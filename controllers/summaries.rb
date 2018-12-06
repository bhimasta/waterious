# frozen_string_literal: true

require 'roda'
require 'pusher-push-notifications'

module Waterious
  # Web controller for Waterious API
  class Api < Roda
    route('summaries') do |routing|
      @summary_route = "#{@api_root}/summaries"

      # GET api/v1/summaries/broadcast_notification
      routing.on 'broadcast_notification' do
        routing.get do
          Notification.new(Api.config)
                      .broadcast('Reminder!!','Please drink more water','hello') 
          response.status = 201
          response['Location'] = "#{@summary_route}/broadcast_notification"
          { message: 'Sending push notification' }.to_json
        end
      end

      routing.on 'today' do
        routing.get do
          account = Account.first(username: @auth_account['username'])
          summary = Summary.first(owner_id: account.id, date_start: Date.today)
          # puts "this is today summary"
          # puts summary.to_json
          policy = SummaryPolicy.new(account, summary)
          raise unless policy.can_view?
          summary.full_details
                 .merge(policies: policy.summary)
                 .to_json
        rescue StandardError => error
          puts "ERROR: #{error.inspect}"
          puts error.backtrace
          routing.halt 404, { message: 'Summaries not found' }.to_json
        end
      end

      # GET api/v1/summaries/loss_regularly
      routing.on 'loss_regularly' do
        routing.get do
          # Update all today intake by - 5
          start_date = Date.today
          today_summaries = Summary.where(date_start: start_date).all
          today_summaries.map do |summary|
            stripped_username = summary.owner.username.gsub(' ', '')

            new_total_die = summary.total_die
            new_hydration = summary.current_hydration - 34
            if (new_hydration <= 0) 
              new_hydration = 400
              new_total_die += 1

              # die <-- create new here
              gone_data = {}
              gone_data['victim'] = summary.living_object
              gone = Waterious::CreateGoneForSummary.call(
                summary_id: summary.id, gone_data: gone_data
              )  
              Notification.new(Api.config).broadcast('Oh No!!!!', "I just died, please take care of me next time", stripped_username)              
            else
              # send notification if not die
              if (new_hydration >= 60 && new_hydration <=  100)
                Notification.new(Api.config).broadcast('Reminder!', "Tap in now, I need your help!!", stripped_username)    
              end  
            end
  
            Waterious::Summary.where(id: summary.id)
                              .update(current_hydration: new_hydration,
                                      total_die: new_total_die)
          end
          new_summaries = Summary.where(date_start: start_date).all
          response.status = 201
          response['Location'] = "#{@summary_route}/loss_regularly"
          { message: 'Data able to get', data: new_summaries }.to_json
        rescue StandardError => error
          puts "ERROR: #{error.inspect}"
          puts error.backtrace
          routing.halt 404, { message: 'Summary not found' }.to_json
        end
      end      

      routing.on String do |sum_id|
        # POST api/v1/summaries/[sum_id]/intake
        routing.on 'intake' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            summary = Summary.first(id: sum_id)
            policy = SummaryPolicy.new(account, summary)
            raise unless policy.can_add_intakes?
            # puts "before summary"
            # puts summary.to_json
            # Save intake data to intake history
            intake_data = JSON.parse(routing.body.read)
            intake = Waterious::CreateIntakeForSummary.call(
              summary_id: sum_id, intake_data: intake_data
            )
            # puts "this is intake data"
            # puts intake.to_json

            # Update Summary 
            new_current_hydration = summary.current_hydration + intake_data['amount_intake']
            new_current_hydration = 400 if new_current_hydration > 400
            # puts "before hydration: "
            # puts summary.current_hydration 
            # puts "new curent hydration: "
            # puts new_current_hydration

            new_total_intakes = summary.total_intakes + intake_data['amount_intake']
            # puts "before: "
            # puts summary.total_intakes
            # puts "adding: "
            # puts intake_data['amount_intake']
            # puts "new total intakes: "
            # puts new_total_intakes

            Waterious::Summary.where(id: summary.id)
                              .update(current_hydration: new_current_hydration,
                                      total_intakes: new_total_intakes)
            # updated_sum = Waterious::Summary.first(id: summary.id)
            # puts "this is updated_sum"
            # puts updated_sum.to_json            
            response.status = 201
            response['Location'] = "#{@summary_route}/#{sum_id}/intake"
            { message: 'Intake saved', data: intake }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Summary not found' }.to_json
          end
        end        

        # POST api/v1/summaries/[sum_id]/loss
        routing.on 'loss' do
          routing.get do
            account = Account.first(username: @auth_account['username'])
            summary = Summary.first(id: sum_id)
            policy = SummaryPolicy.new(account, summary)
            raise unless policy.can_reduce_intakes?

            # Update Summary 
            new_total_die = summary.total_die
            new_current_hydration = summary.current_hydration - 5
            if new_current_hydration <= 0
              new_current_hydration = 400
              new_total_die = summary.total_die + 1
            end

            # puts "before hydration: "
            # puts summary.current_hydration 
            # puts "substract: "
            # puts "100"
            # puts "new curent hydration: "
            # puts new_current_hydration

            # puts "did you die?: "
            # puts new_total_die

            Waterious::Summary.where(id: summary.id)
                              .update(current_hydration: new_current_hydration,
                                      total_die: new_total_die)
            # updated_sum = Waterious::Summary.first(id: summary.id)
            # puts "this is updated_sum"
            # puts updated_sum.to_json            
            response.status = 201
            response['Location'] = "#{@summary_route}/#{sum_id}/loss"
            { message: 'Intake saved' }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Summary not found' }.to_json
          end
        end          
        
        # POST api/v1/summaries/[sum_id]/gone
        routing.on 'gone' do
          routing.post do
            account = Account.first(username: @auth_account['username'])
            summary = Summary.first(id: sum_id)
            # policy = ProjectPolicy.new(account, project)
            # raise unless policy.can_add_intake?
            # puts "before summary"
            # puts summary.to_json
            # Save intake data to intake history
            gone_data = JSON.parse(routing.body.read)
            gone = Waterious::CreateGoneForSummary.call(
              summary_id: sum_id, gone_data: gone_data
            )
            # puts "this is gone data"
            # puts gone.to_json

            # Update Summary 
            new_current_hydration = 400
            new_total_die = summary.total_die + 1

            Waterious::Summary.where(id: summary.id)
                              .update(current_hydration: new_current_hydration,
                                      total_die: new_total_die)
            updated_sum = Waterious::Summary.first(id: summary.id)
            # puts "this is updated_sum"
            # puts updated_sum.to_json            
            response.status = 201
            response['Location'] = "#{@summary_route}/#{sum_id}/gone"
            { message: 'Gone saved', data: gone }.to_json
          rescue StandardError => error
            puts "ERROR: #{error.inspect}"
            puts error.backtrace
            routing.halt 404, { message: 'Summary not found' }.to_json
          end
        end          
      end
      
      # GET api/v1/summaries
      routing.get do
        account = Account.first(username: @auth_account['username'])
        summaries_scope = SummaryPolicy::AccountScope.new(account)
        viewable_summaries = summaries_scope.viewable
        summary_list = Summaries.new(viewable_summaries, account)
        summary_list.to_json        
      rescue StandardError => error
        puts "ERROR: #{error.inspect}"
        puts error.backtrace
        routing.halt 403, { message: 'Could not find summaries' }.to_json
      end
    end
  end
end
