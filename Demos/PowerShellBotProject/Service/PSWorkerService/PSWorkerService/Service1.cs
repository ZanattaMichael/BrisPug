using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Timers;

namespace PSWorkerService
{
    public partial class Service1 : ServiceBase
    {

        // Define the URL Parameters
        public static string URLRequestJob = System.Configuration.ConfigurationManager.AppSettings["URLPull"];
        public static string URLSendJob = System.Configuration.ConfigurationManager.AppSettings["URLPush"];

 
        public Service1()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            // Create a Timer with a 5 Minute Interval
            var timer = new System.Timers.Timer(300000);

            // Register the Event
            timer.Elapsed += new ElapsedEventHandler(TimedEvent);

            // 
            timer.Enabled = true;

            // Keep the Timer Alive to Prevent Garbage Collection from Picking it up
            GC.KeepAlive(timer);
        }

        protected override void OnStop()
        {
        }

        private static void TimedEvent(object source, ElapsedEventArgs e)
        {
            Classes.Job.Process();
        }
    }
}
