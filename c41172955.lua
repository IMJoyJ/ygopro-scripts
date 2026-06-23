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
-- 过滤函数，用于筛选卡组中满足条件的「红色零件」卡片
function c41172955.filter(c)
	return c:IsCode(86445415) and c:IsAbleToHand()
end
-- 效果的处理目标函数，检查卡组中是否存在满足条件的「红色零件」并设置操作信息
function c41172955.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即卡组中是否存在至少1张「红色零件」
	if chk==0 then return Duel.IsExistingMatchingCard(c41172955.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索1张「红色零件」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，执行将「红色零件」从卡组加入手牌的操作
function c41172955.op(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索满足条件的第一张「红色零件」卡片
	local tc=Duel.GetFirstMatchingCard(c41172955.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将检索到的「红色零件」送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认被送入手牌的「红色零件」卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
