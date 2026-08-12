--虚無の波動
-- 效果：
-- 自己没有手卡时，自己场上表侧表示存在的名字带有「永火」的怪兽攻击力及守备力增加400。可以把自己场上表侧表示存在的这张卡送去墓地将自己的所有手卡送去墓地。
function c63665606.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己没有手卡时，自己场上表侧表示存在的名字带有「永火」的怪兽攻击力及守备力增加400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c63665606.atcon)
	-- 设置效果影响的对象为自己场上名字带有「永火」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb))
	e2:SetValue(400)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 可以把自己场上表侧表示存在的这张卡送去墓地将自己的所有手卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(63665606,0))  --"所有手牌送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c63665606.discost)
	e4:SetTarget(c63665606.distg)
	e4:SetOperation(c63665606.disop)
	c:RegisterEffect(e4)
end
-- 攻击力与守备力上升效果的适用条件函数
function c63665606.atcon(e)
	-- 判断自己手卡数量是否为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
-- 效果发动的代价（Cost）函数，将这张卡送去墓地
function c63665606.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡自身作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果发动的目标（Target）函数，确认自己有手卡并设置操作信息
function c63665606.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，确认自己手卡数量大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 设置效果处理信息，表示将手卡的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_HAND)
end
-- 效果处理（Operation）函数，将自己的所有手卡送去墓地
function c63665606.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己所有的手卡
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将自己的所有手卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
