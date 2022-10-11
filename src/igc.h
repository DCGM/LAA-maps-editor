#ifndef IGC__H
#define IGC__H

#include <QtCore>

/// A single event from the igc file.
/// the field type determines which subclass of Event
/// this is.
class IgcEvent : public QObject {
    Q_OBJECT

    Q_PROPERTY(EventType eventType READ getEventType WRITE setEventType NOTIFY
            eventTypeChanged)
    Q_PROPERTY(
        QTime time READ getTimestamp WRITE setTimestamp NOTIFY timestampChanged)

public:
    enum EventType { FIX = 1,
        PILOT_EVENT = 2 };

    void setTimestamp(QTime _timestamp)
    {
        m_timestamp = _timestamp;
        emit timestampChanged();
    }
    void setEventType(EventType _type)
    {
        m_type = _type;
        emit eventTypeChanged();
    }
    QTime getTimestamp() const { return m_timestamp; }
    EventType getEventType() const { return m_type; }

    IgcEvent();

private:
    EventType m_type;
    QTime m_timestamp;

    Q_ENUMS(EventType)

signals:
    void eventTypeChanged();
    void timestampChanged();
};

/// GPS fix event.
class Fix : public IgcEvent {
    Q_OBJECT

    Q_PROPERTY(qreal lat READ getLat WRITE setLat NOTIFY latChanged)
    Q_PROPERTY(qreal lon READ getLon WRITE setLon NOTIFY lonChanged)
    Q_PROPERTY(qreal alt READ getAlt WRITE setAlt NOTIFY altChanged)
    Q_PROPERTY(qreal pressureAlt READ getPressureAlt WRITE setPressureAlt NOTIFY
            pressureAltChanged)
    Q_PROPERTY(bool valid READ getValid WRITE setValid NOTIFY validChanged)

    qreal m_lat;
    qreal m_lon;
    qreal m_alt;
    qreal m_pressureAlt;
    bool m_valid;

signals:
    void latChanged();
    void lonChanged();
    void altChanged();
    void validChanged();
    void pressureAltChanged();

public:
    void setLat(qreal _lat)
    {
        m_lat = _lat;
        emit latChanged();
    }
    void setLon(qreal _lon)
    {
        m_lon = _lon;
        emit lonChanged();
    }
    void setAlt(qreal _alt)
    {
        m_alt = _alt;
        emit altChanged();
    }
    void setPressureAlt(qreal _pressureAlt)
    {
        m_pressureAlt = _pressureAlt;
        emit pressureAltChanged();
    }
    void setValid(bool _valid)
    {
        m_valid = _valid;
        emit validChanged();
    }

    qreal getLat() const { return m_lat; }
    qreal getLon() const { return m_lon; }
    qreal getAlt() const { return m_alt; }
    qreal getPressureAlt() const { return m_pressureAlt; }
    bool getValid() const { return m_valid; }
};

/// Pilot event.
struct PilotEvent : public IgcEvent {
};

/// A class that loads an IGC file.
class IgcFile : public QAbstractListModel {
    // class IgcFile : public QObject {
    Q_OBJECT
public:
    enum IgcEventRoles {
        typeRole = Qt::UserRole + 1,
        timeRole,
        latRole,
        lonRole,
        altRole,
        pressureAltRole,
        validRole
    };
    QHash<int, QByteArray> roleNames() const;

    IgcFile(QObject* object = 0);
    ~IgcFile() { clear(); }

    Q_INVOKABLE bool load(const QString& path, QTextCodec* codec = 0);
    bool load(QIODevice* file, QTextCodec* codec = 0);
    Q_INVOKABLE void clear();

    int getCount() { return rowCount(); }
    Q_INVOKABLE QVariant get(int row);

    /// Return altimeter pressure setting in hectopascals or zero
    /// if it was not specified.
    /// This value doesn't affect altitudes returned in fixes in any way.
    /// All recorded altitudes use 1013.25 as a base pressure.
    Q_PROPERTY(qreal altimeterSetting READ altimeterSetting)
    qreal altimeterSetting() const { return altimeterSetting_; }

