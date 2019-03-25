using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Windows.Forms;

namespace startad
{
    public partial class Form1 : Form
    {
        int CenterX = 570;// Центр координат по X
        int CenterY = 420;// Центр координат по Y
        int WindowSize = 800;// Ширина и высота окна вывода 
        double CenterAlfa;
        double CenterBeta;
        int NumData = 0;// Количество данных
        int[,] a = new int[50000, 2];// Координаты X Y для вывода данных
        int [,]aTemp = new int[50000, 2];// Координаты X Y для вывода данных (предыдущее положение)
        double[,] DataPolar = new double[50000, 3];// Данные в полярных координатах
        double[,] DataXYZ = new double[50000, 3];// Данные в координатах XYZ

        int NumNeur = 0;
        int[,] n = new int[500, 2];// Координаты X Y для вывода нейронов
        int[,] nTemp = new int[500, 2];// Координаты X Y для вывода нейронов (предыдущее положение)
        double[,] NeurPolar = new double[500, 3];
        double[,] NeurXYZ = new double[500, 3];
        int[,] Nodes = new int[500, 500];
        int[] Numbers = new int[500];

        int NumGal = 0;// Количество данных входящих в уплотнения
        int[,] d = new int[50000, 2];// Координаты X Y для вывода данных входящих в уплотнения
        int[,] dTemp = new int[50000, 2];// Координаты X Y для вывода данных входящих в уплотнения (предыдущее положение)
        double[,] GalPolar = new double[50000, 3];// Данные входящих в уплотнения в полярных координатах
        double[,] GalXYZ = new double[50000, 3];// Данные входящих в уплотнения в координатах XYZ

        public Form1()
        {
            InitializeComponent();
        }

