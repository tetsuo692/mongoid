require "mongoid"
require "perftools"

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("mongoid_perf_test")
end

Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)

class Person
  include Mongoid::Document

  field :birth_date, :type => Date
  field :title, :type => String

  embeds_one :name, :validate => false
  embeds_many :addresses, :validate => false
  embeds_many :phones, :validate => false

  references_many :posts, :validate => false
  references_one :game, :validate => false
  references_and_referenced_in_many :preferences, :validate => false
end

class Name
  include Mongoid::Document

  field :given, :type => String
  field :family, :type => String
  field :middle, :type => String
  embedded_in :person
end

class Address
  include Mongoid::Document

  field :street, :type => String
  field :city, :type => String
  field :state, :type => String
  field :post_code, :type => String
  field :address_type, :type => String
  embedded_in :person
end

class Phone
  include Mongoid::Document

  field :country_code, :type => Integer
  field :number, :type => String
  field :phone_type, :type => String
  embedded_in :person
end

class Post
  include Mongoid::Document

  field :title, :type => String
  field :content, :type => String
  referenced_in :person
end

class Game
  include Mongoid::Document

  field :name, :type => String
  referenced_in :person
end

class Preference
  include Mongoid::Document

  field :name, :type => String
  references_and_referenced_in_many :people
end

puts "Starting profiler"

def without_gc
  GC.disable
  yield
  GC.enable
  GC.start
end

without_gc do
  puts "[ Root Document #create ]"
  PerfTools::CpuProfiler.start("perf/root_create.profile") do
    100000.times do |n|
      Person.create(:birth_date => Date.new(1970, 1, 1))
    end
  end
end

without_gc do
  puts "[ Root Document #each ]"
  PerfTools::CpuProfiler.start("perf/root_each.profile") do
    Person.all.each { |person| person.birth_date }
  end
end

without_gc do
  puts "[ Root Document #save ]"
  PerfTools::CpuProfiler.start("perf/root_save.profile") do
    Person.all.each do |person|
      person.title = "Testing"
      person.save
    end
  end
end

without_gc do
  puts "[ Root Document #update_attribute ]"
  PerfTools::CpuProfiler.start("perf/root_save.profile") do
    Person.all.each { |person| person.update_attribute(:title, "Updated") }
  end
end

person = Person.first

without_gc do
  puts "[ Embedded 1-n #build ]"
  PerfTools::CpuProfiler.start("perf/embedded_n_build.profile") do
    1000.times do |n|
      person.addresses.build(
        :street => "Wienerstr. #{n}",
        :city => "Berlin",
        :post_code => "10999"
      )
    end
  end
end

without_gc do
  puts "[ Embedded 1-n #clear ]"
  PerfTools::CpuProfiler.start("perf/embedded_n_clear.profile") do
    person.addresses.clear
  end
end

without_gc do
  puts "[ Embedded 1-n #create ]"
  PerfTools::CpuProfiler.start("perf/embedded_n_create.profile") do
    1000.times do |n|
      person.addresses.create(
        :street => "Wienerstr. #{n}",
        :city => "Berlin",
        :post_code => "10999"
      )
    end
  end
end

without_gc do
  puts "[ Embedded 1-n #count ]"
  PerfTools::CpuProfiler.start("perf/embedded_n_count.profile") do
    person.addresses.count
  end
end

without_gc do
  puts "[ Embedded 1-n #delete_all ]"
  PerfTools::CpuProfiler.start("perf/embedded_n_delete_all.profile") do
    person.addresses.delete_all
  end
end

without_gc do
  puts "[ Embedded 1-n #push ]"
  PerfTools::CpuProfiler.start("perf/embedded_n_push.profile") do
    1000.times do |n|
      person.addresses.push(
        Address.new(
          :street => "Wienerstr. #{n}",
          :city => "Berlin",
          :post_code => "10999"
        )
      )
    end
  end
end

without_gc do
  puts "[ Embedded 1-n #save ]"
  PerfTools::CpuProfiler.start("perf/embedded_n_save.profile") do
    person.addresses.each do |address|
      address.address_type = "Work"
      address.save
    end
  end
end

without_gc do
  puts "[ Embedded 1-n #update_attribute ]"
  PerfTools::CpuProfiler.start("perf/embedded_n_update_attribute.profile") do
    person.addresses.each do |address|
      address.update_attribute(:address_type, "Home")
    end
  end
end

address = person.addresses.last

