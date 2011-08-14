require "spec_helper"

describe Mongoid::Relations::Embedded::In do

  let(:binding_klass) do
    Mongoid::Relations::Bindings::Embedded::In
  end

  let(:builder_klass) do
    Mongoid::Relations::Builders::Embedded::In
  end

  let(:nested_builder_klass) do
    Mongoid::Relations::Builders::NestedAttributes::One
  end

  let(:binding) do
    stub
  end

  let(:base) do
    Name.new
  end

  let(:target) do
    Person.new
  end

  let(:metadata) do
    Mongoid::Relations::Metadata.new(
      :relation => described_class,
      :inverse_class_name => "Name",
      :name => :namable,
      :polymorphic => true
    )
  end

  describe "#===" do

    let(:relation) do
      described_class.new(base, target, metadata)
    end

    context "when the proxied document is same class" do

      it "returns true" do
        (relation === Person.new).should be_true
      end
    end
  end

  describe ".builder" do

    it "returns the embedded one builder" do
      described_class.builder(metadata, target).should be_a(builder_klass)
    end
  end

  describe ".embedded?" do

    it "returns true" do
      described_class.should be_embedded
    end
  end

  describe "#initialize" do

    let(:relation) do
      described_class.new(base, target, metadata)
    end

    it "parentizes the child" do
      relation.base._parent.should == target
    end
  end

  describe ".macro" do

    it "returns embeds_one" do
      described_class.macro.should == :embedded_in
    end
  end

  describe ".nested_builder" do

    let(:attributes) do
      {}
    end

    it "returns the single nested builder" do
      described_class.nested_builder(metadata, attributes, {}).should
        be_a(nested_builder_klass)
    end
  end

  describe ".valid_options" do

    it "returns the valid options" do
      described_class.valid_options.should ==
        [ :cyclic, :polymorphic ]
    end
  end
end
