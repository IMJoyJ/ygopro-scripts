--魂の一撃
-- 效果：
-- 自己基本分是4000以下的场合，自己场上的怪兽和对方怪兽进行战斗的攻击宣言时把基本分支付一半，选择自己场上1只怪兽才能发动。选择的怪兽的攻击力直到对方的结束阶段时上升自己基本分比4000低的数值。「魂之一击」在1回合只能发动1张。
function c36376145.initial_effect(c)
	-- 自己基本分是4000以下的场合，自己场上的怪兽和对方怪兽进行战斗的攻击宣言时把基本分支付一半，选择自己场上1只怪兽才能发动。选择的怪兽的攻击力直到对方的结束阶段时上升自己基本分比4000低的数值。「魂之一击」在1回合只能发动1张。
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
-- 发动条件判定：自己基本分在4000以下，且当前存在攻击目标（发生了攻击宣言），满足条件才允许发动。
function c36376145.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真当自己LP≤4000且场上存在攻击目标，即满足发动所需的基本分和攻击宣言条件。
	return Duel.GetLP(tp)<=4000 and Duel.GetAttackTarget()~=nil
end
-- 发动代价处理：检查代价时无条件视为可支付；实际发动时支付当前LP一半（向下取整）作为代价。
function c36376145.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付自己当前LP一半（向下取整）的数值作为这张卡的发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 取对象处理：选择自己场上表侧表示存在的1只怪兽作为对象。若为连锁中对已选对象的合法性检查，则对象必须是自己场上表侧表示的怪兽；若无对象则不能发动，并让玩家选择对象。
function c36376145.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 发动时检查是否存在至少1只自己场上表侧表示的怪兽可以成为对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示，提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1张表侧表示的怪兽，并将该卡设为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽，若对象仍与效果关联且表侧表示，则为其赋予攻击力上升效果，数值为4000减去当前LP，持续到对方结束阶段。
function c36376145.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的攻击力直到对方的结束阶段时上升自己基本分比4000低的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		-- 设置攻击力上升的数值为4000减去当前LP，即基本分比4000低的数值。
		e1:SetValue(4000-Duel.GetLP(tp))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
