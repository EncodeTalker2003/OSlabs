#include <bits/stdc++.h>
using namespace std;
int main() {
	int a = 2;
	int *pa = &a;
	*pa++;
	cout << a << " " << pa << " " << *pa << endl;
	return 0;
}