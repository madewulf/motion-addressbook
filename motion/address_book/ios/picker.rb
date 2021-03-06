module AddressBook
  class Picker
    class << self
      attr_accessor :showing
    end
    def self.show(&after)
      raise "Cannot show two Pickers" if showing?
      @picker = Picker.new(&after)
      @picker.show
      @picker
    end

    def self.showing?
      !!showing
    end

    def initialize(&after)
      @after = after
    end

    def show
      self.class.showing = true

      @people_picker_ctlr = ABPeoplePickerNavigationController.alloc.init
      @people_picker_ctlr.peoplePickerDelegate = self
      UIApplication.sharedApplication.keyWindow.rootViewController.presentViewController(@people_picker_ctlr, animated:true, completion:nil)
    end

    def hide(ab_person=nil)
      person = ab_person ? AddressBook::Person.new({}, ab_person) : nil

      UIApplication.sharedApplication.keyWindow.rootViewController.dismissViewControllerAnimated(true, completion:lambda{
        @after.call(person) if @after
        self.class.showing = false
      })
    end

    def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person)
      hide(ab_person)
      false
    end

    def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person, property:property, identifier:id)
      hide(ab_person)
      false
    end

    def peoplePickerNavigationControllerDidCancel(people_picker)
      hide
    end
  end
end

module AddressBook
  module_function
  def pick(&after)
    AddressBook::Picker.show &after
  end
end

