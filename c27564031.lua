--Sin World
-- 效果：
-- ①：自己抽卡阶段作为进行通常抽卡的代替才能发动。从卡组把3张「罪」卡给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩下的卡回到卡组。
function c27564031.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：自己抽卡阶段作为进行通常抽卡的代替才能发动。从卡组把3张「罪」卡给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩下的卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27564031,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c27564031.condition)
	e2:SetTarget(c27564031.target)
	e2:SetOperation(c27564031.operation)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否为当前回合玩家触发效果
function c27564031.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断当前玩家是否为回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 规则层面作用：定义过滤函数，筛选「罪」卡且能加入手牌的卡片
function c27564031.filter(c)
	return c:IsSetCard(0x23) and c:IsAbleToHand()
end
-- 规则层面作用：设置效果的发动条件与目标处理
function c27564031.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家是否可以进行通常抽卡且卡组中存在至少3张「罪」卡
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(c27564031.filter,tp,LOCATION_DECK,0,3,nil) end
	-- 规则层面作用：使目标玩家放弃通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	-- 规则层面作用：设置连锁操作信息，指定将要处理的卡牌类别为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 规则层面作用：处理效果的发动流程，包括检索、展示、选择与分配卡片
function c27564031.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取满足条件的「罪」卡组
	local g=Duel.GetMatchingGroup(c27564031.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 规则层面作用：提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 规则层面作用：向对方确认展示的卡片
		Duel.ConfirmCards(1-tp,sg)
		-- 规则层面作用：洗切当前玩家的卡组
		Duel.ShuffleDeck(tp)
		local tg=sg:RandomSelect(1-tp,1)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 规则层面作用：将选定的卡片以效果原因送入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
