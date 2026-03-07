--魔玩具補綴
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「融合」和1只「锋利小鬼」怪兽加入手卡。
function c34773082.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34773082+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c34773082.target)
	e1:SetOperation(c34773082.activate)
	c:RegisterEffect(e1)
end
-- 从卡组把1张「融合」和1只「锋利小鬼」怪兽加入手卡。
function c34773082.filter1(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果作用
function c34773082.filter2(c)
	return c:IsSetCard(0xc3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果作用
function c34773082.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的卡片组
	if chk==0 then return Duel.IsExistingMatchingCard(c34773082.filter1,tp,LOCATION_DECK,0,1,nil)
		-- 检索满足条件的卡片组
		and Duel.IsExistingMatchingCard(c34773082.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果作用
function c34773082.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的卡片组
	local g1=Duel.GetMatchingGroup(c34773082.filter1,tp,LOCATION_DECK,0,nil)
	-- 检索满足条件的卡片组
	local g2=Duel.GetMatchingGroup(c34773082.filter2,tp,LOCATION_DECK,0,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 提示玩家选择卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 提示玩家选择卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		-- 将目标卡片送入手牌
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
		-- 确认玩家手牌
		Duel.ConfirmCards(1-tp,sg1)
	end
end
