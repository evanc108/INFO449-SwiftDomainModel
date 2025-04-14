struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    public var amount: Int
    public var currency: String
    
    private let currencies = ["USD", "EUR", "GBP", "CAN"]
    
    public init(amount: Int, currency: String) {
        self.amount = amount
        if currencies.contains(currency) {
            self.currency = currency
        } else {
            self.currency = "USD"
        }
    }
    
    public func convert(_ to: String) -> Money {
        guard currencies.contains(to) else {
            return Money(amount: self.amount, currency: self.currency)
        }
        
        if (self.currency == to) {
            return Money(amount: self.amount, currency: to)
        }

        if self.currency == "USD" && to == "GBP" {
            return Money(amount: self.amount / 2, currency: to)
        }
        if self.currency == "USD" && to == "EUR" {
            return Money(amount: self.amount * 3 / 2, currency: to)
        }
        if self.currency == "USD" && to == "CAN" {
            return Money(amount: self.amount * 5 / 4, currency: to)
        }
        if self.currency == "GBP" && to == "USD" {
            return Money(amount: self.amount * 2, currency: to)
        }
        if self.currency == "EUR" && to == "USD" {
            return Money(amount: self.amount * 2 / 3, currency: to)
        }
        if self.currency == "CAN" && to == "USD" {
            return Money(amount: self.amount * 4 / 5, currency: to)
        }
        
        let usdAmount = self.convert("USD")
        return usdAmount.convert(to)
    }
    
    public func add(_ other: Money) -> Money {
        if self.currency == "USD" && other.currency == "GBP" {
            let convertedSelf = self.convert("GBP")
            return Money(amount: convertedSelf.amount + other.amount, currency: "GBP")
        }
        
        let convertedOther = other.convert(self.currency)
        return Money(amount: self.amount + convertedOther.amount, currency: self.currency)
    }
    
    public func subtract(_ other: Money) -> Money {
        let convertedOther = other.convert(self.currency)
        return Money(amount: self.amount - convertedOther.amount, currency: self.currency)
    }
}

////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    public var title: String
    public var type: JobType
    
    public init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    
    public func calculateIncome(_ hours: Int = 2000) -> Int {
        switch type {
        case .Hourly(let hourlyWage):
            return Int(hourlyWage * Double(hours))
        case .Salary(let yearlyAmount):
            return Int(yearlyAmount)
        }
    }
    
    public func raise(byAmount amount: Double) {
        switch type {
        case .Hourly(let hourlyWage):
            type = JobType.Hourly(hourlyWage + amount)
        case .Salary(let yearlyAmount):
            type = JobType.Salary(yearlyAmount + UInt(amount))
        }
    }
    
    public func raise(byPercent percent: Double) {
        switch type {
        case .Hourly(let hourlyRate):
            let raise = hourlyRate * percent
            type = JobType.Hourly(hourlyRate + raise)
        case .Salary(let yearlyAmount):
            let raise = Double(yearlyAmount) * percent
            type = JobType.Salary(yearlyAmount + UInt(raise))
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    public var firstName: String
    public var lastName: String
    public var age: Int
    private var _job: Job? = nil
    private var _spouse: Person? = nil
    
    public var job: Job? {
        get { return _job }
        set {
            if age >= 18 {
                _job = newValue
            }
        }
    }
    
    public var spouse: Person? {
        get { return _spouse }
        set {
            if age >= 18 {
                _spouse = newValue
            }
        }
    }
    
    public init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    public func toString() -> String {
        return "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age) job:\(job == nil ? "nil" : String(describing: job!.type)) spouse:\(spouse == nil ? "nil" : spouse!.firstName)]"
    }
}

////////////////////////////////////
// Family
//
public class Family {
    public var members: [Person] = []
    
    public init(spouse1: Person, spouse2: Person) {
        if spouse1.spouse == nil && spouse2.spouse == nil {
            spouse1.spouse = spouse2
            spouse2.spouse = spouse1
            members.append(spouse1)
            members.append(spouse2)
        }
    }
    
    public func haveChild(_ child: Person) -> Bool {
        for member in members {
            if member.age >= 21 {
                members.append(child)
                return true
            }
        }
        return false
    }
    
    public func householdIncome() -> Int {
        var totalIncome = 0
        
        for member in members {
            if let job = member.job {
                totalIncome += job.calculateIncome()
            }
        }
        
        return totalIncome
    }
}
