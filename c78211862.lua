--ライジング・エナジー
-- 效果：
-- ①：丢弃1张手卡，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1500。
function c78211862.initial_effect(c)
	-- ①：丢弃1张手卡，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件：在伤害步骤中，只能在伤害计算前发动（利用aux.dscon辅助函数限制）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c78211862.cost)
	e1:SetTarget(c78211862.target)
	e1:SetOperation(c78211862.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的代价（Cost）函数，处理丢弃手卡的操作。
function c78211862.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查（chk==0）时，判断自己手牌中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手牌作为发动的代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果的目标选择（Target）函数，处理选择场上表侧表示怪兽作为对象的操作。
function c78211862.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动阶段检查（chk==0）时，判断场上是否存在至少1只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送系统提示信息，提示选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择场上1只表侧表示怪兽作为效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 定义效果的处理（Operation）函数，实现提升怪兽攻击力的效果。
function c78211862.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在Target阶段选择的第一个（也是唯一一个）对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时上升1500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1500)
		tc:RegisterEffect(e1)
	end
end
