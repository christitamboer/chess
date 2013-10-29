class Employee
  attr_accessor :salary, :manager
  def initialize(salary)
    @salary = salary
    @manager = []
  end

  def bonus(multiplier)
    bonus = self.salary * multiplier
  end


end

class Manager < Employee
  attr_accessor :sub_employees
  def initialize(salary)
    super(salary)
    @sub_employees = []
  end

  def employee(employee)
    @sub_employees << employee
    employee.manager << self
  end

  def bonus(multiplier)
    bonus = self.salary * multiplier
    employee_arr = []
    @sub_employees.each do |employee|
      bonus += employee.salary
      if employee.class == Manager && employee.sub_employees.length > 0
        employee_arr << employee
      end

    end

    until employee_arr.empty?
      next_employee = employee_arr.shift
      bonus += next_employee.salary
      employee_arr += next_employee.sub_employees

    end

    bonus
  end

end

a = Employee.new(50000)
