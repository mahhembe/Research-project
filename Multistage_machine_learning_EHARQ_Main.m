function c = Multistage_machine_learning_EHARQ_Main()

x=-30:0.5:30;
y=HARQ_throughput(x);
z=machine_learning_EHARQ_throughput(x);
w=mml_EHARQ_throughput(x);

figure
plot(x,y,'r--');
hold on
plot(x,z,'b');
hold on
plot(x,w,'k')
xlabel('SNR');
ylabel('Percentage throughput (%)')
title("Percentage throughput based on different SNR")
legend({'HARQ','Machine learning E-HARQ','Multistage Machine E-HARQ'},'Location','southeast')


y=HARQ_error_rate(x);
z=machine_learning_EHARQ_error_rate(x);
w=mml_EHARQ_error_rate(x);
figure
plot(x,y);
hold on
plot(x,z);
hold on
plot(x,w)
ylabel('error rate (%)')
xlabel('SNR')
title("Percentage error rate based on various SNR")
legend({'HARQ','Machine learning E-HARQ','Multistage Machine E-HARQ'},'Location','northeast')


x=5:20;
y=HARQ_rtt(x);
z=machine_learning_HARQ_rtt(x);
w=mml_EHARQ_rtt(x);
figure
plot(x,y,'r');
hold on
plot(x,z,'b-');
hold on
plot(x,w,'k*')
ylabel('rtt (s)')
xlabel('packet size (2^x)')
title("round trip time for different packet size")
legend({'HARQ','Machine learning E-HARQ','Multistage Machine E-HARQ'},'Location','northeast')


x=-20:0.5:20;
y=HARQ_latency(x);
z=machine_learning_EHARQ_latency(x);
w=mml_EHARQ_latency(x);
figure
plot(x,y,'r');
hold on
plot(x,z,'b-');
hold on
plot(x,w,'k-')
ylabel('latency (s)')
xlabel('SNR ')
title("Latency based on various channel noise(SNR)")
legend({'HARQ','Machine learning E-HARQ','Multistage Machine E-HARQ'},'Location','northeast')


x=5:20;
y=HARQ_packet_latency(x);
z=machine_learning_HARQ_packet(x);
w=mml_HARQ_packet_latency(x);
figure
plot(x,y,'r');
hold on
plot(x,z,'b-');
hold on
plot(x,w,'k*');
ylabel('latency (s)')
xlabel('packet size 2^x ')
title("Latency based on different packet size")
legend({'HARQ','Machine learning E-HARQ','Multistage Machine E-HARQ'},'Location','northeast')


end