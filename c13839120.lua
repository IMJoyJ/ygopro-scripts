--イエロー・ガジェット
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1只「绿色零件」加入手卡。
function c13839120.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1只「绿色零件」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13839120,0))  --"选1只「绿色零件」加入手牌"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c13839120.tg)
	e1:SetOperation(c13839120.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 检查卡片是否为「绿色零件」（41172955）并且能够加入手卡。
function c13839120.filter(c)
	return c:IsCode(41172955) and c:IsAbleToHand()
end
-- 效果发动的合法条件检查：卡组中存在1只以上「绿色零件」且能被加入手卡；并设置检索加入手卡的操作信息。
function c13839120.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查卡组中是否存在1只满足条件的「绿色零件」，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c13839120.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息：从卡组将1张卡加入手卡（检索效果），用于连锁和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选取1只「绿色零件」加入手卡，并向对方玩家确认。
function c13839120.op(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中获取第一张满足过滤条件的「绿色零件」。
	local tc=Duel.GetFirstMatchingCard(c13839120.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将该卡加入持有者的手卡（由效果加入手卡）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的这张卡（因为是从卡组检索，需要确认）。
		Duel.ConfirmCards(1-tp,tc)
	end
end
