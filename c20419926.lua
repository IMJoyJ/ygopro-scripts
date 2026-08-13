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
	-- 这个卡名的①的效果1回合只能使用1次。①：自己·对方的战斗阶段，从自己墓地把1只暗属性连接怪兽除外，以自己场上1只「枪管」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升因为这张卡发动而除外的怪兽的攻击力数值。
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
-- 发动条件判定：当前阶段必须处于战斗阶段开始时到战斗阶段结束之间，且满足伤害步骤中允许发动的限定条件（不能在伤害计算时发动）。
function c20419926.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前阶段是否在战斗阶段范围内（PHASE_BATTLE_START至PHASE_BATTLE），并进一步用aux.dscon限制在伤害步骤内只能在伤害计算前发动。
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 费用筛选：从墓地选择1只暗属性连接怪兽，且攻击力至少为1，并能够作为代价除外。
function c20419926.costfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackAbove(1) and c:IsAbleToRemoveAsCost()
end
-- 支付代价：从自己墓地选择1只符合条件的暗属性连接怪兽除外，并记录其攻击力数值供后续效果使用。
function c20419926.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价确认阶段检查自己墓地是否存在至少1只符合条件的暗属性连接怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c20419926.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择卡片的提示，提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1只满足costfilter条件的暗属性连接怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c20419926.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local atk=g:GetFirst():GetAttack()
	e:SetLabel(atk)
	-- 将选中的怪兽以表侧表示除外，除外原因为代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 对象筛选：自己场上表侧表示且卡名含有「枪管」字段的怪兽。
function c20419926.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10f)
end
-- 取对象：选择自己场上1只表侧表示的「枪管」怪兽作为效果对象。
function c20419926.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c20419926.atkfilter(chkc) end
	-- 在目标确认阶段检查自己场上是否存在至少1只符合条件的「枪管」怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c20419926.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择卡片的提示，提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家从自己场上选择1只表侧表示的「枪管」怪兽作为效果对象。
	Duel.SelectTarget(tp,c20419926.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使对象怪兽的攻击力上升因发动这张卡而除外的怪兽的攻击力数值，直到回合结束。
function c20419926.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时上升因为这张卡发动而除外的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
