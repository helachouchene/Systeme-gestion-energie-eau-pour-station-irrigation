package com.irrigation.eau.event;

import java.time.LocalDateTime;

public class SurconsommationEvent {
    
    private Long pompeId;
    private Double energieUtilisee;
    private LocalDateTime dateMesure;
    private String message;
    
    public SurconsommationEvent() {
    }
    
    public SurconsommationEvent(Long pompeId, Double energieUtilisee, LocalDateTime dateMesure, String message) {
        this.pompeId = pompeId;
        this.energieUtilisee = energieUtilisee;
        this.dateMesure = dateMesure;
        this.message = message;
    }
    
    public Long getPompeId() {
        return pompeId;
    }
    
    public void setPompeId(Long pompeId) {
        this.pompeId = pompeId;
    }
    
    public Double getEnergieUtilisee() {
        return energieUtilisee;
    }
    
    public void setEnergieUtilisee(Double energieUtilisee) {
        this.energieUtilisee = energieUtilisee;
    }
    
    public LocalDateTime getDateMesure() {
        return dateMesure;
    }
    
    public void setDateMesure(LocalDateTime dateMesure) {
        this.dateMesure = dateMesure;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    @Override
    public String toString() {
        return "SurconsommationEvent{" +
                "pompeId=" + pompeId +
                ", energieUtilisee=" + energieUtilisee +
                ", dateMesure=" + dateMesure +
                ", message='" + message + '\'' +
                '}';
    }
}