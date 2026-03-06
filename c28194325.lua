--H・C クラスプ・ナイフ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡用「英豪挑战者」怪兽的效果特殊召唤成功时才能发动。从卡组把1只「英豪挑战者」怪兽加入手卡。
function c28194325.initial_effect(c)
	-- 效果原文内容：①：这张卡用「英豪挑战者」怪兽的效果特殊召唤成功时才能发动。从卡组把1只「英豪挑战者」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28194325,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,28194325)
	e1:SetCondition(c28194325.condition)
	e1:SetTarget(c28194325.target)
	e1:SetOperation(c28194325.operation)
	c:RegisterEffect(e1)
end
-- 规则层面操作：判断这张卡是否是通过「英豪挑战者」怪兽的效果特殊召唤成功
function c28194325.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x106f)
end
-- 规则层面操作：过滤出卡组中满足条件的「英豪挑战者」怪兽（类型为怪兽且能加入手牌）
function c28194325.filter(c)
	return c:IsSetCard(0x106f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 规则层面操作：设置连锁处理信息，表示将从卡组检索1只「英豪挑战者」怪兽加入手牌
function c28194325.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查在卡组中是否存在至少1张满足条件的「英豪挑战者」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28194325.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面操作：设置连锁处理信息，表示将从卡组检索1只「英豪挑战者」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：选择并把符合条件的「英豪挑战者」怪兽从卡组加入手牌，并向对方确认该卡
function c28194325.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：从卡组中选择1张满足条件的「英豪挑战者」怪兽
	local g=Duel.SelectMatchingCard(tp,c28194325.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面操作：向对方确认被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
