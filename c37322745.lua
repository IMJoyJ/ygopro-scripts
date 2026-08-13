--ナチュルの森
-- 效果：
-- 把对方控制的卡的发动无效的场合，可以从自己卡组把1只3星以下的名字带有「自然」的怪兽加入手卡。
function c37322745.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 把对方控制的卡的发动无效的场合，可以从自己卡组把1只3星以下的名字带有「自然」的怪兽加入手卡。
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
-- 检测被无效的卡的发动者是否为对方（ep不等于自己的tp），若对方发动的效果被无效则条件成立。
function c37322745.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 定义检索卡牌的条件：等级3以下、字段为「自然」的怪兽，且当前允许加入手卡（不受“不能加入手卡”等限制）。
function c37322745.filter(c)
	return c:IsLevelBelow(3) and c:IsSetCard(0x2a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动合法性检测：此效果发动时，本卡不在连锁处理中（未处于STATUS_CHAINING状态），且自己卡组存在符合filter条件的卡。
function c37322745.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 进一步确认卡组中存在至少1张满足c37322745.filter条件的「自然」怪兽，作为效果可发动的必要条件。
		and Duel.IsExistingMatchingCard(c37322745.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记本次操作信息：预定将我方卡组的1张卡加入手牌（分类为回手牌+检索），供其他卡的效果检测发动条件。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：从卡组选择1只符合条件的「自然」怪兽加入手牌，若成功则向对方展示该卡。
function c37322745.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示选择提示消息，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中让当前玩家选择1张满足filter条件的卡；若没有可选卡，g为空组。
	local g=Duel.SelectMatchingCard(tp,c37322745.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送去其持有者的手牌（第二参数为nil表示返回持有者手牌），操作原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将因效果加入手牌的那张卡展示给对手（1-tp）确认，以符合公开信息要求。
		Duel.ConfirmCards(1-tp,g)
	end
end
