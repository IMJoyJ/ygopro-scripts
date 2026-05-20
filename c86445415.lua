--レッド・ガジェット
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1只「黄色零件」加入手卡。
function c86445415.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1只「黄色零件」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86445415,0))  --"选1只「黄色零件」加入手牌"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c86445415.tg)
	e1:SetOperation(c86445415.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤卡组中卡名为「黄色零件」且可以加入手牌的卡
function c86445415.filter(c)
	return c:IsCode(13839120) and c:IsAbleToHand()
end
-- 效果发动的目标与可行性检查
function c86445415.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在可以加入手牌的「黄色零件」
	if chk==0 then return Duel.IsExistingMatchingCard(c86445415.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，将卡组中的「黄色零件」加入手牌并给对方确认
function c86445415.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张满足过滤条件的「黄色零件」
	local tc=Duel.GetFirstMatchingCard(c86445415.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将选取的卡片因效果加入玩家手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
