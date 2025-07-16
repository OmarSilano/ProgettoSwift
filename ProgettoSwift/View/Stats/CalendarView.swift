//
//  CalendarView.swift
//  ProgettoSwift
//
//  Created by Studente on 16/07/25.
//
import SwiftUI
import UIKit
import CoreData

struct CalendarView: UIViewRepresentable {
    let interval: DateInterval // intervallo di date visibili nel calendario
    @Binding var dateSelected: DateComponents? // data selezionata dall'utente
    var markedDates: Set<DateComponents> // giorni con un completamento da cerchiare
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.delegate = context.coordinator
        calendarView.calendar = Calendar.current
        calendarView.availableDateRange = interval

        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        calendarView.selectionBehavior = selection

        calendarView.backgroundColor = UIColor(named: "CardBackground")
        calendarView.layer.cornerRadius = 16
        calendarView.clipsToBounds = true
        calendarView.overrideUserInterfaceStyle = .dark

        return calendarView
    }

    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        uiView.reloadDecorations(forDateComponents: Array(markedDates), animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        
        init(_ parent: CalendarView) {
            self.parent = parent
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           didSelectDate dateComponents: DateComponents?) {
            parent.dateSelected = dateComponents
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           canSelectDate dateComponents: DateComponents?) -> Bool {
            return dateComponents.map { parent.markedDates.contains($0) } ?? false
        }
        
        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            if parent.markedDates.contains(dateComponents) {
                return .default(color: .systemGreen, size: .large)
            }
            return nil
        }
    }
}
