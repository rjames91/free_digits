import numpy as np
import pyNN.nest as p
import relu_utils as alg
import spiking_relu as sr
import cnn_utils as cnnu
import spiking_cnn as scnn
import random
import os.path
import sys
#import matplotlib.cm as cm


import scipy.io as sio
#tmp_x = sio.loadmat('mnist.mat')['test_x']
#tmp_x = np.transpose(tmp_x, (2, 0, 1))
#tmp_x = np.reshape(tmp_x, (tmp_x.shape[0], 28*28), order='F' )

#tmp_y = sio.loadmat('mnist.mat')['test_y']
#tmp_y = np.argmax(tmp_y, axis=0)

tmp_x = sio.loadmat('map_rates_60.mat')['test_x'] #train_x
tmp_x = np.abs(tmp_x)
tmp_x /= tmp_x.max()
tmp_y = sio.loadmat('map_rates_60.mat')['test_y'] #train_y
tmp_y = np.argmax(tmp_y, axis=1)
print tmp_y
dur_test = 1000 #ms
silence = 20 #ms
num_test = 10

test_len = 100 #400 for training data
dir = 'result'
if not os.path.isdir('result'):
    os.mkdir(dir)
cnn_file = sys.argv[1]
tau_syn = 5.
scale_S = 201.
scale_K = 200.

cell_params_lif = {'cm': 0.25,      #nF
                   'i_offset': 0.1, #nA
                   'tau_m': 20.0,   #ms
                   'tau_refrac': 1.,#ms
                   'tau_syn_E': tau_syn,#ms
                   'tau_syn_I': tau_syn,#ms
                   'v_reset': -65.0,#mV
                   'v_rest': -65.0, #mV
                   'v_thresh': -50.0#mV
                   }                  
                    
w_cnn, l_cnn = cnnu.readmat(cnn_file)
predict = np.zeros(test_len)

for offset in range(0, test_len, num_test):
    print 'offset: ', offset
    test = tmp_x[offset:(offset+num_test), :]
    test = test * scale_K
    predict[offset:(offset+num_test)],  spikes= scnn.scnn_test(cell_params_lif, l_cnn, w_cnn, num_test, test, 0, dur_test, silence)
    print predict[offset:(offset+num_test)] 
    print sum(predict[offset:(offset+num_test)]==tmp_y[offset:(offset+num_test)]) 
    spike_f = '%s/spike_%d.npy'%(dir,offset)
    np.save(spike_f, spikes)
np.save('%s/predict_result'%(dir), predict)
print 'Classification accuracy: ', np.float(np.sum(predict[:test_len]==tmp_y[:test_len]))/np.float(test_len)*100., '%'

