--召集の聖刻印
-- 效果：
-- ①：从卡组把1只「圣刻」怪兽加入手卡。
function c25377819.initial_effect(c)
	-- ①：从卡组把1只「圣刻」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c25377819.target)
	e1:SetOperation(c25377819.activate)
	c:RegisterEffect(e1)
end
-- 筛选卡组中满足以下条件的卡：持有「圣刻」字段、是怪兽卡，并且能够被加入手卡。
function c25377819.filter(c)
	return c:IsSetCard(0x69) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设定效果发动时的目标判定：在发动时检查是否满足条件，并设置将卡组中1只「圣刻」怪兽加入手卡的操作信息。
function c25377819.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中存在至少1只满足 c25377819.filter 过滤条件的「圣刻」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c25377819.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：效果类别为回手牌+检索，预计处理1张卡，从卡组加入手卡，供后续效果检测（如星尘龙、王家长眠之谷等）使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让玩家从卡组选择1只符合条件的「圣刻」怪兽加入手卡，并将检索结果展示给对手确认。
function c25377819.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从当前玩家的卡组中选择1张满足 c25377819.filter 过滤条件的「圣刻」怪兽（不取对象）。
	local g=Duel.SelectMatchingCard(tp,c25377819.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，加入原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对手玩家确认（公开检索信息）。
		Duel.ConfirmCards(1-tp,g)
	end
end
