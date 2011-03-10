using System;
using System.Collections.Generic;
using System.Text;

// Taken from Mono sources, changed to work on C# 2.0 compilers

//
// Enumerable.cs
//
// Authors:
//  Marek Safar (marek.safar@gmail.com)
//  Antonello Provenzano  <antonello@deveel.com>
//  Alejandro Serrano "Serras" (trupill@yahoo.es)
//  Jb Evain (jbevain@novell.com)
//
// Copyright (C) 2007 Novell, Inc (http://www.novell.com)
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

// precious: http://www.hookedonlinq.com

public delegate TResult Func<TResult>();
public delegate TResult Func<T, TResult>(T arg1);
public delegate TResult Func<T1, T2, TResult>(T1 arg1, T2 arg2);
public delegate TResult Func<T1, T2, T3, TResult>(T1 arg1, T2 arg2, T3 arg3);
public delegate TResult Func<T1, T2, T3, T4, TResult>(T1 arg1, T2 arg2, T3 arg3, T4 arg4);


namespace Antlr.Runtime.JavaExtensions {
    static class EnumerableExtensions {

        #region Average

        public static double Average(IEnumerable<int> source) {
            return Average<int, long, double>(source, delegate(long a, int b) { return a + b; }, delegate(long a, long b) { return (double)a / (double)b; });
        }

        static TResult Average<TElement, TAggregate, TResult>(IEnumerable<TElement> source,
            Func<TAggregate, TElement, TAggregate> func, Func<TAggregate, long, TResult> result)
            where TElement : struct
            where TAggregate : struct
            where TResult : struct {
            Check.Source(source);

            var total = default(TAggregate);
            long counter = 0;
            foreach (var element in source) {
                total = func(total, element);
                ++counter;
            }

            if (counter == 0)
                throw new InvalidOperationException();

            return result(total, counter);
        }

        public static double Average(IEnumerable<double> source) {
            return Average<double, double, double>(source, delegate(double a, double b) { return a + b; }, delegate(double a, long b) { return a / b; });
        }

        #endregion

        #region Contains

        public static bool Contains<TSource>(IEnumerable<TSource> source, TSource value) {
            var collection = source as ICollection<TSource>;
            if (collection != null)
                return collection.Contains(value);

            return Contains<TSource>(source, value, null);
        }

        public static bool Contains<TSource>(IEnumerable<TSource> source, TSource value, IEqualityComparer<TSource> comparer) {
            Check.Source(source);

            if (comparer == null)
                comparer = EqualityComparer<TSource>.Default;

            foreach (var element in source)
                if (comparer.Equals(element, value))
                    return true;

            return false;
        }
        #endregion

        #region DefaultIfEmpty

        public static IEnumerable<TSource> DefaultIfEmpty<TSource>(IEnumerable<TSource> source) {
            return DefaultIfEmpty(source, default(TSource));
        }

        public static IEnumerable<TSource> DefaultIfEmpty<TSource>(IEnumerable<TSource> source, TSource defaultValue) {
            Check.Source(source);

            return CreateDefaultIfEmptyIterator(source, defaultValue);
        }

        static IEnumerable<TSource> CreateDefaultIfEmptyIterator<TSource>(IEnumerable<TSource> source, TSource defaultValue) {
            bool empty = true;
            foreach (TSource item in source) {
                empty = false;
                yield return item;
            }

            if (empty)
                yield return defaultValue;
        }

        #endregion

        #region Max

        public static int Max(IEnumerable<int> source) {
            Check.Source(source);

            return Iterate(source, int.MinValue, delegate(int a, int b){return Math.Max(a, b);});
        }

        static U Iterate<T, U>(IEnumerable<T> source, U initValue, Func<T, U, U> selector) {
            bool empty = true;
            foreach (var element in source) {
                initValue = selector(element, initValue);
                empty = false;
            }

            if (empty)
                throw new InvalidOperationException();

            return initValue;
        }

        #endregion

        #region Min

