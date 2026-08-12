--ゴーストリック・ナイト
-- 效果：
-- 只要场上有名字带有「鬼计」的怪兽存在，对方场上的怪兽不能反转召唤。此外，这张卡被对方破坏送去墓地时发动。这个回合对方不能攻击宣言。
function c85827713.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要场上有名字带有「鬼计」的怪兽存在，对方场上的怪兽不能反转召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c85827713.sumcon)
	c:RegisterEffect(e2)
	-- 此外，这张卡被对方破坏送去墓地时发动。这个回合对方不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85827713,0))  --"不能攻击宣言"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c85827713.limcon)
	e3:SetOperation(c85827713.limop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查卡片是否为表侧表示且卡名含有「鬼计」
function c85827713.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 永续效果的生效条件：场上存在表侧表示的「鬼计」怪兽
function c85827713.sumcon(e)
	-- 检查双方场上是否存在至少1张表侧表示的「鬼计」怪兽
	return Duel.IsExistingMatchingCard(c85827713.sfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 诱发效果的发动条件：此卡在己方控制下被对方卡片破坏并送去墓地
function c85827713.limcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
end
-- 诱发效果的效果处理：注册一个在回合结束前限制对方不能攻击宣言的全局效果
function c85827713.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合对方不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制对方攻击宣言的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