        private void GetMashtab()
        {
            double Mash=1;
            double MaxDisp = 0;
            double[] MinXYZ = new double[3];
            double[] MaxXYZ = new double[3];
            for (int i=0;i<3;i++)
            {
                MinXYZ[i] = DataXYZ[0, i];
                MaxXYZ[i] = DataXYZ[0, i];
            }
            for (int i = 0; i < NumData; i++)
            {
                for (int j = 0; j < 3; j++)
                {
                    if (MinXYZ[j] > DataXYZ[i, j]) MinXYZ[j] = DataXYZ[i, j];
                    if (MaxXYZ[j] < DataXYZ[i, j]) MaxXYZ[j] = DataXYZ[i, j];
                }
            }
            double MaxDispX = MaxXYZ[0] - MinXYZ[0];
            double MaxDispY = MaxXYZ[1] - MinXYZ[1];
            double MaxDispZ = MaxXYZ[2] - MinXYZ[2];
            if ((MaxDispX >= MaxDispY) && (MaxDispX >= MaxDispZ)) MaxDisp = MaxDispX;
            if ((MaxDispY >= MaxDispX) && (MaxDispY >= MaxDispZ)) MaxDisp = MaxDispY;
            if ((MaxDispZ >= MaxDispX) && (MaxDispZ >= MaxDispY)) MaxDisp = MaxDispZ;
            Mash = 1.00*WindowSize /  MaxDisp;
            for (int i = 0; i < NumData; i++)
            {
                for (int j = 0; j < 3; j++)
                {
                    DataXYZ[i, j] -=  (MaxXYZ[j] + MinXYZ[j])  / 2;
                    DataXYZ[i, j] *= Mash;
                }
            }
            for (int i = 0; i < NumNeur; i++)
            {
                for (int j = 0; j < 3; j++)
                {
                    NeurXYZ[i, j] -= (MaxXYZ[j] + MinXYZ[j]) / 2;
                    NeurXYZ[i, j] *= Mash;
                }
            }
            for (int i = 0; i < NumGal; i++)
            {
                for (int j = 0; j < 3; j++)
                {
                    GalXYZ[i, j] -= (MaxXYZ[j] + MinXYZ[j]) / 2;
                    GalXYZ[i, j] *= Mash;
                }
            }

        }
        private void ReadData()
        {
            FileStream file = new FileStream("C:\\DrawGal\\0_03_1sh.txt", FileMode.Open); 
            StreamReader reader = new StreamReader(file);
            string s = reader.ReadLine();
            NumData = int.Parse(s);
            for (int i = 0; i < NumData; i++)
            {
                for (int j = 0; j < 3; j++)
                {
                    string ss = reader.ReadLine();
                    int sign = 1;
                    if (ss[0] == '-')
                    {
                        sign = -1;
                        ss = ss.Remove(0, 1);
                    }
                    ss=ss.Replace(".", ",");
                    DataXYZ[i, j] = double.Parse(ss) * sign;
                }
            }
            reader.Close();
        }
        private void ReadNeur()
        {
            FileStream file = new FileStream("C:\\DrawGal\\0_03_1Ash.txt", FileMode.Open);
            StreamReader reader = new StreamReader(file);
            string s = reader.ReadLine();
            NumNeur = int.Parse(s);
            for (int i = 0; i < 500; i++)
            {
                for (int j = 0; j < 500; j++)
                {
                    Nodes[i, j] = -1;
                }
            }
            for (int i = 0; i < NumNeur; i++)
            {
                s = reader.ReadLine();
                Numbers[i]= int.Parse(s);
                for (int j = 0; j < 3; j++)
                {
                    string ss = reader.ReadLine();
                    int sign = 1;
                    if (ss[0] == '-')
                    {
                        sign = -1;
                        ss = ss.Remove(0, 1);
                    }
                    ss = ss.Replace(".", ",");
                    NeurXYZ[i, j] = double.Parse(ss) * sign;
                }
                s = reader.ReadLine();
                int Count = int.Parse(s);
                for (int j = 0; j < Count; j++)
                {
                    s = reader.ReadLine();
                    int TempVar1= int.Parse(s);
                    Nodes[Numbers[i], TempVar1] = 0;
                }
            }
            reader.Close();
        }
        private void ReadGal()
        {
            FileStream file = new FileStream("C:\\DrawGal\\0_03_1Gsh.txt", FileMode.Open);
            StreamReader reader = new StreamReader(file);
            string s = reader.ReadLine();
            int NumClust = int.Parse(s);
            NumGal = 0;
            for (int i = 0; i < NumClust; i++)
            {
                s = reader.ReadLine();
                int NumGalInClust = int.Parse(s);
                for (int k = 0; k < NumGalInClust; k++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        string ss = reader.ReadLine();
                        int sign = 1;
                        if (ss[0] == '-')
                        {
                            sign = -1;
                            ss = ss.Remove(0, 1);
                        }
                        ss = ss.Replace(".", ",");
                        GalXYZ[NumGal, j] = double.Parse(ss) * sign;
                    }
                    NumGal++;
                }
            }
            NumGal--;
            reader.Close();
        }
        private void DataPolarToXYZ()
        {
            for (int i = 0; i < NumData; i++)
            {
                DataXYZ[i, 0] = DataPolar[i, 2] * Math.Cos(DataPolar[i, 1] / 180 * Math.PI) * Math.Cos(DataPolar[i, 0] / 180 * Math.PI);
                DataXYZ[i, 1] = DataPolar[i, 2] * Math.Cos(DataPolar[i, 1] / 180 * Math.PI) * Math.Sin(DataPolar[i, 0] / 180 * Math.PI);
                DataXYZ[i, 2] = DataPolar[i, 2] * Math.Sin(DataPolar[i, 1] / 180 * Math.PI);
            }
        }
        private void NeurPolarToXYZ()
        {
            for (int i = 0; i < NumNeur; i++)
            {
                NeurXYZ[i, 0] = NeurPolar[i, 2] * Math.Cos(NeurPolar[i, 1] / 180 * Math.PI) * Math.Cos(NeurPolar[i, 0] / 180 * Math.PI);
                NeurXYZ[i, 1] = NeurPolar[i, 2] * Math.Cos(NeurPolar[i, 1] / 180 * Math.PI) * Math.Sin(NeurPolar[i, 0] / 180 * Math.PI);
                NeurXYZ[i, 2] = NeurPolar[i, 2] * Math.Sin(NeurPolar[i, 1] / 180 * Math.PI);
            }
        }
        private void GalPolarToXYZ()
        {
            for (int i = 0; i < NumGal; i++)
            {
                GalXYZ[i, 0] = GalPolar[i, 2] * Math.Cos(GalPolar[i, 1] / 180 * Math.PI) * Math.Cos(GalPolar[i, 0] / 180 * Math.PI);
                GalXYZ[i, 1] = GalPolar[i, 2] * Math.Cos(GalPolar[i, 1] / 180 * Math.PI) * Math.Sin(GalPolar[i, 0] / 180 * Math.PI);
                GalXYZ[i, 2] = GalPolar[i, 2] * Math.Sin(GalPolar[i, 1] / 180 * Math.PI);
            }
        }
        private void DataXYZToPolar()
        {
            for (int i = 0; i < NumData; i++)
            {
                double TempVar = 0;
                DataPolar[i, 2] = Math.Sqrt(DataXYZ[i, 0] * DataXYZ[i, 0] + DataXYZ[i, 1] * DataXYZ[i, 1] + DataXYZ[i, 2] * DataXYZ[i, 2]);
                DataPolar[i, 0] = 0;
                DataPolar[i, 1] = 0;
                if (DataPolar[i, 2] > 0)
                {
                    DataPolar[i, 1] = Math.Asin(DataXYZ[i, 2] / DataPolar[i, 2]) * 180 / Math.PI;
                    TempVar = Math.Asin(DataXYZ[i, 1] / Math.Sqrt(DataXYZ[i, 0] * DataXYZ[i, 0] + DataXYZ[i, 1] * DataXYZ[i, 1]));
                }
                if ((DataXYZ[i, 0] > 0) && (DataXYZ[i, 1] >= 0))
                {
                    DataPolar[i, 0] = TempVar * 180 / Math.PI;
                }
                else if ((DataXYZ[i, 0] > 0) && (DataXYZ[i, 1] < 0))
                {
                    DataPolar[i, 0] = (TempVar + 2 * Math.PI) * 180 / Math.PI;
                }
                else
                {
                    DataPolar[i, 0] = (Math.PI - TempVar) * 180 / Math.PI;
                }
            }
        }
        private void NeurXYZToPolar()
        {
            for (int i = 0; i < NumNeur; i++)
            {
                double TempVar = 0;
                NeurPolar[i, 2] = Math.Sqrt(NeurXYZ[i, 0] * NeurXYZ[i, 0] + NeurXYZ[i, 1] * NeurXYZ[i, 1] + NeurXYZ[i, 2] * NeurXYZ[i, 2]);
                NeurPolar[i, 0] = 0;
                NeurPolar[i, 1] = 0;
                if (NeurPolar[i, 2] > 0)
                {
                    NeurPolar[i, 1] = Math.Asin(NeurXYZ[i, 2] / NeurPolar[i, 2]) * 180 / Math.PI;
                    TempVar = Math.Asin(NeurXYZ[i, 1] / Math.Sqrt(NeurXYZ[i, 0] * NeurXYZ[i, 0] + NeurXYZ[i, 1] * NeurXYZ[i, 1]));
                }
                if ((NeurXYZ[i, 0] > 0) && (NeurXYZ[i, 1] >= 0))
                {
                    NeurPolar[i, 0] = TempVar * 180 / Math.PI;
                }
                else if ((NeurXYZ[i, 0] > 0) && (NeurXYZ[i, 1] < 0))
                {
                    NeurPolar[i, 0] = (TempVar + 2 * Math.PI) * 180 / Math.PI;
                }
                else
                {
                    NeurPolar[i, 0] = (Math.PI - TempVar) * 180 / Math.PI;
                }
            }
        }
        private void GalXYZToPolar()
        {
            for (int i = 0; i < NumGal; i++)
            {
                double TempVar = 0;
                GalPolar[i, 2] = Math.Sqrt(GalXYZ[i, 0] * GalXYZ[i, 0] + GalXYZ[i, 1] * GalXYZ[i, 1] + GalXYZ[i, 2] * GalXYZ[i, 2]);
                GalPolar[i, 0] = 0;
                GalPolar[i, 1] = 0;
                if (GalPolar[i, 2] > 0)
                {
                    GalPolar[i, 1] = Math.Asin(GalXYZ[i, 2] / GalPolar[i, 2]) * 180 / Math.PI;
                    TempVar = Math.Asin(GalXYZ[i, 1] / Math.Sqrt(GalXYZ[i, 0] * GalXYZ[i, 0] + GalXYZ[i, 1] * GalXYZ[i, 1]));
                }
                if ((GalXYZ[i, 0] > 0) && (GalXYZ[i, 1] >= 0))
                {
                    GalPolar[i, 0] = TempVar * 180 / Math.PI;
                }
                else if ((GalXYZ[i, 0] > 0) && (GalXYZ[i, 1] < 0))
                {
                    GalPolar[i, 0] = (TempVar + 2 * Math.PI) * 180 / Math.PI;
                }
                else
                {
                    GalPolar[i, 0] = (Math.PI - TempVar) * 180 / Math.PI;
                }
            }
        }
        private void TurnDataAroundXOneDegree()
        {
            for (int i = 0; i < NumData; i++)
            {
                double AA = Math.Sqrt(DataXYZ[i, 1] * DataXYZ[i, 1] + DataXYZ[i, 2] * DataXYZ[i, 2]);
                double TempVar = 0;
                double ConerZ = 0;
                if (AA > 0)
                {
                    TempVar = Math.Asin(DataXYZ[i, 1] / AA);
                }
                if ((DataXYZ[i, 2] > 0) && (DataXYZ[i, 1] >= 0))
                {
                    ConerZ = TempVar * 180 / Math.PI;
                }
                else if ((DataXYZ[i, 2] > 0) && (DataXYZ[i, 1] < 0))
                {
                    ConerZ = (TempVar + 2 * Math.PI) * 180 / Math.PI;
                }
                else
                {
                    ConerZ = (Math.PI - TempVar) * 180 / Math.PI;
                }
                ConerZ += 1;
                if (ConerZ > 360)
                {
                    ConerZ -= 360;
                }
                DataXYZ[i, 2] = Math.Cos(ConerZ / 180 * Math.PI) * AA;
                DataXYZ[i, 1] = Math.Sin(ConerZ / 180 * Math.PI) * AA;
            }
        }
        private void TurnNeurAroundXOneDegree()
        {
            for (int i = 0; i < NumNeur; i++)
            {
                double AA = Math.Sqrt(NeurXYZ[i, 1] * NeurXYZ[i, 1] + NeurXYZ[i, 2] * NeurXYZ[i, 2]);
                double TempVar = 0;
                double ConerZ = 0;
                if (AA > 0)
                {
                    TempVar = Math.Asin(NeurXYZ[i, 1] / AA);
                }
                if ((NeurXYZ[i, 2] > 0) && (NeurXYZ[i, 1] >= 0))
                {
                    ConerZ = TempVar * 180 / Math.PI;
                }
                else if ((NeurXYZ[i, 2] > 0) && (NeurXYZ[i, 1] < 0))
                {
                    ConerZ = (TempVar + 2 * Math.PI) * 180 / Math.PI;
                }
                else
                {
                    ConerZ = (Math.PI - TempVar) * 180 / Math.PI;
                }
                ConerZ += 1;
                if (ConerZ > 360)
                {
                    ConerZ -= 360;
                }
                NeurXYZ[i, 2] = Math.Cos(ConerZ / 180 * Math.PI) * AA;
                NeurXYZ[i, 1] = Math.Sin(ConerZ / 180 * Math.PI) * AA;
            }
        }
        private void TurnGalAroundXOneDegree()
        {
            for (int i = 0; i < NumGal; i++)
            {
                double AA = Math.Sqrt(GalXYZ[i, 1] * GalXYZ[i, 1] + GalXYZ[i, 2] * GalXYZ[i, 2]);
                double TempVar = 0;
                double ConerZ = 0;
                if (AA > 0)
                {
                    TempVar = Math.Asin(GalXYZ[i, 1] / AA);
                }
                if ((GalXYZ[i, 2] > 0) && (GalXYZ[i, 1] >= 0))
                {
                    ConerZ = TempVar * 180 / Math.PI;
                }
                else if ((GalXYZ[i, 2] > 0) && (GalXYZ[i, 1] < 0))
                {
                    ConerZ = (TempVar + 2 * Math.PI) * 180 / Math.PI;
                }
                else
                {
                    ConerZ = (Math.PI - TempVar) * 180 / Math.PI;
                }
                ConerZ += 1;
                if (ConerZ > 360)
                {
                    ConerZ -= 360;
                }
                GalXYZ[i, 2] = Math.Cos(ConerZ / 180 * Math.PI) * AA;
                GalXYZ[i, 1] = Math.Sin(ConerZ / 180 * Math.PI) * AA;
            }
        }
        private void TurnDataAroundZOneDegree()
        {
            for (int i = 0; i < NumData; i++)
            {
                DataPolar[i, 0] += 1;
                if (DataPolar[i, 0] > 360)
                {
                    DataPolar[i, 0] -= 360;
                }
            }

        }
        private void TurnNeurAroundZOneDegree()
        {
            for (int i = 0; i < NumNeur; i++)
            {
                NeurPolar[i, 0] += 1;
                if (NeurPolar[i, 0] > 360)
                {
                    NeurPolar[i, 0] -= 360;
                }
            }

        }
        private void TurnGalAroundZOneDegree()
        {
            for (int i = 0; i < NumGal; i++)
            {
                GalPolar[i, 0] += 1;
                if (GalPolar[i, 0] > 360)
                {
                    GalPolar[i, 0] -= 360;
                }
            }

        }
        private void SetDataScreenPositions()
        {
            for (int i = 0; i < NumData; i++)
            {
                a[i, 0] = CenterX + Convert.ToInt32(DataXYZ[i, 0]);
                a[i, 1] = CenterY - Convert.ToInt32(DataXYZ[i, 1]);
            }
        }
        private void SetNeurScreenPositions()
        {
            for (int i = 0; i < NumNeur; i++)
            {
                n[i, 0] = CenterX + Convert.ToInt32(NeurXYZ[i, 0]);
                n[i, 1] = CenterY - Convert.ToInt32(NeurXYZ[i, 1]);
            }
        }
        private void SetGalScreenPositions()
        {
            for (int i = 0; i < NumGal; i++)
            {
                d[i, 0] = CenterX + Convert.ToInt32(GalXYZ[i, 0]);
                d[i, 1] = CenterY - Convert.ToInt32(GalXYZ[i, 1]);
            }
        }
        private void SaveDataScreenPositions()
        {
            for (int i = 0; i < NumData; i++)
            {
                aTemp[i, 0] = a[i, 0];
                aTemp[i, 1] = a[i, 1];
            }
        }
        private void SaveNeurScreenPositions()
        {
            for (int i = 0; i < NumNeur; i++)
            {
                nTemp[i, 0] = n[i, 0];
                nTemp[i, 1] = n[i, 1];
            }
        }
        private void SaveGalScreenPositions()
        {
            for (int i = 0; i < NumGal; i++)
            {
                dTemp[i, 0] = d[i, 0];
                dTemp[i, 1] = d[i, 1];
            }
        }
        private double GetCenterAlfa()
        {
            double MinA = DataPolar[0, 0];
            double MaxA = DataPolar[0, 0];
            for (int i = 0; i < NumData; i++)
            {
                if (MinA > DataPolar[i, 0]) MinA = DataPolar[i, 0];
                if (MaxA < DataPolar[i, 0]) MaxA = DataPolar[i, 0];
            }
            double CenterA = (MinA + MaxA) / 2;
            return CenterA;
        }
        private void TurnDataAroundZForCentring()
        {
            double CenterA = CenterAlfa;
            for (int i = 0; i < NumData; i++)
            {
                DataPolar[i, 0] += (360-CenterA);
                if (DataPolar[i, 0] > 360)
                {
                    DataPolar[i, 0] -= 360;
                }
            }
            DataPolarToXYZ();
        }
        private void TurnNeurAroundZForCentring()
        {
            double CenterA = CenterAlfa;
            for (int i = 0; i < NumNeur; i++)
            {
                NeurPolar[i, 0] += (360 - CenterA);
                if (NeurPolar[i, 0] > 360)
                {
                    NeurPolar[i, 0] -= 360;
                }
            }
            NeurPolarToXYZ();
        }
        private void TurnGalAroundZForCentring()
        {
            double CenterA = CenterAlfa;
            for (int i = 0; i < NumGal; i++)
            {
                GalPolar[i, 0] += (360 - CenterA);
                if (GalPolar[i, 0] > 360)
                {
                    GalPolar[i, 0] -= 360;
                }
            }
            GalPolarToXYZ();
        }
        private double GetCenterBeta()
        {
            double MinB = DataPolar[0, 1];
            double MaxB = DataPolar[0, 1];
            for (int i = 0; i < NumData; i++)
            {
                if (MinB > DataPolar[i, 1]) MinB = DataPolar[i, 1];
                if (MaxB < DataPolar[i, 1]) MaxB = DataPolar[i, 1];
            }
            double CenterB = (MinB + MaxB) / 2;
            return CenterB;
        }
        private void TurnDataAroundYForCentring()
        {
            double CenterB = CenterBeta;
            for (int i = 0; i < NumData; i++)
            {
                DataPolar[i, 1] -= CenterB;
            }
            DataPolarToXYZ();
        }
        private void TurnNeurAroundYForCentring()
        {
            double CenterB = CenterBeta;
            for (int i = 0; i < NumNeur; i++)
            {
                NeurPolar[i, 1] -= CenterB;
            }
            NeurPolarToXYZ();
        }
        private void TurnGalAroundYForCentring()
        {
            double CenterB = CenterBeta;
            for (int i = 0; i < NumGal; i++)
            {
                GalPolar[i, 1] -= CenterB;
            }
            GalPolarToXYZ();
        }
        private void button1_Click(object sender, EventArgs e)
        {
            // Turn around X one degree
            Graphics g = panel1.CreateGraphics();
            Pen pen1 = new Pen(Color.WhiteSmoke, 1);
            Pen pen2 = new Pen(Color.Black, 1);
            Pen pen4 = new Pen(Color.DeepSkyBlue, 1);
            //SaveDataScreenPositions();
            TurnDataAroundXOneDegree();
            SetDataScreenPositions();
            for (int i = 0; i < NumData; i++)
            {
                    g.DrawEllipse(pen2, aTemp[i, 0], aTemp[i, 1], 1, 1);
                    g.DrawEllipse(pen1, a[i, 0], a[i, 1], 1, 1);
            }
            SaveDataScreenPositions();
            DataXYZToPolar();

            Pen pen3 = new Pen(Color.Red, 1);
            //SaveNeurScreenPositions();
            TurnNeurAroundXOneDegree();
            SetNeurScreenPositions();
            for (int i = 0; i < NumNeur; i++)
            {
                g.DrawEllipse(pen2, nTemp[i, 0], nTemp[i, 1], 2,2);
                g.DrawEllipse(pen3, n[i, 0], n[i, 1], 2, 2);
            }
            SaveNeurScreenPositions();
            NeurXYZToPolar();

            //SaveGalScreenPositions();
            TurnGalAroundXOneDegree();
            SetGalScreenPositions();
            for (int i = 0; i < NumGal; i++)
            {
                g.DrawEllipse(pen2, dTemp[i, 0], dTemp[i, 1], 1, 1);
                g.DrawEllipse(pen4, d[i, 0], d[i, 1], 1, 1);
            }
            SaveGalScreenPositions();
            GalXYZToPolar();

            //for (int i = 0; i < NumNeur; i++)
            //{
            //    for (int j = 0; j < NumNeur; j++)
            //    {
            //        if (Nodes[Numbers[i],Numbers[j]]==0) g.DrawLine(pen3, n[i, 0], n[i, 1], n[j,0], n[j,1]);
            //    }
            //}
        }

