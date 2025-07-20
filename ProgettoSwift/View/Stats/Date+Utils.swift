import Foundation

extension DateComponents {
    // Restituisce una versione normalizzata che contiene solo anno, mese e giorno
    func normalized() -> DateComponents {
        return DateComponents(
            year: self.year,
            month: self.month,
            day: self.day
        )
    }
    
    // Confronta solo anno/mese/giorno (ignora ore, timezone ecc.)
    func isSameDay(as other: DateComponents) -> Bool {
        return self.year == other.year &&
               self.month == other.month &&
               self.day == other.day
    }
}

extension Date {
    // Converte una Date in DateComponents normalizzati (anno/mese/giorno)
    func asNormalizedComponents(calendar: Calendar = .current) -> DateComponents {
        let comps = calendar.dateComponents([.year, .month, .day], from: self)
        return comps.normalized()
    }
}
