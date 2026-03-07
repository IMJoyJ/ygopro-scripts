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
	-- 效果原文内容：①：对方怪兽的攻击宣言时才能发动。掷1次骰子，出现数目的效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c36708764.condition)
	e1:SetTarget(c36708764.target)
	e1:SetOperation(c36708764.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否为对方攻击宣言
function c36708764.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果作用：设置攻击怪兽为连锁对象并设置骰子操作信息
function c36708764.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：获取当前攻击怪兽
	local at=Duel.GetAttacker()
	-- 效果作用：将攻击怪兽设置为连锁对象
	Duel.SetTargetCard(at)
	-- 效果作用：设置操作信息为投掷1次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果原文内容：1·自己基本分变成一半。2·那次攻击变成对自己的直接攻击。3·选自己场上1只怪兽，攻击对象转移为那只怪兽进行伤害计算。4·选攻击怪兽以外的对方场上1只怪兽，攻击对象转移为那只怪兽进行伤害计算。5·那次攻击无效，给与对方那只怪兽的攻击力数值的伤害。6·那只对方怪兽破坏。
function c36708764.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：投掷1次骰子
	local dc=Duel.TossDice(tp,1)
	if dc==1 then
		-- 效果作用：获取当前玩家基本分
		local lp=Duel.GetLP(tp)
		-- 效果作用：将当前玩家基本分设置为一半
		Duel.SetLP(tp,math.ceil(lp/2))
		return
	elseif dc==2 then
		-- 效果作用：将攻击对象设置为自身进行直接攻击
		Duel.ChangeAttackTarget(nil)
		return
	elseif dc==3 then
		-- 效果作用：获取当前攻击对象
		local bc=Duel.GetAttackTarget()
		-- 效果作用：获取满足条件的己方怪兽组
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,bc)
		if g:GetCount()>0 then
			-- 效果作用：提示选择攻击对象
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(36708764,0))  --"请选择攻击对象"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 效果作用：获取当前攻击怪兽
			local at=Duel.GetAttacker()
			if at:IsAttackable() and not at:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then
				-- 效果作用：进行攻击伤害计算
				Duel.CalculateDamage(at,tc)
			end
		end
		return
	elseif dc==4 then
		-- 效果作用：获取当前攻击怪兽
		local at=Duel.GetAttacker()
		-- 效果作用：获取满足条件的对方怪兽组
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,at)
		if g:GetCount()>0 then
			-- 效果作用：提示选择攻击对象
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(36708764,0))  --"请选择攻击对象"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 效果作用：获取当前攻击怪兽
			local at=Duel.GetAttacker()
			if at:IsAttackable() and not at:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then
				-- 效果作用：进行攻击伤害计算
				Duel.CalculateDamage(at,tc)
			end
		end
		return
	elseif dc==5 then
		-- 效果作用：获取当前连锁对象
		local at=Duel.GetFirstTarget()
		-- 效果作用：判断攻击怪兽是否有效且可无效攻击
		if at:IsRelateToEffect(e) and Duel.NegateAttack() and at:GetAttack()>0 then
			-- 效果作用：对对方造成攻击怪兽攻击力数值的伤害
			Duel.Damage(1-tp,at:GetAttack(),REASON_EFFECT)
		end
		return
	elseif dc==6 then
		-- 效果作用：获取当前连锁对象
		local at=Duel.GetFirstTarget()
		if at:IsRelateToEffect(e) and at:IsControler(1-tp) and at:IsType(TYPE_MONSTER) then
			-- 效果作用：破坏目标怪兽
			Duel.Destroy(at,REASON_EFFECT)
		end
	end
end
