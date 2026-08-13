--E－エマージェンシーコール
-- 效果：
-- ①：从卡组把1只「元素英雄」怪兽加入手卡。
function c213326.initial_effect(c)
	-- ①：从卡组把1只「元素英雄」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c213326.target)
	e1:SetOperation(c213326.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选出拥有「元素英雄」字段、是怪兽卡且可以被加入手卡的卡。
function c213326.filter(c)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的目标判定与操作信息设置：检查卡组是否存在符合条件的卡，并设定将卡组1张卡加入手卡的操作信息。
function c213326.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 仅在发动时检查卡组是否存在至少1只满足条件的「元素英雄」怪兽，作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c213326.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将把持有者tp的卡组中1张卡加入手卡（效果分类为回手牌），具体卡片在处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：提示玩家选择卡组中1只符合条件的「元素英雄」怪兽；若有选中则将其加入手卡，并让对方确认。
function c213326.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示消息，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让tp从自己的卡组中选出1张满足filter的卡（必须选1张），并返回选中的卡组。
	local g=Duel.SelectMatchingCard(tp,c213326.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（nil表示加入持有者手卡），原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
