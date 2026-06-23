--魔導書士 バテル
-- 效果：
-- ①：这张卡召唤·反转的场合发动。从卡组把1张「魔导书」魔法卡加入手卡。
function c14824019.initial_effect(c)
	-- ①：这张卡召唤·反转的场合发动。从卡组把1张「魔导书」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14824019,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c14824019.shtg)
	e1:SetOperation(c14824019.shop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的卡片
function c14824019.filter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置效果处理时的目标，用于检索满足条件的卡片组
function c14824019.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息，指定将从卡组检索1张魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索并加入手牌的操作
function c14824019.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的1张魔法卡
	local g=Duel.SelectMatchingCard(tp,c14824019.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
