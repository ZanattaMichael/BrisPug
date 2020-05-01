using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections;
using System.Reflection;
using System.ComponentModel;

namespace ConfigurationBuilder
{
    public static class ObjectToHashtableHelper
    {
        
        public static Hashtable[] ToHashtableList(this object source)
        {

            List<Hashtable> hashtables = new List<Hashtable>();

            IEnumerable enumerable = source as IEnumerable;
            if (enumerable != null)
            {
                foreach (object element in enumerable)
                    hashtables.Add(ToHashtable(element));
            }

            return hashtables.ToArray();

        }
        
        public static Hashtable ToHashtable(this object source)
        {
            return source.ToHashtable<object>();
        }

        public static Hashtable ToHashtable<T>(this object source)
        {
            if (source == null)
                ThrowExceptionWhenSourceArgumentIsNull();

            var hashTable = (Hashtable)Convert.ChangeType(source, typeof(Hashtable));

            return hashTable;
        }

        private static bool IsOfType<T>(object value)
        {
            return value is T;
        }

        private static void ThrowExceptionWhenSourceArgumentIsNull()
        {
            throw new ArgumentNullException("source", "Unable to convert object to a hashtable. The source object is null.");
        }
    }
}
