--ポセイドン・ウェーブ
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。把1只对方怪兽的攻击无效。自己场上有鱼族·海龙族·水族怪兽表侧表示存在的场合，给与对方基本分那个数量×800的数值的伤害。
function c25642998.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。把1只对方怪兽的攻击无效。自己场上有鱼族·海龙族·水族怪兽表侧表示存在的场合，给与对方基本分那个数量×800的数值的伤害。
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
-- 效果发动条件判定：仅在对方回合且对方怪兽攻击宣言时才能发动（当前玩家不是回合玩家）。
function c25642998.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定效果发动者不是当前回合玩家，保证该卡只能在对方回合发动。
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤函数：选出自己场上表侧表示且种族为鱼族、海龙族、水族的怪兽，用于计算伤害数量。
function c25642998.dfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 发动时处理：选择攻击宣言的怪兽为效果对象，并统计自己场上符合条件的怪兽数量；若伤害值大于0，则登记伤害操作信息。
function c25642998.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前正在进行攻击宣言的对方怪兽。
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为该效果的对象（取对象效果），并使其与当前连锁关联，供后续处理时获取。
	Duel.SetTargetCard(tg)
	-- 统计自己场上表侧表示的鱼族·海龙族·水族怪兽数量，乘以800得到预计伤害值。
	local dam=Duel.GetMatchingGroupCount(c25642998.dfilter,tp,LOCATION_MZONE,0,nil)*800
	if dam>0 then
		-- 登记连锁操作信息：本连锁将造成CATEGORY_DAMAGE伤害，目标为对方玩家，伤害值约为dam，使其他卡能检测到此伤害效果。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- 效果处理：若对象仍与效果关联且攻击无效成功，则按自己场上符合条件的怪兽数量重新计算伤害并给予对方。
function c25642998.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理阶段的对象卡（被无效攻击的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查对象是否仍与效果关联，若是则无效该攻击。
	if tc:IsRelateToEffect(e) and Duel.NegateAttack() then
		-- 重新统计自己场上符合条件的怪兽数量并乘以800，得到当前实际伤害值。
		local dam=Duel.GetMatchingGroupCount(c25642998.dfilter,tp,LOCATION_MZONE,0,nil)*800
		if dam>0 then
			-- 以效果伤害的形式给与对方玩家dam点伤害。
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