    /// Return competition class or null string.
    Q_PROPERTY(QString competitionClass READ competitionClass)
    QString competitionClass() const { return competitionClass_; }

    /// Return glider competition ID or null string.
    Q_PROPERTY(QString competitionId READ competitionId)
    QString competitionId() const { return competitionId_; }

    /// Return date of the recording.
    Q_PROPERTY(QDate date READ date)
    QDate date() const { return date_; }

    /// Return FR manufacturer or null string.
    Q_PROPERTY(QString manufacturer READ manufacturer)
    QString manufacturer() const { return manufacturer_; }

    /// Return FR type or null string.
    Q_PROPERTY(QString frType READ frType)
    QString frType() const { return frType_; }

    /// Return glider registration number or null string.
    Q_PROPERTY(QString gliderId READ gliderId)
    QString gliderId() const { return gliderId_; }

    /// Return GPS receiver type or null string.
    Q_PROPERTY(QString gps READ gps)
    QString gps() const { return gps_; }

    /// Return glider model or null string.
    Q_PROPERTY(QString gliderType READ gliderType)
    QString gliderType() const { return gliderType_; }

    /// Return pilot name or null string.
    Q_PROPERTY(QString pilot READ pilot)
    QString pilot() const { return pilot_; }

    /// Return a const reference to the event map.

    //    Q_PROPERTY(QList<IgcEvent*> events READ events NOTIFY eventsChanged)
    Q_PROPERTY(int count READ getCount NOTIFY eventsChanged)
    QList<IgcEvent*> events() const { return eventList; }

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
    int rowCount(const QModelIndex& parent = QModelIndex()) const;

    //    const EventList events() const { return eventList; }

private:
    /// Load record into the buffer and parse it.
    /// \return True on success.
    bool loadOneRecord();

    /// Parse a single record stored in the buffer.
    bool parseOneRecord();

    /// Parse time from IGC encoding. The time is in the HHMMSS format.
    /// \param bytes The byte array with the time to be parsed.
    /// \param ok Set to true if parsing was successful, false otherwise.
    QTime parseTimestamp(QByteArray bytes, bool* ok);

    /// Parse latitude or longitude from IGC encoding.
    /// \param bytes The byte array with the latitude/longitude number to be
    ///              parsed.
    /// \param ok Set to true if parsing was successful, false otherwise.
    /// \return Degrees. Negative values go south and west.
    /// DDMMmmm[NS] or DDDMMmmm[EW]
    qreal parseLatLon(QByteArray bytes, bool* ok);

    /// Parse a decimal number in igc format.
    /// \param bytes The byte array with the decimal number to be parsed.
    /// \param ok Set to true if parsing was successful, false otherwise.
    qreal parseDecimal(QByteArray bytes, bool* ok);

    /// Parse date specification.
    /// \param bytes The byte array with the date to be parsed.
    /// \param ok Set to true if parsing was successful, false otherwise.
    QDate parseDate(QByteArray bytes, bool* ok);

    /// Process a single record of type B (fix data) stored in buffer.
    bool processRecordB();

    /// Process a single record of type H (headers) stored in buffer.
    bool processRecordH();

    /// Process a single record of type L (comments) stored in buffer.
    bool processRecordL();

    static bool eventLessThan(const IgcEvent* e1, const IgcEvent* e2);

    QList<IgcEvent*> eventList;

    QByteArray buffer;

    char previousRecord;
    QIODevice* file;
    QTextCodec* activeCodec;

    /// Data extracted from IGC headers.
    /// \{
    qreal altimeterSetting_;
    QString competitionClass_;
    QString competitionId_;
    QDate date_;
    QString manufacturer_;
    QString frType_;
    QString gliderId_;
    QString gps_;
    QString gliderType_;
    QString pilot_;
    /// \}
signals:
    void eventsChanged();
};

#endif // IGC__H
