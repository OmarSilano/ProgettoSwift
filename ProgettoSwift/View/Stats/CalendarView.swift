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
            guard let tapped = dateComponents?.normalized() else { return false }
            
            // Normalizziamo tutte le markedDates
            let normalizedMarked = parent.markedDates.map { $0.normalized() }
            
            // Controlliamo se esiste almeno una data che coincide
            return normalizedMarked.contains(tapped)
        }
        
        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            
            let normalizedDay = dateComponents.normalized()
            
            let normalizedMarked = parent.markedDates.map { $0.normalized() }
            
            if normalizedMarked.contains(normalizedDay) {
                return .default(
                    color: UIColor(named: "SecondaryColor") ?? .systemBlue,
                    size: .medium
                )
            }
            
            return nil
        }
    }
}
