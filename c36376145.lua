--魂の一撃
-- 效果：
-- 自己基本分是4000以下的场合，自己场上的怪兽和对方怪兽进行战斗的攻击宣言时把基本分支付一半，选择自己场上1只怪兽才能发动。选择的怪兽的攻击力直到对方的结束阶段时上升自己基本分比4000低的数值。「魂之一击」在1回合只能发动1张。
function c36376145.initial_effect(c)
	-- 创建效果，设置为发动时改变攻击力、在攻击宣言时发动、需要选择对象、一回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,36376145+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c36376145.condition)
	e1:SetCost(c36376145.cost)
	e1:SetTarget(c36376145.target)
	e1:SetOperation(c36376145.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：自己基本分不超过4000且对方有攻击目标
function c36376145.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 自己基本分不超过4000且对方有攻击目标
	return Duel.GetLP(tp)<=4000 and Duel.GetAttackTarget()~=nil
end
-- 支付费用：支付自己当前基本分的一半
function c36376145.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付自己当前基本分的一半
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 选择目标：选择自己场上1只表侧表示的怪兽
function c36376145.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 判断是否有满足条件的怪兽可选
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 发动效果：使选择的怪兽攻击力上升4000减去自己基本分的数值
function c36376145.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的攻击力上升4000减去自己基本分的数值，直到对方结束阶段
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		-- 攻击力上升4000减去自己基本分的数值
		e1:SetValue(4000-Duel.GetLP(tp))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
