--占術姫アローシルフ
-- 效果：
-- ①：这张卡反转的场合才能发动。从自己的卡组·墓地选1张仪式魔法卡加入手卡。
function c31118030.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从自己的卡组·墓地选1张仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c31118030.thtg)
	e1:SetOperation(c31118030.thop)
	c:RegisterEffect(e1)
end
-- 筛选条件：卡片类型为仪式魔法卡（类型值0x82包含仪式与魔法）且该卡能被加入手卡。
function c31118030.thfilter(c)
	return bit.band(c:GetType(),0x82)==0x82 and c:IsAbleToHand()
end
-- 效果发动时的目标检测与操作信息设置：检查我方卡组·墓地是否存在符合条件的仪式魔法卡，并声明效果处理时将卡片加入手卡。
function c31118030.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）确认卡组·墓地中是否存在至少1张符合条件的仪式魔法卡，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c31118030.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：声明本效果处理时将从卡组·墓地把1张卡加入手卡，用于后续连锁响应和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理时：玩家从卡组·墓地选择1张符合条件的仪式魔法卡加入手卡，并将选择的卡展示给对方确认。
function c31118030.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组·墓地中筛选出满足条件（仪式魔法卡、可加入手卡且不受王家长眠之谷影响的卡）的卡片，并让玩家选择1张。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31118030.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡（nil表示回到原本持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
