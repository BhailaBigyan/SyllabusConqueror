#include <QtTest>
#include <QSignalSpy>
#include "../TopicModel.h"
#include "../SessionModel.h"
#include "../DatabaseManager.h"
#include "../FocusController.h"

class SyllabusTests : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase() {
        // Setup temporary database for testing
        m_db = new DatabaseManager(this);
    }

    void cleanupTestCase() {
        delete m_db;
    }

    void testSessionIsolation() {
        SessionModel sessionModel;
        sessionModel.setDatabaseManager(m_db);
        
        TopicModel topicModel;
        topicModel.setDatabaseManager(m_db);

        // 1. Create three sessions
        sessionModel.addSession("Session 1");
        int id1 = sessionModel.currentSessionId();
        
        sessionModel.addSession("Session 2");
        int id2 = sessionModel.currentSessionId();
        
        sessionModel.addSession("Session 3");
        int id3 = sessionModel.currentSessionId();

        QVERIFY(id1 != id2 && id2 != id3 && id1 != id3);

        // 2. Add topics to Session 1
        topicModel.setSessionId(id1);
        topicModel.addTopic("Topic 1.1", 10);
        topicModel.addTopic("Topic 1.2", 20);
        QCOMPARE(topicModel.rowCount(), 2);

        // 3. Switch to Session 2 and verify it's empty
        topicModel.setSessionId(id2);
        QCOMPARE(topicModel.rowCount(), 0);
        topicModel.addTopic("Topic 2.1", 15);
        QCOMPARE(topicModel.rowCount(), 1);

        // 4. Switch back to Session 1 and verify isolation
        topicModel.setSessionId(id1);
        QCOMPARE(topicModel.rowCount(), 2);
        QCOMPARE(topicModel.data(topicModel.index(0), TopicModel::NameRole).toString(), "Topic 1.1");
    }

    void testTimerExecution() {
        FocusController focusCtrl;
        focusCtrl.setTotalSeconds(2); // 2 second session for testing
        
        QSignalSpy spyFinished(&focusCtrl, &FocusController::sessionFinished);
        QSignalSpy spyRemaining(&focusCtrl, &FocusController::remainingSecondsChanged);

        focusCtrl.startSession();
        QVERIFY(focusCtrl.running());
        
        // Wait for timer to expire (up to 3 seconds)
        QVERIFY(spyFinished.wait(3000));
        
        QCOMPARE(spyFinished.count(), 1);
        QCOMPARE(focusCtrl.remainingSeconds(), 0);
        QVERIFY(!focusCtrl.running());
    }

    void testSessionPersistence() {
        // Create a new session and add a topic
        int sid;
        {
            SessionModel sm;
            sm.setDatabaseManager(m_db);
            sm.addSession("Persistent Session");
            sid = sm.currentSessionId();
            
            TopicModel tm;
            tm.setDatabaseManager(m_db);
            tm.setSessionId(sid);
            tm.addTopic("Persistent Topic", 50);
        }

        // Re-open and verify
        SessionModel sm2;
        sm2.setDatabaseManager(m_db);
        TopicModel tm2;
        tm2.setDatabaseManager(m_db);
        tm2.setSessionId(sid);
        
        QCOMPARE(tm2.rowCount(), 1);
        QCOMPARE(tm2.data(tm2.index(0), TopicModel::NameRole).toString(), "Persistent Topic");
        QCOMPARE(tm2.data(tm2.index(0), TopicModel::MarksRole).toInt(), 50);
    }

private:
    DatabaseManager* m_db;
};

QTEST_MAIN(SyllabusTests)
#include "SyllabusTests.moc"
