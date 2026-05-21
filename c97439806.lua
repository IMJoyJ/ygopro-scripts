--魔轟神クシャノ
-- 效果：
-- ①：这张卡在墓地存在的场合，从手卡把「魔轰神 库沙诺」以外的1只「魔轰神」怪兽丢弃去墓地才能发动。这张卡加入手卡。
function c97439806.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，从手卡把「魔轰神 库沙诺」以外的1只「魔轰神」怪兽丢弃去墓地才能发动。这张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97439806,0))  --"这张卡加入手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(c97439806.cost)
	e1:SetTarget(c97439806.tg)
	e1:SetOperation(c97439806.op)
	c:RegisterEffect(e1)
end
-- 过滤手卡中「魔轰神 库沙诺」以外的「魔轰神」怪兽，且该怪兽可以作为代价丢弃去墓地
function c97439806.costfilter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and not c:IsCode(97439806)
		and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 发动代价：从手卡将1只「魔轰神 库沙诺」以外的「魔轰神」怪兽丢弃去墓地
function c97439806.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查手卡中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c97439806.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手卡中1张满足过滤条件的卡作为代价丢弃去墓地
	Duel.DiscardHand(tp,c97439806.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 效果的目标处理：检查自身是否能加入手卡，并设置操作信息
function c97439806.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁的操作信息为：将1张自身加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果的处理：若自身仍与效果有关联，则将其加入手卡并给对方确认
function c97439806.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身加入手卡
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,e:GetHandler())
	end
end
