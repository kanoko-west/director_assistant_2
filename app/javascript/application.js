// 既存のインポート
import "@hotwired/turbo-rails"
import "controllers"

window.generateReport = function() {
  const archiveList = document.getElementById('archive-list');
  const tasksContainer = document.getElementById('tasks_container');
  const reportOutput = document.getElementById('report-output');

  if (!reportOutput) return;

  // 1. 完了済みリストからテキストを取得
  const archivedElements = archiveList ? archiveList.querySelectorAll('.archive-item-title') : [];
  const archivedTasks = Array.from(archivedElements).map(el => el.innerText.trim());

  // 2. 実行中リストからテキストを取得
  const todayElements = tasksContainer ? tasksContainer.querySelectorAll('.task-title, .task-title-cell') : [];
  const todayTasks = Array.from(todayElements).map(el => el.innerText.trim());

  const now = new Date();
  const dateStr = `${now.getMonth() + 1}/${now.getDate()}`;
  let reportText = "";

  // 3. 現在のURLで「朝」か「夕方」を判定
  const isMorningPage = window.location.pathname.includes('morning');

  if (isMorningPage) {
    // 【朝の3分ビュー用】昨日完了 + 本日の予定
    reportText = `【朝礼報告】${dateStr}\n\n`;
    reportText += "▼昨日の完了事項\n";
    reportText += archivedTasks.length ? archivedTasks.map(t => `・${t}\n`).join('') : "・(特になし)\n";
    reportText += "\n▼本日の注力事項\n";
    reportText += todayTasks.length ? todayTasks.map(t => `・${t}\n`).join('') : "・(未定)\n";
  } else {
    // 【メイン画面(index)用】本日完了分のみ
    reportText = `【日報報告】${dateStr}\n\n`;
    reportText += "▼本日の完了事項\n";
    reportText += archivedTasks.length ? archivedTasks.map(t => `・${t}\n`).join('') : "・(完了タスクなし)\n";
  }

  reportText += "\n以上、よろしくお願いいたします。";
  reportOutput.innerText = reportText;
};

