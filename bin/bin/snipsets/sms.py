'''send sms message via bmob.'''
import json
import requests
import threading

class SMS_sender:
    def __init__(self,appid,appkey):
        self.headers={"X-Bmob-Application-ID":appid,
                      "X-Bmob-REST-API-Key":appkey,
                      "Content-Type":"application/json"}
    def send_sms(self,content,target):
        data={'mobilePhoneNumber':target,'content':content}
        request=requests.post("https://api.bmob.cn/1/requestSms",headers=self.headers,data=json.dumps(data))
        return request.json()

    def send_sms_code(self,template,target):
        data={'mobilePhoneNumber':target,'template':template}
        request=requests.post("https://api.bmob.cn/1/requestSmsCode",headers=self.headers,data=json.dumps(data))
        return request.json()

    def send_mass_sms_code(self,template,target):
        outputs=[]
        for target_item in target:
            outputs.append(self.send_sms_code(template,target_item))
        return outputs

    def async_send_mass_sms_code(self,template,*target):
        thr = threading.Thread(target=self.send_mass_sms_code, args=[template, target])
        thr.start()
        return thr

if __name__=='__main__':
    sendlist={'13302091826',
    '13820389921',
    '13821707225',
    '13752127826',
    '13820382715',
    '15620683792',
    '13302093992',
    '13672010117',
    '13332065091',
    '15022163897',
    '13702183626',
    '13799133760',
    '18222114519',
    '13820271727',
    '18997212787'}
    sendlist2={"18076189849",
"15332032978",
"13132537260",
"13820389921",
"13302091826",
"13821707225",
"13752127826",
"13820382715",
"15620683792",
"15832009144",
"13662177020",
"13302093992",
"13672010117",
"13332065091",
"15022163897",
"13702183626",
"13799133760",
"18222114519",
"13820271727",
"13820206019",
"13821135320",
"17787762693",
"18997212787",
}
    print(sendlist2-sendlist)
    sender=SMS_sender("e37593594304a3497ebc49a5d82ec863","0b0ec4e580556df22790b1a2291b9f2e")
    print(sender.send_mass_sms_code('celitea-面试',sendlist2-sendlist))
