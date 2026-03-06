--スニッフィング・ドラゴン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「嗅探龙」加入手卡。
function c27877771.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「嗅探龙」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27877771,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,27877771)
	e1:SetTarget(c27877771.target)
	e1:SetOperation(c27877771.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检索满足条件的「嗅探龙」卡片
function c27877771.filter(c)
	return c:IsCode(27877771) and c:IsAbleToHand()
end
-- 效果处理时的条件判断，检查卡组中是否存在满足条件的「嗅探龙」
function c27877771.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「嗅探龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c27877771.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索1张「嗅探龙」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行将「嗅探龙」从卡组加入手牌的操作
function c27877771.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索满足条件的第一张「嗅探龙」
	local tc=Duel.GetFirstMatchingCard(c27877771.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将检索到的「嗅探龙」送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认自己从卡组检索到的「嗅探龙」
		Duel.ConfirmCards(1-tp,tc)
	end
end
