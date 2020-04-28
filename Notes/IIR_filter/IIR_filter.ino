#define LOWBYTE 0
#define HIGHBYTE 1

#define FILTER_LENGTH 4

double x[FILTER_LENGTH+1] = {0,0,0,0,0};
double y[FILTER_LENGTH+1] = {0,0,0,0,0};
double b[FILTER_LENGTH+1] = {0.621097829054547,  -2.475596488119054,   3.709013494358226, -2.475596488119055,   0.621097829054547};
double a[FILTER_LENGTH+1] = {1.000000000000000,  -3.135374485849859,   3.800207796244981,  -2.101115571063907,   0.452458489875999};

bool current_byte = LOWBYTE;
int16_t y_org, y_filt;

int16_t floor_and_convert(double value)
{
  if (value > 0) // positiv
  {
      return (int16_t)(value + 0.5);
  }
  else // negativ
  {
      return (int16_t)(value - 0.5);
  }    
}

int16_t iir_filter(int16_t value)
{      
    x[0] =  (double) (value); // Read received sample and perform typecast
    
    y[0] = b[0]*x[0];                   // Run IIR filter for first element
    
    for(int i = 1;i <= FILTER_LENGTH;i++)   // Run IIR filter for all other elements
    {
        y[0] += b[i]*x[i] - a[i]*y[i];  
    } 

    for(int i = FILTER_LENGTH-1;i >= 0;i--) // Roll x and y arrays in order to hold old sample inputs and outputs
    {
        x[i+1] = x[i];
        y[i+1] = y[i];
    }
    
    return floor_and_convert(y[0]);     // fix rounding issues;
}


void setup()
{
  Serial.begin(115200);                 // initialize serial:
}

void loop()
{
  serialEvent();
}

void serialEvent()
{
  while (Serial.available())
  {
    if (current_byte == LOWBYTE)
    {
      y_org = Serial.read();                      // get the new lowbyte
      current_byte = HIGHBYTE;
    }
    else {
      y_org += (int16_t)(Serial.read()<<8);       // get the new highbyte
      current_byte = LOWBYTE;

      y_filt = iir_filter(y_org);                 // filter new value
      Serial.write(y_filt&0xFF);                  // send low byte first
      Serial.write(y_filt>>8);                    // send high byte second (this is called littleindian)
    }
  }
}
