--ソニックバード
-- 效果：
-- ①：这张卡召唤·反转召唤成功时才能发动。从卡组把1张仪式魔法卡加入手卡。
function c57617178.initial_effect(c)
	-- ①：这张卡召唤·反转召唤成功时才能发动。从卡组把1张仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57617178,0))  --"选择1张仪式魔法卡加入自己手牌"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c57617178.tg)
	e1:SetOperation(c57617178.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可以加入手牌的仪式魔法卡
function c57617178.filter(c)
	return c:GetType()==0x82 and c:IsAbleToHand()
end
-- 效果发动的条件检测与操作信息设置
function c57617178.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以加入手牌的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c57617178.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张仪式魔法卡加入手牌并给对方确认
function c57617178.op(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c57617178.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
