--キキナガシ風鳥
-- 效果：
-- 1星怪兽×2
-- ①：这张卡只要在怪兽区域存在，不受其他卡的效果影响。
-- ②：1回合1次，把这张卡2个超量素材取除才能发动。这个回合，这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。这个效果在对方回合也能发动。
function c27240101.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用2只等级1的怪兽作为超量素材叠放（对应“1星怪兽×2”）。
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
	-- 设置效果②的发动条件为只能在可进入战斗阶段的主要阶段或战斗阶段中发动（因为二速效果，对方回合也能在对应时点发动）。
	e2:SetCondition(aux.bpcon)
	e2:SetCost(c27240101.indcost)
	e2:SetOperation(c27240101.indop)
	c:RegisterEffect(e2)
end
-- 免疫过滤函数：当试图影响本卡的效果的所有者不是本卡时，本卡对该效果免疫，从而实现“不受其他卡的效果影响”。
function c27240101.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 发动代价：在发动时检查并且实际取除这张卡的2个超量素材（取除为COST）。
function c27240101.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果处理：若这张卡仍与效果关联，则赋予它直到结束阶段的“不会被战斗破坏”和“战斗发生的对自己的战斗伤害变成0”的效果。
function c27240101.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡不会被战斗破坏
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