without_gc do
  puts "[ Embedded 1-n #find ]"
  PerfTools::CpuProfiler.start("perf/embedded_n_find.profile") do
    person.addresses.find(address.id)
  end
end

without_gc do
  puts "[ Embedded 1-n #delete ]"
  PerfTools::CpuProfiler.start("perf/embedded_n_delete.profile") do
    person.addresses.delete(address)
  end
end

person.addresses.delete_all

without_gc do
  puts "[ Embedded 1-1 #relation= ]"
  PerfTools::CpuProfiler.start("perf/embedded_1_relation.profile") do
    10000.times do |n|
      person.name = Name.new(:given => "Name #{n}")
    end
  end
end

without_gc do
  puts "[ Referenced 1-n #build ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_build.profile") do
    10000.times do |n|
      person.posts.build(:title => "Posting #{n}")
    end
  end
end

without_gc do
  puts "[ Referenced 1-n #clear ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_clear.profile") do
    person.posts.clear
  end
end

without_gc do
  puts "[ Referenced 1-n #create ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_create.profile") do
    10000.times do |n|
      person.posts.create(:title => "Posting #{n}")
    end
  end
end

without_gc do
  puts "[ Referenced 1-n #count ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_count.profile") do
    person.posts.count
  end
end

without_gc do
  puts "[ Referenced 1-n #delete_all ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_delete_all.profile") do
    person.posts.delete_all
  end
end

without_gc do
  puts "[ Referenced 1-n #push ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_push.profile") do
    10000.times do |n|
      person.posts.push(Post.new(:title => "Posting #{n}"))
    end
  end
end

without_gc do
  puts "[ Referenced 1-n #save ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_save.profile") do
    person.posts.each do |post|
      post.content = "Test"
      post.save
    end
  end
end

without_gc do
  puts "[ Referenced 1-n #save ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_update_attribute.profile") do
    person.posts.each do |post|
      post.update_attribute(:content, "Testing")
    end
  end
end

post = person.posts.last

without_gc do
  puts "[ Referenced 1-n #find ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_find.profile") do
    person.posts.find(post.id)
  end
end

without_gc do
  puts "[ Referenced 1-n #delete ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_delete.profile") do
    person.posts.delete(post)
  end
end

person.posts.delete_all

without_gc do
  puts "[ Referenced 1-1 #relation= ]"
  PerfTools::CpuProfiler.start("perf/referenced_1_relation.profile") do
    10000.times do |n|
      person.name = Game.new(:name => "Final Fantasy #{n}")
    end
  end
end

without_gc do
  puts "[ Referenced n-n #build ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_n_build.profile") do
    10000.times do |n|
      person.preferences.build(:name => "Preference #{n}")
    end
  end
end

without_gc do
  puts "[ Referenced n-n #clear ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_n_clear.profile") do
    person.preferences.clear
  end
end

without_gc do
  puts "[ Referenced n-n #create ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_n_create.profile") do
    10000.times do |n|
      person.preferences.create(:name => "Preference #{n}")
    end
  end
end

without_gc do
  puts "[ Referenced n-n #count ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_n_count.profile") do
    person.preferences.count
  end
end

without_gc do
  puts "[ Referenced n-n #delete_all ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_n_delete_all.profile") do
    person.preferences.delete_all
  end
end

without_gc do
  puts "[ Referenced n-n #push ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_n_push.profile") do
    10000.times do |n|
      person.preferences.push(Preference.new(:name => "Preference #{n}"))
    end
  end
end

without_gc do
  puts "[ Referenced n-n #save ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_n_save.profile") do
    person.preferences.each do |preference|
      preference.name = "Test"
      preference.save
    end
  end
end

without_gc do
  puts "[ Referenced n-n #save ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_n_update_attribute.profile") do
    person.preferences.each do |preference|
      preference.update_attribute(:name, "Testing")
    end
  end
end

preference = person.preferences.last

without_gc do
  puts "[ Referenced n-n #find ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_n_find.profile") do
    person.preferences.find(preference.id)
  end
end

without_gc do
  puts "[ Referenced n-n #delete ]"
  PerfTools::CpuProfiler.start("perf/referenced_n_n_delete.profile") do
    person.preferences.delete(preference)
  end
end

person.preferences.delete_all

Dir.glob("perf/*.profile") do |profile|
  puts "Generating #{profile}.pdf..."
  `bundle exec pprof.rb --pdf #{profile} > #{profile}.pdf`
end
