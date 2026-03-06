--霊魂の円環
-- 效果：
-- 「灵魂的圆环」的①②的效果1回合各能使用1次。
-- ①：这张卡在魔法与陷阱区域存在，自己场上的表侧表示的灵魂怪兽回到自己手卡的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：对方怪兽的攻击宣言时把自己墓地1只灵魂怪兽除外才能发动。那次攻击无效，那之后战斗阶段结束。
function c276357.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时把自己墓地1只灵魂怪兽除外才能发动。那次攻击无效，那之后战斗阶段结束。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(276357,0))  --"卡片破坏"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,276357)
	e2:SetCondition(c276357.condition)
	e2:SetCost(c276357.cost)
	e2:SetOperation(c276357.activate)
	c:RegisterEffect(e2)
	-- ①：这张卡在魔法与陷阱区域存在，自己场上的表侧表示的灵魂怪兽回到自己手卡的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(276357,1))  --"攻击无效"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,276358)
	e3:SetCondition(c276357.descon)
	e3:SetTarget(c276357.destg)
	e3:SetOperation(c276357.desop)
	c:RegisterEffect(e3)
end
c276357.has_text_type=TYPE_SPIRIT
-- 判断是否为对方怪兽攻击宣言时触发的效果
function c276357.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击方是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 判断墓地是否存在灵魂怪兽
function c276357.cfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsAbleToRemoveAsCost()
end
-- 支付效果代价，从墓地除外1只灵魂怪兽
function c276357.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付代价的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c276357.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的灵魂怪兽除外
	local g=Duel.SelectMatchingCard(tp,c276357.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以除外形式从墓地移除
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 处理效果发动后的操作，无效攻击并跳过对方战斗阶段
function c276357.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效此次攻击
	if Duel.NegateAttack() then
		-- 中断当前效果处理流程
		Duel.BreakEffect()
		-- 跳过对方的战斗阶段
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 判断是否满足效果发动条件，即是否有灵魂怪兽回到手牌
function c276357.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsControler(tp) and c:GetPreviousTypeOnField()&TYPE_SPIRIT>0
end
-- 判断是否满足效果发动条件，即是否有灵魂怪兽回到手牌且卡片处于启用状态
function c276357.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c276357.filter,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 设置效果目标，选择对方场上1张卡作为破坏对象
function c276357.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为目标
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，确定破坏效果的目标数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果破坏操作
function c276357.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以破坏形式从场上移除
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
