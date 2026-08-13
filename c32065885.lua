--痛恨の訴え
-- 效果：
-- 对方怪兽的直接攻击让自己受到战斗伤害时才能发动。对方场上表侧表示存在的1只守备力最高的怪兽的控制权直到下次的自己的结束阶段时得到。这个效果得到控制权的怪兽的效果无效化，也不能攻击宣言。
function c32065885.initial_effect(c)
	-- 对方怪兽的直接攻击让自己受到战斗伤害时才能发动。对方场上表侧表示存在的1只守备力最高的怪兽的控制权直到下次的自己的结束阶段时得到。这个效果得到控制权的怪兽的效果无效化，也不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c32065885.ctlcon)
	e1:SetTarget(c32065885.ctltg)
	e1:SetOperation(c32065885.ctlop)
	c:RegisterEffect(e1)
end
-- 定义发动条件判定函数：在战斗伤害事件中确认是己方受到对方怪兽直接攻击造成的战斗伤害，满足此条件时效果才可发动。
function c32065885.ctlcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定伤害承受者为效果发动者（ep==tp）、攻击对象为空（直接攻击）且攻击怪兽为对方控制（IsControler(1-tp)），即‘对方怪兽的直接攻击让自己受到战斗伤害’。
	return ep==tp and Duel.GetAttackTarget()==nil and Duel.GetAttacker():IsControler(1-tp)
end
-- 定义效果对象筛选函数：选取对方场上表侧表示且控制权可以被改变、守备力大于等于0的怪兽。
function c32065885.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged() and c:IsDefenseAbove(0)
end
-- 定义效果发动时的目标判定与操作信息设置函数：检查对方场上是否存在符合条件的表侧表示怪兽，并预设定改变控制权的处理信息。
function c32065885.ctltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查对方场上是否存在至少1只满足filter条件的表侧表示怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c32065885.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置当前连锁的操作信息：效果类别为改变控制权，预计处理1张对方主要怪兽区的卡，用于影响后续相关效果判定。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- 定义效果处理时筛选函数：选取对方场上表侧表示且守备力大于等于0的怪兽（实际以守备力最高为挑选目标）。
function c32065885.filter1(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 定义效果处理函数：从对方场上表侧表示怪兽中选出守备力最高的一只（复数则由玩家选择），若控制权夺取成功则直到下次自己的结束阶段得到控制权，并使其效果无效化且不能攻击宣言。
function c32065885.ctlop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上全部满足filter1条件的表侧表示怪兽组，作为选择守备力最高怪兽的候补集合。
	local g=Duel.GetMatchingGroup(c32065885.filter1,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local sg=g:GetMaxGroup(Card.GetDefense)
	if sg:GetCount()>1 then
		-- 当守备力最高的怪兽有多只时，弹出‘请选择要改变控制权的怪兽’的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		sg=sg:Select(tp,1,1,nil)
		-- 为选中的怪兽显示被选为对象的动画效果，并将该卡记录为当前连锁的（广义）对象。
		Duel.HintSelection(sg)
	end
	local tc=sg:GetFirst()
	-- 尝试取得所选怪兽的控制权直到第2次结束阶段（PHASE_END，2），若成功（返回值不为0），则继续对其附加效果无效化与不能攻击的永续效果。
	if Duel.GetControl(tc,tp,PHASE_END,2)~=0 then
		local c=e:GetHandler()
		-- '这个效果得到控制权的怪兽的效果无效化'——赋予该怪兽效果无效化效果（EFFECT_DISABLE），使其怪兽效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- '这个效果得到控制权的怪兽的效果无效化'——赋予该怪兽效果无效化效果（EFFECT_DISABLE_EFFECT），使其效果无效化，且该无效状态不因怪兽离场而解除。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
		-- '也不能攻击宣言'——赋予该怪兽不能攻击宣言的效果。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e3)
	end
end
