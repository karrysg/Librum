#pragma once
#include <QObject>


class SidebarState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(State currentState READ currentState WRITE setCurrentState NOTIFY currentStateChanged)
    
public:
    explicit SidebarState(QObject *parent = nullptr);
    
    
    enum State
    {
        Closed,
        Opened
    };
    Q_ENUM(State);
    
    State currentState() const;
    void setCurrentState(State newState);
    
signals:
    void currentStateChanged();
    
private:
    State m_currentState;
};