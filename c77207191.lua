--バフォメット
-- 效果：
-- ①：这张卡召唤·反转召唤时才能发动。从卡组把1只「幻兽王 加泽尔」加入手卡。
function c77207191.initial_effect(c)
	-- ①：这张卡召唤·反转召唤时才能发动。从卡组把1只「幻兽王 加泽尔」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77207191,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c77207191.tg)
	e1:SetOperation(c77207191.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤卡组中卡名为「幻兽王 加泽尔」且可以加入手牌的卡
function c77207191.filter(c)
	return c:IsCode(5818798) and c:IsAbleToHand()
end
-- 效果发动的目标检查与操作信息设置函数
function c77207191.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在可以加入手牌的「幻兽王 加泽尔」
	if chk==0 then return Duel.IsExistingMatchingCard(c77207191.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息为：将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，将选中的卡加入手牌并给对方确认
function c77207191.op(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只「幻兽王 加泽尔」
	local g=Duel.SelectMatchingCard(tp,c77207191.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
