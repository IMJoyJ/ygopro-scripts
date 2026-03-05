--ガンスリンガー・エクスキューション
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的战斗阶段，从自己墓地把1只暗属性连接怪兽除外，以自己场上1只「枪管」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升因为这张卡发动而除外的怪兽的攻击力数值。
function c20419926.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的战斗阶段，从自己墓地把1只暗属性连接怪兽除外，以自己场上1只「枪管」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升因为这张卡发动而除外的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20419926,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1,20419926)
	e2:SetCondition(c20419926.atkcon)
	e2:SetCost(c20419926.atkcost)
	e2:SetTarget(c20419926.atktg)
	e2:SetOperation(c20419926.atkop)
	c:RegisterEffect(e2)
end
-- 效果发动的时机为战斗阶段开始到战斗阶段结束之间，并且不能在伤害步骤中发动。
function c20419926.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前阶段是否为战斗阶段开始到战斗阶段结束之间，并且满足不能在伤害步骤发动的条件。
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 用于筛选满足条件的墓地中的暗属性连接怪兽作为除外的代价。
function c20419926.costfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackAbove(1) and c:IsAbleToRemoveAsCost()
end
-- 检查是否有满足条件的暗属性连接怪兽在墓地，若有则选择一张并除外，同时将该怪兽的攻击力记录到效果标签中。
function c20419926.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即墓地是否存在满足条件的暗属性连接怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c20419926.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从玩家墓地中选择一张满足条件的暗属性连接怪兽。
	local g=Duel.SelectMatchingCard(tp,c20419926.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local atk=g:GetFirst():GetAttack()
	e:SetLabel(atk)
	-- 将选中的怪兽从墓地除外，并作为效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 用于筛选场上满足条件的「枪管」怪兽作为效果的对象。
function c20419926.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10f)
end
-- 检查是否有满足条件的「枪管」怪兽在场上，若有则选择一只作为效果对象。
function c20419926.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c20419926.atkfilter(chkc) end
	-- 检查是否满足发动条件，即场上是否存在满足条件的「枪管」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c20419926.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择要作为效果对象的表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上满足条件的一只「枪管」怪兽作为效果对象。
	Duel.SelectTarget(tp,c20419926.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将效果对象怪兽的攻击力提升等于被除外怪兽的攻击力数值。
function c20419926.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽获得一个直到回合结束时生效的攻击力提升效果，提升数值等于被除外怪兽的攻击力。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
