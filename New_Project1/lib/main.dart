
class human{
    human(int age , double weight , double hight){
        this.age = age;
        this.weight = weight;
        this.hight = hight;
    }
    int numberOfArms=2;
    int? age;
    double? weight;
    double? hight;
}

void main(){
    human amr = human(22,173,70);
    print(amr.age);
}

