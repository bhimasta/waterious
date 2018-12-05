# frozen_string_literal: true

require 'roda'

module Waterious
  # Web controller for Waterious API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on 'change_password' do
        # POST api/v1/accounts/change_password
        routing.post do
          # account = SignedRequest.new(Api.config).parse(request.body.read)
          account = JSON.parse(routing.body.read)
          puts account
          puts account[:email]
          Waterious::ChangePassword.call(
            email: account[:email], edit_data: account
          )
          response.status = 201
          { message: 'Password changed' }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError => error
          puts "ERROR CHANGING PASSWORD: #{error.inspect}"
          puts error.backtrace
          routing.halt 500, { message: error.message }.to_json
        end
      end

      # POST api/v1/accounts/profile/edit
      routing.on 'profile' do
        routing.on 'edit' do
          routing.post do
            data = JSON.parse(routing.body.read)
            account = Account.first(username: @auth_account['username'])
            edited_account = Waterious::EditProfile.call(id: account.id, data: data)
            response.status = 201
            response['Location'] = "#{@account_route}/profile/edit"
            { message: 'Profile edited'}.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => error
            puts "ERROR CREATING ACCOUNT: #{error.inspect}"
            puts error.backtrace
            routing.halt 500, { message: error.message }.to_json
          end
        end
      end

      # GET api/v1/accounts/create_15_accounts
      routing.on 'create_15_accounts' do 
        routing.get do
          var = 1
          x = {}
          participants = ['li123','gao321','zhong213','zeng321','chen213','wang123','gaoren213',
            'liao111','yang222','huang333','dai332','mao221','zhuang113','pan112','liao212']        
          new_account = {}
          participants.each do |participant|
            x['username'] = participant
            x['password'] = participant
            x['email'] = "ManusiaHebat" + var.to_s + "@iss.nthu.edu.tw"
            x['profile'] = "https://s3.amazonaws.com/Waterious-app/profile/default.jpg"
            new_account = EmailAccount.new(x)
            raise('Could not save account') unless new_account.save
            var = var + 1             
          end
          response.status = 201
          response['Location'] = "#{@account_route}/#{new_account.id}"
          { message: 'All Account created' }.to_json
        rescue StandardError => error
          puts "ERROR CREATING 15 ACCOUNTS: #{error.inspect}"
          puts error.backtrace
          routing.halt 404, { message: error.message }.to_json
        end
      end

      # GET api/v1/accounts/randomize_accounts
      routing.on 'randomize_accounts' do 
        routing.get do
          long_a_condition = 5
          condition = 1
          accounts = Account.all
          
          # for testing first day
          x = 1
          accounts.each do |account|
            summary_data = {}
            start_date = Date.today
            summary_data['date_start'] = start_date
            summary_data['living_object'] = 'Human' if x <= 5
            summary_data['living_object'] = 'Animal' if x <= 10
            summary_data['living_object'] = 'Plant' if x <= 15
            # puts summary_data
            x += 1
            Waterious::CreateSummaryForUser.call(owner_id: account.id, summary_data: summary_data)          
          end

          # for real experiment
          accounts.each do |account|
            
            Waterious::Account.where(id: account.id).update(condition: condition)

            condition = condition + 1
            condition = 1 if condition > 3            

            #generate data
            order = ['Human','Animal','Plant'] if condition == 1
            order = ['Animal','Plant','Human'] if condition == 2
            order = ['Plant','Human','Animal'] if condition == 3
            start_date = Date.today + 1
            order.each do |cond|
              (1..long_a_condition).each do
                summary_data = {}
                summary_data['date_start'] = start_date
                start_date = start_date + 1
                summary_data['living_object'] = cond

                Waterious::CreateSummaryForUser.call(owner_id: account.id, summary_data: summary_data)          
              end
            end              
          end
          # puts accounts.to_json
          response.status = 201
          response['Location'] = "#{@account_route}/randomize_accounts"
          { message: 'Randomize Succeed', data: accounts }.to_json
          # { message: 'Haiiii' }.to_json
        rescue StandardError => error
          puts "ERROR CREATING 15 ACCOUNTS: #{error.inspect}"
          puts error.backtrace
          routing.halt 404, { message: error.message }.to_json
        end
      end

      # POST api/v1/accounts/password/edit
      routing.on 'password' do
        routing.on 'edit' do
          routing.post do
            data = JSON.parse(routing.body.read)
            account = Account.first(username: @auth_account['username'])
            # account = Account.first(username: 'victorlin12345')
            if account.password_check(account.salt,
                                      data['old_password']) == true
              account.password = (data['new_password'])
              edit_data = { :password_hash => account.password_hash,
                            :salt => account.salt }
              account.update(edit_data).to_json
              response.status = 201
              response['Location'] = "#{@account_route}/password/edit"
              { message: 'Password edited' }.to_json
            elsif data['new_password'].nil?
              { message: 'The new password cant be empty' }.to_json
            else
              { message: 'The old password is wrong' }.to_json
            end
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => error
            puts "ERROR CREATING ACCOUNT: #{error.inspect}"
            puts error.backtrace
            routing.halt 500, { message: error.message }.to_json
          end
        end
      end

      # GET api/v1/accounts/
      routing.on String do |username|
        routing.get do
          raise unless username == @auth_account['username']
          account = Account.first(username: @auth_account['username'])
          account ? account.to_json : raise('Account not found')
        rescue StandardError => error
          puts "ERROR GETTING ACCOUNT: #{error.inspect}"
          puts error.backtrace
          routing.halt 404, { message: error.message }.to_json
        end
      end

      # POST api/v1/accounts
      routing.post do
        # new_data = SignedRequest.new(Api.config).parse(request.body.read)
        new_data = JSON.parse(routing.body.read)
        new_account = EmailAccount.new(new_data)
        raise('Could not save account') unless new_account.save
        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.id}"
        { message: 'Account created', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => error
        # puts "ERROR CREATING ACCOUNT: #{error.inspect}"
        # puts error.backtrace
        routing.halt 500, { message: error.message }.to_json
      end
    end
  end
end
