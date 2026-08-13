--グリーン・ガジェット
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1只「红色零件」加入手卡。
function c41172955.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1只「红色零件」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41172955,0))  --"选1只「红色零件」加入手牌"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c41172955.tg)
	e1:SetOperation(c41172955.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：卡组中卡号86445415（红色零件）且能够加入手卡的卡。
function c41172955.filter(c)
	return c:IsCode(86445415) and c:IsAbleToHand()
end
-- 目标函数：在发动时检查是否满足条件，并设置本次效果的处理信息。
function c41172955.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：在时点检查（chk==0）时，确认卡组是否存在至少1张符合条件的「红色零件」。
	if chk==0 then return Duel.IsExistingMatchingCard(c41172955.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理为从卡组将1张卡加入手卡，供连锁/检测等系统使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组找到符合条件的「红色零件」并加入手卡，同时向对方确认。
function c41172955.op(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组取得第一张符合筛选条件的卡片。
	local tc=Duel.GetFirstMatchingCard(c41172955.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将该卡加入其持有者的手卡，移动原因是效果处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对手玩家展示被加入手卡的卡片，确认检索结果。
		Duel.ConfirmCards(1-tp,tc)
	end
end
