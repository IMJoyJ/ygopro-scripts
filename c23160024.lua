--アモルファスP
-- 效果：
-- ①：场上的「无形噬体」怪兽的攻击力·守备力上升300。
-- ②：只要这张卡在场地区域存在，每次自己场上的「无形噬体」怪兽被解放让自己从卡组抽1张。这个效果1回合可以适用最多2次。
-- ③：把墓地的这张卡除外才能发动。从自己的手卡·场上把等级合计直到8的灵摆怪兽解放，从手卡把「虚龙魔王 无形矢·心灵」仪式召唤。
function c23160024.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「无形噬体」怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 指定攻击力上升效果的对象：场上所有持有「无形噬体」字段（0xe0）的怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe0))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在场地区域存在，每次自己场上的「无形噬体」怪兽被解放让自己从卡组抽1张。这个效果1回合可以适用最多2次。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_RELEASE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(2)
	e4:SetCondition(c23160024.drcon)
	e4:SetOperation(c23160024.drop)
	c:RegisterEffect(e4)
	-- 为这张卡添加③的仪式召唤效果：从手卡·场上把等级合计直到8的灵摆怪兽解放，从手卡把「虚龙魔王 无形矢·心灵」仪式召唤；此处先以辅助函数生成效果框架并设定素材须为灵摆怪兽。
	local e5=aux.AddRitualProcEqualCode(c,98287529,nil,nil,c23160024.mfilter,true)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCode(0)
	e5:SetRange(LOCATION_GRAVE)
	-- 设置③效果发动COST：把墓地中的这张卡除外。
	e5:SetCost(aux.bfgcost)
	c:RegisterEffect(e5)
end
-- 判断解放事件中的某张卡是否为满足条件的「无形噬体」怪兽：其解放前属于「无形噬体」字段（0xe0）、因解放而离场、离场前在怪兽区域、且控制者为使用此效果的玩家tp。
function c23160024.cfilter(c,tp)
	return c:IsPreviousSetCard(0xe0) and c:IsReason(REASON_RELEASE) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 抽卡效果的发动条件：本次解放事件中存在至少1张自己场上被解放的「无形噬体」怪兽。
function c23160024.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23160024.cfilter,1,nil,tp)
end
-- 抽卡效果的处理：展示卡片动画后，让控制者tp从卡组抽1张卡。
function c23160024.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示效果持有者（无形阵·假面）的卡片动画，提示该效果正在处理。
	Duel.Hint(HINT_CARD,0,e:GetHandler():GetCode())
	-- 控制者tp从卡组抽1张卡，抽卡原因标记为效果。
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 仪式素材过滤条件：要求解放的怪兽必须是灵摆怪兽。
function c23160024.mfilter(c)
	return c:IsType(TYPE_PENDULUM)
end
