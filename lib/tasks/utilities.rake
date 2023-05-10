namespace :utilities do

  desc 'Change feature name'
  task :change_feature_name, [:category_name, :feature_name, :feature_new_name] => :environment do |task, args|
    category = Category.find_by_name(args.category_name)
    abort "This category does not exist" unless category
      
    feature = Feature.where(category_id: category.id, name: args.feature_name).first
    if feature
      feature.name = args.feature_new_name
      feature.save
      puts "Feature #{args.feature_name} was changed by #{args.feature_new_name}"
    elsif !feature
      puts "This feature #{args.feature_name} does not exist"
    else
      puts "Something went wrong"
    end
  end

  desc 'Add a new feature to boat category features'
  task :add_new_feature_to_boat_features, [:category_name, :feature_name] => :environment do |task, args|
    category = Category.find_by_name(args.category_name)
    abort "this category name does not exist" unless category

    if Feature.create(category_id: category.id, name: args.feature_name)
      puts "Feature #{args.feature_name} was successfully created"
    else
      puts "Something went wrong"
    end
  end


  desc 'Delete a feature from boat features'
  task :delete_feature_from_boat_features, [:category_name, :feature_name] => :environment do |task, args|
    category = Category.find_by_name(args.category_name)
    abort "this category name does not exist" unless category

    feature = Feature.find_by(category_id: category.id, name: args.feature_name)
    abort "this feature name does not exist" unless feature

    if feature.destroy
      puts "Feature #{args.feature_name} from Category #{args.category_name} was successfully deleted"
    else
      puts "Something went wrong"
    end
  end
  
end
  
