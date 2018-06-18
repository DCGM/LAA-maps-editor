#ifndef FILEREADER_H
#define FILEREADER_H

#include <QObject>

class FileReader : public QObject
{
    Q_OBJECT
public:
    explicit FileReader(QObject *parent = 0);


    Q_INVOKABLE QString toLocal(const QUrl &filename);

    Q_INVOKABLE QByteArray read_local(const QString &filename);
    Q_INVOKABLE bool file_exists_local(const QString &filename);
    Q_INVOKABLE void write_local(const QString &filename, QByteArray data);

    Q_INVOKABLE void copy_file(const QUrl &filename, const QUrl &newFilename);

    Q_INVOKABLE void write(const QUrl &filename, QByteArray data);
    Q_INVOKABLE void writeUTF8(const QUrl &filename, QByteArray data);
    Q_INVOKABLE bool file_exists(const QUrl &filename);
    Q_INVOKABLE QByteArray read(const QUrl &filename);

    Q_INVOKABLE bool is_local_file(const QUrl &filename);

    Q_INVOKABLE bool delete_file(const QUrl &filename);
    Q_INVOKABLE bool delete_file_local(const QString &filename);

    Q_INVOKABLE void remove_if_exists(const QUrl &filename);

    Q_INVOKABLE QString dirname_local(const QString &filename);
    Q_INVOKABLE bool is_dir_and_exists_local(const QString &dirname);


signals:

public slots:

};

#endif // FILEREADER_H
