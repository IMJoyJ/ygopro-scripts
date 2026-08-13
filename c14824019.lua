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
-- 过滤卡组中满足以下条件的卡片：卡名含有「魔导书」字段的魔法卡，且该卡能够被加入手卡。
function c14824019.filter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果发动时的目标判定：若为发动时点检查（chk==0）则直接允许发动；同时将本次操作信息登记为从卡组检索1张卡加入手卡。
function c14824019.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次效果的操作信息：效果分类为回手牌与检索，预计从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时执行的操作：先弹出选择提示，再从己方卡组选择1张符合条件的「魔导书」魔法卡加入手卡，并让对方确认。
function c14824019.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示当前玩家选择一张要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 在己方卡组中检索并选择1张满足c14824019.filter条件的卡（即「魔导书」魔法卡且可加入手牌）。
	local g=Duel.SelectMatchingCard(tp,c14824019.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