        public static int Min(IEnumerable<int> source) {
            Check.Source(source);

            return Iterate(source, int.MaxValue, delegate(int a, int b) { return Math.Min(a, b); });
        }
        
        #endregion

        #region Select

        public static IEnumerable<TResult> Select<TSource, TResult>(IEnumerable<TSource> source, Func<TSource, TResult> selector) {
            Check.SourceAndSelector(source, selector);

            return CreateSelectIterator(source, selector);
        }

        static IEnumerable<TResult> CreateSelectIterator<TSource, TResult>(IEnumerable<TSource> source, Func<TSource, TResult> selector) {
            foreach (var element in source)
                yield return selector(element);
        }

        public static IEnumerable<TResult> Select<TSource, TResult>(IEnumerable<TSource> source, Func<TSource, int, TResult> selector) {
            Check.SourceAndSelector(source, selector);

            return CreateSelectIterator(source, selector);
        }

        static IEnumerable<TResult> CreateSelectIterator<TSource, TResult>(IEnumerable<TSource> source, Func<TSource, int, TResult> selector) {
            int counter = 0;
            foreach (TSource element in source) {
                yield return selector(element, counter);
                counter++;
            }
        }

        #endregion

        #region SelectMany

        public static IEnumerable<TResult> SelectMany<TSource, TCollection, TResult>(IEnumerable<TSource> source,
            Func<TSource, int, IEnumerable<TCollection>> collectionSelector, Func<TSource, TCollection, TResult> selector) {
            Check.SourceAndCollectionSelectors(source, collectionSelector, selector);

            return CreateSelectManyIterator(source, collectionSelector, selector);
        }

        public static IEnumerable<TResult> SelectMany<TSource, TResult>(IEnumerable<TSource> source, Func<TSource, int, IEnumerable<TResult>> selector) {
            Check.SourceAndSelector(source, selector);

            return CreateSelectManyIterator(source, selector);
        }

        static IEnumerable<TResult> CreateSelectManyIterator<TSource, TCollection, TResult>(IEnumerable<TSource> source,
            Func<TSource, int, IEnumerable<TCollection>> collectionSelector, Func<TSource, TCollection, TResult> selector) {
            int counter = 0;
            foreach (TSource element in source)
                foreach (TCollection collection in collectionSelector(element, counter++))
                    yield return selector(element, collection);
        }

        static IEnumerable<TResult> CreateSelectManyIterator<TSource, TResult>(IEnumerable<TSource> source, Func<TSource, int, IEnumerable<TResult>> selector) {
            int counter = 0;
            foreach (TSource element in source) {
                foreach (TResult item in selector(element, counter))
                    yield return item;
                counter++;
            }
        }

        #endregion

        #region Sum

        public static int Sum(IEnumerable<int> source) {
            Check.Source(source);

            return Sum<int, int>(source, delegate(int a, int b) { return checked(a + b); });
        }

        static TR Sum<TA, TR>(IEnumerable<TA> source, Func<TR, TA, TR> selector) {
            TR total = default(TR);
            foreach (var element in source) {
                total = selector(total, element);
            }

            return total;
        }

        #endregion

        #region Take

        public static IEnumerable<TSource> Take<TSource>(IEnumerable<TSource> source, int count) {
            Check.Source(source);

            return CreateTakeIterator(source, count);
        }

        static IEnumerable<TSource> CreateTakeIterator<TSource>(IEnumerable<TSource> source, int count) {
            if (count <= 0)
                yield break;

            int counter = 0;
            foreach (TSource element in source) {
                yield return element;

                if (++counter == count)
                    yield break;
            }
        }

        #endregion
        
        #region ToArray

        public static TSource[] ToArray<TSource>(IEnumerable<TSource> source) {
            Check.Source(source);

            var collection = source as ICollection<TSource>;
            if (collection != null) {
                var array = new TSource[collection.Count];
                collection.CopyTo(array, 0);
                return array;
            }

            return new List<TSource>(source).ToArray();
        }

        #endregion
    }
}