        private void button2_Click(object sender, EventArgs e)
        {
            // Turn around Z one degree
            Graphics g = panel1.CreateGraphics();
            Pen pen1 = new Pen(Color.WhiteSmoke, 1);
            Pen pen2 = new Pen(Color.Black, 1);
            Pen pen4 = new Pen(Color.DeepSkyBlue, 1);
            //SaveDataScreenPositions();
            TurnDataAroundZOneDegree();
            DataPolarToXYZ();
            SetDataScreenPositions();
            for (int i = 0; i < NumData; i++)
            {
                g.DrawEllipse(pen2, aTemp[i, 0], aTemp[i, 1], 1, 1);
                g.DrawEllipse(pen1, a[i, 0], a[i, 1], 1, 1);
            }
            SaveDataScreenPositions();

            Pen pen3 = new Pen(Color.Red, 1);
            //SaveNeurScreenPositions();
            TurnNeurAroundZOneDegree();
            NeurPolarToXYZ();
            SetNeurScreenPositions();
            for (int i = 0; i < NumNeur; i++)
            {
                g.DrawEllipse(pen2, nTemp[i, 0], nTemp[i, 1], 2, 2);
                g.DrawEllipse(pen3, n[i, 0], n[i, 1], 2, 2);
            }
            SaveNeurScreenPositions();
            //for (int i = 0; i < NumNeur; i++)
            //{
            //    for (int j = 0; j < NumNeur; j++)
            //    {
            //        if (Nodes[Numbers[i], Numbers[j]] == 0) g.DrawLine(pen3, n[i, 0], n[i, 1], n[j, 0], n[j, 1]);
            //    }
            //}

            TurnGalAroundZOneDegree();
            GalPolarToXYZ();
            SetGalScreenPositions();
            for (int i = 0; i < NumGal; i++)
            {
                g.DrawEllipse(pen2, dTemp[i, 0], dTemp[i, 1], 1, 1);
                g.DrawEllipse(pen4, d[i, 0], d[i, 1], 1, 1);
            }
            SaveGalScreenPositions();

        }
        private void panel1_Paint(object sender, PaintEventArgs e)
        {

        }
        private void button3_Click(object sender, EventArgs e)
        {
            // Turn around Z on 25 degrees
            int ConerTurnAroundZ = 25;
            Graphics g = panel1.CreateGraphics();
            Pen pen1 = new Pen(Color.WhiteSmoke, 1);
            Pen pen2 = new Pen(Color.Black, 1);
            Pen pen3 = new Pen(Color.Red, 1);
            Pen pen4 = new Pen(Color.DeepSkyBlue, 1);
            //SaveDataScreenPositions();
            for (int k=0;k<ConerTurnAroundZ;k++)
            {
                TurnDataAroundZOneDegree();
                DataPolarToXYZ();
                SetDataScreenPositions();
                for (int i = 0; i < NumData; i++)
                {
                    g.DrawEllipse(pen2, aTemp[i, 0], aTemp[i, 1], 1, 1);
                    g.DrawEllipse(pen1, a[i, 0], a[i, 1], 1, 1);
                }
                SaveDataScreenPositions();

                TurnNeurAroundZOneDegree();
                NeurPolarToXYZ();
                SetNeurScreenPositions();
                for (int i = 0; i < NumNeur; i++)
                {
                    g.DrawEllipse(pen2, nTemp[i, 0], nTemp[i, 1], 2, 2);
                    g.DrawEllipse(pen3, n[i, 0], n[i, 1], 2, 2);
                }
                SaveNeurScreenPositions();
                //for (int i = 0; i < NumNeur; i++)
                //{
                //    for (int j = 0; j < NumNeur; j++)
                //    {
                //        if (Nodes[Numbers[i], Numbers[j]] == 0) g.DrawLine(pen3, n[i, 0], n[i, 1], n[j, 0], n[j, 1]);
                //    }
                //}

                TurnGalAroundZOneDegree();
                GalPolarToXYZ();
                SetGalScreenPositions();
                for (int i = 0; i < NumGal; i++)
                {
                    g.DrawEllipse(pen2, dTemp[i, 0], dTemp[i, 1], 1, 1);
                    g.DrawEllipse(pen4, d[i, 0], d[i, 1], 1, 1);
                }
                SaveGalScreenPositions();

            }
        }

