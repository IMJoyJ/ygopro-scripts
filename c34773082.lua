--魔玩具補綴
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「融合」和1只「锋利小鬼」怪兽加入手卡。
function c34773082.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1张「融合」和1只「锋利小鬼」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34773082+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c34773082.target)
	e1:SetOperation(c34773082.activate)
	c:RegisterEffect(e1)
end
-- 筛选卡组中卡号为24094653（「融合」）且能够加入手卡的卡，作为可检索的融合魔法卡候选。
function c34773082.filter1(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 筛选卡组中属于「锋利小鬼」系列且为怪兽卡、能够加入手卡的怪兽，作为可检索的锋利小鬼怪兽候选。
function c34773082.filter2(c)
	return c:IsSetCard(0xc3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动的合法条件检查：自己卡组中同时存在至少1张符合条件的「融合」和至少1只符合条件的「锋利小鬼」怪兽时，效果才能发动。
function c34773082.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足filter1（即「融合」）的卡，作为发动条件之一。
	if chk==0 then return Duel.IsExistingMatchingCard(c34773082.filter1,tp,LOCATION_DECK,0,1,nil)
		-- 同时检查卡组中是否存在至少1只满足filter2（即「锋利小鬼」怪兽）的卡，作为发动条件之一。
		and Duel.IsExistingMatchingCard(c34773082.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果预计从持有者（tp）的卡组把2张卡加入手卡。由于具体卡牌在效果处理时才确定，因此targets设为nil，并标明位置为卡组，供相关效果（如星尘龙等）检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组分别选出1张「融合」和1只「锋利小鬼」怪兽，合并后加入持有者手卡，并向对方玩家展示这些卡片。
function c34773082.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方卡组中所有满足filter1（卡号为24094653的「融合」）的卡，作为待选择集合g1。
	local g1=Duel.GetMatchingGroup(c34773082.filter1,tp,LOCATION_DECK,0,nil)
	-- 获取己方卡组中所有满足filter2（「锋利小鬼」怪兽）的卡，作为待选择集合g2。
	local g2=Duel.GetMatchingGroup(c34773082.filter2,tp,LOCATION_DECK,0,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 弹出选择框提示，让玩家从g1中选择1张要加入手卡的「融合」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 弹出选择框提示，让玩家从g2中选择1只要加入手卡的「锋利小鬼」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		-- 将选中的「融合」和「锋利小鬼」怪兽（合并后的sg1）以效果原因送去持有者的手卡。
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
		-- 向对方玩家（1-tp）确认展示加入手卡的卡，即公开检索结果。
		Duel.ConfirmCards(1-tp,sg1)
	end
end
