using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Timers;

namespace PSWorkerService
{
    public partial class Service1 : ServiceBase
    {
        public static bool flag = false;
        // Define the URL Parameters
        public static string URLRequestJob = System.Configuration.ConfigurationManager.AppSettings["URLPull"];
        public static string URLSendJob = System.Configuration.ConfigurationManager.AppSettings["URLPush"];
        public static int WaitTimer = int.Parse(System.Configuration.ConfigurationManager.AppSettings["ServiceTimer"]);

        public Service1()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            // Create a Timer with a 5 Minute Interval
            var timer = new System.Timers.Timer(WaitTimer);

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

            // Wait for the Debugger to be attached
            //while (!Debugger.IsAttached)
            //{
            //    Thread.Sleep(1000);
            //}

            // Execute one. REMOVE ME!
            //if (Service1.flag == false)
            //{
            //    Service1.flag = true;
                Classes.Job.Process();
                
            //}
            
        }
    }
}
