--ジャスティス・ワールド
-- 效果：
-- 每次从自己卡组有卡被送去墓地，给这张卡放置1个光指示物。每有1个光指示物，场上名字带有「光道」的怪兽的攻击力上升100。场上表侧表示存在的这张卡被其他的卡的效果破坏的场合，作为代替把2个光指示物取除。
function c36099620.initial_effect(c)
	c:EnableCounterPermit(0x5)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次从自己卡组有卡被送去墓地，给这张卡放置1个光指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(c36099620.acop)
	c:RegisterEffect(e2)
	-- 每有1个光指示物，场上名字带有「光道」的怪兽的攻击力上升100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 将攻击力上升的对象限定为双方场上名字带有「光道」的怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x38))
	e3:SetValue(c36099620.atkval)
	c:RegisterEffect(e3)
	-- 场上表侧表示存在的这张卡被其他的卡的效果破坏的场合，作为代替把2个光指示物取除。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(c36099620.desreptg)
	e4:SetOperation(c36099620.desrepop)
	c:RegisterEffect(e4)
end
c36099620.mentioned_counter={
	[0x5]=true,
}
-- 计算攻击力上升数值：这张卡上的光指示物数量乘以100。
function c36099620.atkval(e,c)
	return e:GetHandler():GetCounter(0x5)*100
end
-- 筛选条件：送去墓地的卡之前位于卡组，且之前的控制者为该玩家，即从自己卡组送去墓地的卡。
function c36099620.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
end
-- 若本次送去墓地的卡中存在从自己卡组送去墓地的卡，则给这张卡放置1个光指示物。
function c36099620.acop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c36099620.cfilter,1,nil,tp) then
		e:GetHandler():AddCounter(0x5,1)
	end
end
-- 检查代替破坏的适用条件：这张卡不是因规则被破坏，且其上的光指示物有2个以上。
function c36099620.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_RULE)
		and e:GetHandler():GetCounter(0x5)>=2 end
	return true
end
-- 作为破坏的代替，从这张卡上取除2个光指示物。
function c36099620.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(ep,0x5,2,REASON_EFFECT)
end
