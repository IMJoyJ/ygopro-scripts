--ナチュルの森
-- 效果：
-- 把对方控制的卡的发动无效的场合，可以从自己卡组把1只3星以下的名字带有「自然」的怪兽加入手卡。
function c37322745.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：把对方控制的卡的发动无效的场合，可以从自己卡组把1只3星以下的名字带有「自然」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetDescription(aux.Stringid(37322745,0))  --"检索"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetCondition(c37322745.condition)
	e2:SetTarget(c37322745.target)
	e2:SetOperation(c37322745.operation)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断连锁发动的玩家是否为对方（即是否为对方控制的卡发动无效）。
function c37322745.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 规则层面作用：过滤满足条件的怪兽（3星以下、名字带有「自然」、怪兽类型、可以加入手牌）。
function c37322745.filter(c)
	return c:IsLevelBelow(3) and c:IsSetCard(0x2a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 规则层面作用：设置效果发动的条件，检查是否满足发动条件（不在连锁中且卡组存在符合条件的怪兽）。
function c37322745.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 规则层面作用：检查卡组中是否存在至少1张满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c37322745.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面作用：设置效果处理时的操作信息，指定将要处理的卡为1张手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：设置效果发动后的处理流程，包括提示选择、选择符合条件的怪兽并加入手牌。
function c37322745.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面作用：从卡组中选择1张满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c37322745.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的怪兽以效果原因送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面作用：确认对方查看被送入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
