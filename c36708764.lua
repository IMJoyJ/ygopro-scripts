--ルーレット・スパイダー
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。掷1次骰子，出现数目的效果适用。
-- 1·自己基本分变成一半。
-- 2·那次攻击变成对自己的直接攻击。
-- 3·选自己场上1只怪兽，攻击对象转移为那只怪兽进行伤害计算。
-- 4·选攻击怪兽以外的对方场上1只怪兽，攻击对象转移为那只怪兽进行伤害计算。
-- 5·那次攻击无效，给与对方那只怪兽的攻击力数值的伤害。
-- 6·那只对方怪兽破坏。
function c36708764.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。掷1次骰子，出现数目的效果适用。1·自己基本分变成一半。2·那次攻击变成对自己的直接攻击。3·选自己场上1只怪兽，攻击对象转移为那只怪兽进行伤害计算。4·选攻击怪兽以外的对方场上1只怪兽，攻击对象转移为那只怪兽进行伤害计算。5·那次攻击无效，给与对方那只怪兽的攻击力数值的伤害。6·那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c36708764.condition)
	e1:SetTarget(c36708764.target)
	e1:SetOperation(c36708764.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：必须是对方怪兽进行攻击宣言（即攻击宣言的玩家不是自己）时才能发动。
function c36708764.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 发动时的目标处理：无对象选择直接允许发动，并将攻击怪兽登记为效果关联对象，同时登记本次连锁包含掷骰子效果的操作信息。
function c36708764.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取进行攻击宣言的对方怪兽。
	local at=Duel.GetAttacker()
	-- 将攻击怪兽设置为当前效果的关联对象，用于后续效果处理时确认该怪兽。
	Duel.SetTargetCard(at)
	-- 登记操作信息：本次效果包含掷骰子（投1次），用于满足骰子相关时点和判定。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果处理：掷1次骰子，根据点数分别适用对应分支：1自己LP减半；2攻击改为直接攻击；3选自己场上1只怪兽转移攻击目标；4选对方场上其他怪兽转移攻击目标；5无效攻击并给予伤害；6破坏攻击怪兽。
function c36708764.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 发动方投1次骰子，返回点数存入dc。
	local dc=Duel.TossDice(tp,1)
	if dc==1 then
		-- 获取发动方当前基本分。
		local lp=Duel.GetLP(tp)
		-- 将发动方基本分变为当前值的一半（向上取整），即点数1的效果。
		Duel.SetLP(tp,math.ceil(lp/2))
		return
	elseif dc==2 then
		-- 将攻击对象改为直接攻击（nil表示不攻击怪兽而直接攻击玩家），即点数2的效果。
		Duel.ChangeAttackTarget(nil)
		return
	elseif dc==3 then
		-- 获取当前攻击的对象怪兽，用于后续选择时排除该怪兽。
		local bc=Duel.GetAttackTarget()
		-- 获取自己场上除当前攻击对象以外的怪兽，作为点数3可选转移攻击目标的候选。
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,bc)
		if g:GetCount()>0 then
			-- 向发动方显示“请选择攻击对象”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(36708764,0))  --"请选择攻击对象"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 获取攻击怪兽。
			local at=Duel.GetAttacker()
			if at:IsAttackable() and not at:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then
				-- 令攻击怪兽与选中的己方怪兽进行伤害计算，实现攻击对象转移并进入伤害计算。
				Duel.CalculateDamage(at,tc)
			end
		end
		return
	elseif dc==4 then
		-- 获取攻击怪兽。
		local at=Duel.GetAttacker()
		-- 获取对方场上除攻击怪兽以外的怪兽群，作为点数4可选转移攻击目标的候选。
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,at)
		if g:GetCount()>0 then
			-- 向发动方显示“请选择攻击对象”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(36708764,0))  --"请选择攻击对象"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 获取攻击怪兽。
			local at=Duel.GetAttacker()
			if at:IsAttackable() and not at:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then
				-- 令攻击怪兽与选中的对方怪兽进行伤害计算，实现攻击对象转移。
				Duel.CalculateDamage(at,tc)
			end
		end
		return
	elseif dc==5 then
		-- 获取发动时登记的攻击怪兽（效果关联对象）。
		local at=Duel.GetFirstTarget()
		-- 判断攻击怪兽仍与效果相关且攻击无效成功、攻击力大于0时，才继续执行伤害。
		if at:IsRelateToEffect(e) and Duel.NegateAttack() and at:GetAttack()>0 then
			-- 给予对方玩家该攻击怪兽攻击力数值的效果伤害，即点数5效果。
			Duel.Damage(1-tp,at:GetAttack(),REASON_EFFECT)
		end
		return
	elseif dc==6 then
		-- 获取发动时登记的攻击怪兽。
		local at=Duel.GetFirstTarget()
		if at:IsRelateToEffect(e) and at:IsControler(1-tp) and at:IsType(TYPE_MONSTER) then
			-- 破坏那只对方怪兽，即点数6效果。
			Duel.Destroy(at,REASON_EFFECT)
		end
	end
end
