--カラクリ粉
-- 效果：
-- 选择场上表侧攻击表示存在的2只名字带有「机巧」的怪兽发动。选择的1只怪兽变成守备表示，另1只怪兽的攻击力直到结束阶段时上升变成守备表示的怪兽的攻击力数值。这个效果在战斗阶段时才能发动。
function c16708652.initial_effect(c)
	-- 选择场上表侧攻击表示存在的2只名字带有「机巧」的怪兽发动。选择的1只怪兽变成守备表示，另1只怪兽的攻击力直到结束阶段时上升变成守备表示的怪兽的攻击力数值。这个效果在战斗阶段时才能发动。
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
-- 效果发动条件判定：当前阶段处于战斗阶段（从战斗阶段开始到战斗阶段结束）且满足伤害步骤限制（伤害计算前），从而实现“这个效果在战斗阶段时才能发动”。
function c16708652.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	-- 返回条件是否成立：当前阶段为战斗阶段开始至战斗阶段结束之间，并且不在伤害计算后，满足战斗阶段内可发动的时机限制。
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 筛选可作为‘变成守备表示’对象的候选怪兽：表侧攻击表示、可以变更表示形式、攻击力不低于1。
function c16708652.atkfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition() and c:IsAttackAbove(1)
end
-- 筛选第一位对象：自身必须是表侧攻击表示的名字带有「机巧」的怪兽，且能变更表示形式、攻击力≥1，同时场上还存在另一只可被选择为对象的表侧攻击表示「机巧」怪兽。
function c16708652.filter1(c,tp)
	return c16708652.atkfilter(c) and c:IsSetCard(0x11)
		-- 追加判定：场上存在另一只满足filter2（表侧攻击表示的名字带有「机巧」）且能成为效果对象的「机巧」怪兽可被选择。
		and Duel.IsExistingTarget(c16708652.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 筛选名字带有「机巧」且表侧攻击表示的怪兽，作为另一只可被选择的对象。
function c16708652.filter2(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(0x11)
end
-- 筛选可作为效果对象的名字带有「机巧」且表侧攻击表示的怪兽，并确认其能成为当前效果的对象。
function c16708652.tgfilter(c,e)
	return c16708652.filter2(c) and c:IsCanBeEffectTarget(e)
end
-- 检查所选的2只怪兽中是否至少存在1只满足atkfilter（表侧攻击表示、可变更表示形式、攻击力≥1），以保证效果处理时能选出1只变成守备表示。
function c16708652.gcheck(g)
	return g:IsExists(c16708652.atkfilter,1,nil)
end
-- 效果发动时的对象选择处理：先判断是否存在满足条件的2只「机巧」怪兽，若存在则在所有可成为对象的「机巧」怪兽中让玩家选择2只，并将选择结果设置为连锁对象。
function c16708652.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动时合法性检测：确认场上是否存在至少1只满足filter1的「机巧」怪兽（即自身可变更表示形式且另有其他「机巧」怪兽可被选择）。
	if chk==0 then return Duel.IsExistingTarget(c16708652.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 获取双方怪兽区中所有可成为效果对象的表侧攻击表示「机巧」怪兽，作为玩家选择的候选集合。
	local g=Duel.GetMatchingGroup(c16708652.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	-- 向当前玩家显示‘请选择效果的对象’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c16708652.gcheck,false,2,2)
	-- 将玩家选择的2只怪兽设置为当前连锁的对象，用于效果处理时关联这些卡。
	Duel.SetTargetCard(sg)
end
-- 筛选可变更表示形式的表侧攻击表示怪兽（不要求攻击力≥1），作为备选的变成守备表示的对象。
function c16708652.atkfilter2(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 效果处理操作：从连锁对象中选择1只怪兽变成表侧守备表示，若成功则令另1只怪兽攻击力上升该怪兽的攻击力数值，直到结束阶段。
function c16708652.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择且仍与当前连锁相关的2只对象怪兽；若对象已离场或联系重置，相关对象会减少。
	local g=Duel.GetTargetsRelateToChain()
	if #g==0 then return end
	-- 向玩家显示‘请选择要改变表示形式的怪兽’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(16708652,0))  --"请选择要改变表示形式的怪兽"
	local tc1=g:FilterSelect(tp,c16708652.atkfilter,1,1,nil):GetFirst()
	if not tc1 then
		-- 当按原筛选条件找不到可变更表示形式的怪兽时，再次向玩家显示‘请选择要改变表示形式的怪兽’的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(16708652,0))  --"请选择要改变表示形式的怪兽"
		tc1=g:FilterSelect(tp,c16708652.atkfilter2,1,1,nil):GetFirst()
	end
	if not tc1 then return end
	local tc2=(g-tc1):GetFirst()
	-- 将选中的怪兽tc1变为表侧守备表示；若变更成功并且存在另1只对象tc2，则继续为tc2上升攻击力。
	if Duel.ChangePosition(tc1,POS_FACEUP_DEFENSE)>0 and tc2 then
		-- 另1只怪兽的攻击力直到结束阶段时上升变成守备表示的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc1:GetAttack())
		tc2:RegisterEffect(e1)
	end
end
