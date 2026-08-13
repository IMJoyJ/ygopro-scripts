--心鎮壷のレプリカ
-- 效果：
-- 选择场上盖放的1张魔法·陷阱卡发动。只要这张卡在场上存在，选择的卡不能发动。不能对应这张卡的发动把魔法·陷阱·效果怪兽的效果发动。
function c40736921.initial_effect(c)
	-- 『选择场上盖放的1张魔法·陷阱卡发动。不能对应这张卡的发动把魔法·陷阱·效果怪兽的效果发动。』
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c40736921.target)
	e1:SetOperation(c40736921.operation)
	c:RegisterEffect(e1)
	-- 『只要这张卡在场上存在，选择的卡不能发动。』
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
end
-- 发动时的目标选择与连锁限制处理：确认对象只能是里侧表示的魔法·陷阱卡，提示玩家选择1张，并设置本次发动不能被魔法·陷阱·效果怪兽的效果连锁。
function c40736921.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	-- 发动条件检查：确认场上存在1张里侧表示的魔法·陷阱卡（除自身）可以作为对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	-- 给玩家提示选择消息：请选择一张盖放的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40736921,0))  --"请选择一张盖放的魔法·陷阱卡"
	-- 让玩家从双方魔陷区选择1张里侧表示的魔法·陷阱卡（除自身）作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置本次发动的连锁限制为恒假，使任何魔法·陷阱·效果怪兽的效果都不能对应这次发动进行连锁。
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 效果处理时，若发动卡和目标卡都仍在场上且与效果相关联，且目标仍是里侧表示，则将目标卡设为这张卡的持续对象，使『不能发动』效果持续作用于目标。
function c40736921.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的目标卡（作为对象的那张里侧魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
