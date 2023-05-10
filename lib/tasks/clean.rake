# frozen_string_literal: true

namespace :clean do
  desc 'Clean all marketplace entities in DB and all associated files'
  task all: %i[paranoid_confirmation environment] do
    announce 'Start cleaning'

    time_elapsed = Benchmark.realtime do
      [Boat, Review, User].each(&method(:destroy_model))
    end

    announce "Cleaning successfully finished! (#{time_elapsed.round(3)}s) Bye!"
  end

  task :paranoid_confirmation do
    announce '[WARNING] This task is destructive!'
    say 'It will delete all entities in DB and all associated files.'
    say 'Are you sure you want to continue? Enter `yes i am sure` to confirm:'

    if STDIN.gets.chomp.casecmp('yes i am sure').zero?
      puts # To separate confirmation from processing output.
    else
      announce 'Cleaning aborted! Bye!'
      abort
    end
  end
end

def announce(message)
  length = [0, 75 - (text = message.to_s).length].max
  puts format('== %<text>s %<ending>s', text: text, ending: '=' * length)
end

def say(message, subitem = false)
  puts "#{subitem ? '   ->' : '--'} #{message}"
end

def destroy_model(model)
  announce "Deleting #{model.name}s and all associated (#{model.count})"

  destroyed_models = 0
  admin_emails = %w[alex.petrofan@gmail.com dmitry.sokolov@roobykon.com]

  time_elapsed = Benchmark.realtime do
    destroyed_models = if model.name == 'User'
                         model.where.not(email: admin_emails).destroy_all
                       else
                         model.destroy_all
                       end
  end

  announce "#{destroyed_models.count} #{model.name}s deleted "\
           "(#{time_elapsed.round(3)}s)"
  puts
end
