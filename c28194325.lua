--H・C クラスプ・ナイフ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡用「英豪挑战者」怪兽的效果特殊召唤成功时才能发动。从卡组把1只「英豪挑战者」怪兽加入手卡。
function c28194325.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡用「英豪挑战者」怪兽的效果特殊召唤成功时才能发动。从卡组把1只「英豪挑战者」怪兽加入手卡。
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
-- 发动条件判定：确认这张卡是被「英豪挑战者」怪兽的效果特殊召唤成功，且那次特殊召唤的来源是怪兽效果。
function c28194325.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x106f)
end
-- 检索过滤器：对象必须是「英豪挑战者」字段的怪兽，并且可以加入手牌。
function c28194325.filter(c)
	return c:IsSetCard(0x106f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动前检查与操作信息登记：卡组存在可检索对象时才可发动，并向系统登记本效果会把卡组中的1张卡加入手牌。
function c28194325.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点合法性检查：在卡组中至少存在1张满足条件的「英豪挑战者」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28194325.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时将把持有者tp的卡组中的1张卡加入手牌，供后续连锁/判定参考。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组选择1张符合条件的「英豪挑战者」怪兽加入手牌；若选到了则执行加入手牌并向对方展示。
function c28194325.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给出“请选择要加入手牌的卡”的提示文字，配合选择框显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选出1张满足条件的「英豪挑战者」怪兽（处理时不取对象，进行实际选择）。
	local g=Duel.SelectMatchingCard(tp,c28194325.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示刚加入手牌的卡，以便确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
