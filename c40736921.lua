--心鎮壷のレプリカ
-- 效果：
-- 选择场上盖放的1张魔法·陷阱卡发动。只要这张卡在场上存在，选择的卡不能发动。不能对应这张卡的发动把魔法·陷阱·效果怪兽的效果发动。
function c40736921.initial_effect(c)
	-- 效果原文：选择场上盖放的1张魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c40736921.target)
	e1:SetOperation(c40736921.operation)
	c:RegisterEffect(e1)
	-- 效果原文：只要这张卡在场上存在，选择的卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
end
-- 检索满足条件的场上盖放的魔法·陷阱卡
function c40736921.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	-- 判断是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	-- 提示玩家选择一张盖放的魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40736921,0))  --"请选择一张盖放的魔法·陷阱卡"
	-- 选择一张场上盖放的魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制，使该卡发动时不能被连锁
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 效果处理：将选择的目标卡设为永续对象
function c40736921.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
