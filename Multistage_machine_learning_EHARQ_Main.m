function c = Multistage_machine_learning_EHARQ_Main()

x=-30:0.5:30;
y=HARQ_throughput(x);
z=machine_learning_EHARQ_throughput(x);
w=mml_EHARQ_throughput(x);
figure
plot(x,y);
hold on
plot(x,z);
hold on
plot(x,w)


end