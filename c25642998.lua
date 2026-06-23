--ポセイドン・ウェーブ
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。把1只对方怪兽的攻击无效。自己场上有鱼族·海龙族·水族怪兽表侧表示存在的场合，给与对方基本分那个数量×800的数值的伤害。
function c25642998.initial_effect(c)
	-- 创建效果，设置为魔法卡发动效果，触发时机为攻击宣言时，条件为对方攻击，目标为攻击怪兽，效果为无效攻击并造成伤害
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c25642998.condition)
	e1:SetTarget(c25642998.target)
	e1:SetOperation(c25642998.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：只有在对方回合才能发动
function c25642998.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方玩家
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤函数：筛选出场上的表侧表示的鱼族、海龙族或水族怪兽
function c25642998.dfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 效果目标处理：设置攻击怪兽为效果对象，并计算满足条件的己方怪兽数量乘以800作为伤害值
function c25642998.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为连锁处理的对象
	Duel.SetTargetCard(tg)
	-- 计算己方场上满足条件的怪兽数量并乘以800作为伤害值
	local dam=Duel.GetMatchingGroupCount(c25642998.dfilter,tp,LOCATION_MZONE,0,nil)*800
	if dam>0 then
		-- 设置连锁操作信息，表示将对对方造成指定数值的伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- 效果发动处理：判断目标怪兽是否有效且攻击被成功无效，若成立则计算伤害并造成伤害
function c25642998.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否与当前效果相关联且攻击被成功无效
	if tc:IsRelateToEffect(e) and Duel.NegateAttack() then
		-- 再次计算己方场上满足条件的怪兽数量并乘以800作为伤害值
		local dam=Duel.GetMatchingGroupCount(c25642998.dfilter,tp,LOCATION_MZONE,0,nil)*800
		if dam>0 then
			-- 对对方玩家造成指定数值的伤害，伤害来源为效果
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
