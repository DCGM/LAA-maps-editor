/**************************************************************************
 *   Butaca
 *   Copyright (C) 2011 - 2012 Simon Pena <spena@igalia.com>
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 **************************************************************************/

#ifndef IMAGESAVER_H
#define IMAGESAVER_H

#include <QObject>
#include <QQuickItem>
#include <QQuickPaintedItem>

class ImageSaver : public QObject {
  Q_OBJECT

public:
  explicit ImageSaver(QObject *parent = 0);
  // QQuickItem
  Q_INVOKABLE void save(QQuickItem *item, const QUrl &filename);
  //    Q_INVOKABLE void save(QString item, QString filename);
};

#endif // IMAGESAVER_H
