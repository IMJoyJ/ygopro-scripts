--痛恨の訴え
-- 效果：
-- 对方怪兽的直接攻击让自己受到战斗伤害时才能发动。对方场上表侧表示存在的1只守备力最高的怪兽的控制权直到下次的自己的结束阶段时得到。这个效果得到控制权的怪兽的效果无效化，也不能攻击宣言。
function c32065885.initial_effect(c)
	-- 创建效果，设置为发动时点，触发条件为造成战斗伤害，目标为对方场上表侧表示存在的怪兽，操作为改变控制权
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c32065885.ctlcon)
	e1:SetTarget(c32065885.ctltg)
	e1:SetOperation(c32065885.ctlop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：对方怪兽的直接攻击让自己受到战斗伤害
function c32065885.ctlcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方受到战斗伤害的玩家为效果发动玩家，攻击怪兽没有攻击目标，攻击怪兽的控制者为对方
	return ep==tp and Duel.GetAttackTarget()==nil and Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤函数：满足条件的怪兽必须表侧表示、可以改变控制权、守备力大于等于0
function c32065885.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged() and c:IsDefenseAbove(0)
end
-- 设置效果目标：检查对方场上是否存在满足条件的怪兽，若存在则设置操作信息为改变控制权
function c32065885.ctltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c32065885.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息为改变控制权，目标为对方场上怪兽区的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- 过滤函数：满足条件的怪兽必须表侧表示、守备力大于等于0
function c32065885.filter1(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 效果处理函数：检索对方场上守备力最高的怪兽，若有多只则选择其一，然后改变其控制权并使其效果无效化且不能攻击
function c32065885.ctlop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方场上所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c32065885.filter1,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local sg=g:GetMaxGroup(Card.GetDefense)
	if sg:GetCount()>1 then
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		sg=sg:Select(tp,1,1,nil)
		-- 为选中的怪兽显示被选为对象的动画效果
		Duel.HintSelection(sg)
	end
	local tc=sg:GetFirst()
	-- 尝试改变选中怪兽的控制权，直到下次自己的结束阶段
	if Duel.GetControl(tc,tp,PHASE_END,2)~=0 then
		local c=e:GetHandler()
		-- 使该怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 使该怪兽的效果无效化（针对效果）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
		-- 使该怪兽不能攻击宣言
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e3)
	end
end