        private void button4_Click(object sender, EventArgs e)
        {
            // Turn around X on 25 degrees
            Graphics g = panel1.CreateGraphics();
            int ConerTurnAroundX = 25;
            Pen pen1 = new Pen(Color.WhiteSmoke, 1);
            Pen pen2 = new Pen(Color.Black, 1);
            Pen pen3 = new Pen(Color.Red, 1);
            Pen pen4 = new Pen(Color.DeepSkyBlue, 1);
            //SaveDataScreenPositions();
            for (int k=0;k<ConerTurnAroundX;k++)
            {
                TurnDataAroundXOneDegree();
                SetDataScreenPositions();
                for (int i = 0; i < NumData; i++)
                {
                    g.DrawEllipse(pen2, aTemp[i, 0], aTemp[i, 1], 1, 1);
                    g.DrawEllipse(pen1, a[i, 0], a[i, 1], 1, 1);
                }
                SaveDataScreenPositions();

                TurnNeurAroundXOneDegree();
                SetNeurScreenPositions();
                for (int i = 0; i < NumNeur; i++)
                {
                    g.DrawEllipse(pen2, nTemp[i, 0], nTemp[i, 1], 2, 2);
                    g.DrawEllipse(pen3, n[i, 0], n[i, 1], 2, 2);
                }
                SaveNeurScreenPositions();
                //for (int i = 0; i < NumNeur; i++)
                //{
                //    for (int j = 0; j < NumNeur; j++)
                //    {
                //        if (Nodes[Numbers[i], Numbers[j]] == 0) g.DrawLine(pen3, n[i, 0], n[i, 1], n[j, 0], n[j, 1]);
                //    }
                //}

                TurnGalAroundXOneDegree();
                SetGalScreenPositions();
                for (int i = 0; i < NumGal; i++)
                {
                    g.DrawEllipse(pen2, dTemp[i, 0], dTemp[i, 1], 1, 1);
                    g.DrawEllipse(pen4, d[i, 0], d[i, 1], 1, 1);
                }
                SaveGalScreenPositions();

            }
            DataXYZToPolar();
            NeurXYZToPolar();
            GalXYZToPolar();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            ReadData();
            ReadNeur();
            ReadGal();
            DataXYZToPolar();
            NeurXYZToPolar();
            GalXYZToPolar();
            CenterAlfa = GetCenterAlfa();
            TurnDataAroundZForCentring();
            TurnNeurAroundZForCentring();
            TurnGalAroundZForCentring();
            CenterBeta = GetCenterBeta();
            TurnDataAroundYForCentring();
            TurnNeurAroundYForCentring();
            TurnGalAroundYForCentring();
            GetMashtab();
            DataXYZToPolar();
            NeurXYZToPolar();
            GalXYZToPolar();
            Graphics g = panel1.CreateGraphics();
            g.Clear(Color.Black);
            Pen pen1 = new Pen(Color.WhiteSmoke, 1);
            SetDataScreenPositions();
            for (int i = 0; i < NumData; i++)
            {
                g.DrawEllipse(pen1, a[i, 0], a[i, 1], 1, 1);
            }
            SaveDataScreenPositions();

            Pen pen3 = new Pen(Color.Red, 1);
            SetNeurScreenPositions();
            for (int i = 0; i < NumNeur; i++)
            {
                g.DrawEllipse(pen3, n[i, 0], n[i, 1], 2, 2);
            }
            SaveNeurScreenPositions();
            //for (int i = 0; i < NumNeur; i++)
            //{
            //    for (int j = 0; j < NumNeur; j++)
            //    {
            //        if (Nodes[Numbers[i], Numbers[j]] == 0) g.DrawLine(pen3, n[i, 0], n[i, 1], n[j, 0], n[j, 1]);
            //    }
            //}

            Pen pen4 = new Pen(Color.DeepSkyBlue, 1);
            SetGalScreenPositions();
            for (int i = 0; i < NumGal; i++)
            {
                g.DrawEllipse(pen4, d[i, 0], d[i, 1], 1, 1);
            }
            SaveGalScreenPositions();
        }
    }
}
