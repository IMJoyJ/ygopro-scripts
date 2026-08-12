--カラクリ粉
-- 效果：
-- 选择场上表侧攻击表示存在的2只名字带有「机巧」的怪兽发动。选择的1只怪兽变成守备表示，另1只怪兽的攻击力直到结束阶段时上升变成守备表示的怪兽的攻击力数值。这个效果在战斗阶段时才能发动。
function c16708652.initial_effect(c)
	-- 创建效果对象并设置其类型为发动效果，具有取对象和伤害步骤限制属性，可于自由时点发动，发动条件为战斗阶段且未在伤害计算后，目标函数为c16708652.target，发动效果为c16708652.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c16708652.condition)
	e1:SetTarget(c16708652.target)
	e1:SetOperation(c16708652.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的时机条件：当前阶段为战斗阶段开始到战斗阶段结束之间，并且不在伤害计算后
function c16708652.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 返回当前阶段是否在战斗阶段开始到战斗阶段结束之间，并且满足aux.dscon条件
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 判断怪兽是否为表侧攻击表示、可以改变表示形式、攻击力大于等于1
function c16708652.atkfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition() and c:IsAttackAbove(1)
end
-- 判断怪兽是否为表侧攻击表示、名字带有「机巧」、并且场上存在满足filter2条件的怪兽作为目标
function c16708652.filter1(c,tp)
	return c16708652.atkfilter(c) and c:IsSetCard(0x11)
		-- 判断场上是否存在满足filter2条件的怪兽作为目标
		and Duel.IsExistingTarget(c16708652.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 判断怪兽是否为表侧攻击表示、名字带有「机巧」
function c16708652.filter2(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(0x11)
end
-- 判断怪兽是否为表侧攻击表示、可以成为效果对象
function c16708652.tgfilter(c,e)
	return c16708652.filter2(c) and c:IsCanBeEffectTarget(e)
end
-- 判断组中是否存在满足atkfilter条件的怪兽
function c16708652.gcheck(g)
	return g:IsExists(c16708652.atkfilter,1,nil)
end
-- 设置效果目标：检查是否存在满足filter1条件的怪兽作为目标，若存在则获取满足tgfilter条件的怪兽组，提示选择2只怪兽作为目标并设置为连锁对象
function c16708652.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否存在满足filter1条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c16708652.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 获取满足tgfilter条件的怪兽组
	local g=Duel.GetMatchingGroup(c16708652.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c16708652.gcheck,false,2,2)
	-- 将选择的怪兽组设置为当前效果的目标
	Duel.SetTargetCard(sg)
end
-- 判断怪兽是否为表侧攻击表示、可以改变表示形式
function c16708652.atkfilter2(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 发动效果：获取当前连锁相关的怪兽组，提示选择一只怪兽改变表示形式为守备表示，另一只怪兽的攻击力提升为该怪兽的攻击力数值
function c16708652.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁相关的怪兽组
	local g=Duel.GetTargetsRelateToChain()
	if #g==0 then return end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(16708652,0))  --"请选择要改变表示形式的怪兽"
	local tc1=g:FilterSelect(tp,c16708652.atkfilter,1,1,nil):GetFirst()
	if not tc1 then
		-- 提示玩家选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(16708652,0))  --"请选择要改变表示形式的怪兽"
		tc1=g:FilterSelect(tp,c16708652.atkfilter2,1,1,nil):GetFirst()
	end
	if not tc1 then return end
	local tc2=(g-tc1):GetFirst()
	-- 将选择的怪兽改变为守备表示，若成功且存在另一只怪兽则为该怪兽增加攻击力
	if Duel.ChangePosition(tc1,POS_FACEUP_DEFENSE)>0 and tc2 then
		-- 创建一个攻击力变更效果，使目标怪兽的攻击力增加选择怪兽的攻击力数值，效果在结束阶段重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc1:GetAttack())
		tc2:RegisterEffect(e1)
	end
end
