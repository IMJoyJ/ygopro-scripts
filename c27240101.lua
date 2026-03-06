--キキナガシ風鳥
-- 效果：
-- 1星怪兽×2
-- ①：这张卡只要在怪兽区域存在，不受其他卡的效果影响。
-- ②：1回合1次，把这张卡2个超量素材取除才能发动。这个回合，这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。这个效果在对方回合也能发动。
function c27240101.initial_effect(c)
	-- 添加XYZ召唤手续，使用1星怪兽叠放2只以上进行XYZ召唤
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- ①：这张卡只要在怪兽区域存在，不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c27240101.efilter)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡2个超量素材取除才能发动。这个回合，这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27240101,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	-- 效果发动条件为当前处于可以进行战斗相关操作的时点或阶段
	e2:SetCondition(aux.bpcon)
	e2:SetCost(c27240101.indcost)
	e2:SetOperation(c27240101.indop)
	c:RegisterEffect(e2)
end
-- 效果过滤器函数，使该卡不受除自己以外的其他卡的效果影响
function c27240101.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 支付效果代价，从自己场上取除2个超量素材
function c27240101.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 将该卡在本回合内设置为不会被战斗破坏，并且不会受到战斗伤害
function c27240101.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 设置该卡在本回合内不会被战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		c:RegisterEffect(e2)
	end
end
