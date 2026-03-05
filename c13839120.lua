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
-- 过滤函数，用于检索满足条件的「绿色零件」卡片
function c13839120.filter(c)
	return c:IsCode(41172955) and c:IsAbleToHand()
end
-- 效果处理时的处理目标函数
function c13839120.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「绿色零件」
	if chk==0 then return Duel.IsExistingMatchingCard(c13839120.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将从卡组检索1张「绿色零件」加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的处理函数
function c13839120.op(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索满足条件的第一张「绿色零件」
	local tc=Duel.GetFirstMatchingCard(c13839120.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将检索到的「绿色零件」送入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认送入手卡的「绿色零件」
		Duel.ConfirmCards(1-tp,tc)
	end
end
