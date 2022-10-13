#pragma once
#include <QObject>
#include <QString>
#include <QImage>


namespace adapters
{

class IUserStorageAccess : public QObject
{
    Q_OBJECT
    
public:
    virtual ~IUserStorageAccess() noexcept = default;
    
    virtual void getUser(const QString& authToken) = 0;
    virtual void changeFirstName(const QString& authToken, 
                                 const QString& newFirstName) = 0;
    virtual void changeLastName(const QString& authToken,
                                const QString& newLastName) = 0;
    virtual void changeEmail(const QString& authToken,
                             const QString& newEmail) = 0;
    virtual void changeProfilePicture(const QString& authToken,
                                      const QImage& newProfilePicture) = 0;
    
signals:
    void userReady(const QString firstName, const QString lastName, 
                   const QString email);
    void gettingUserFailed();
};

} // namespace adapters