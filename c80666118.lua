--レッド・デーモンズ・ドラゴン・スカーライト
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡的卡名只要在场上·墓地存在当作「红莲魔龙」使用。
-- ②：1回合1次，自己主要阶段才能发动。这张卡以外的持有这张卡的攻击力以下的攻击力的特殊召唤的效果怪兽全部破坏。那之后，给与对方这个效果破坏的怪兽数量×500伤害。
function c80666118.initial_effect(c)
	-- 添加同调召唤手续，要求为调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 使这张卡在场上·墓地存在时，卡名当作「红莲魔龙」使用
	aux.EnableChangeCode(c,70902743,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：1回合1次，自己主要阶段才能发动。这张卡以外的持有这张卡的攻击力以下的攻击力的特殊召唤的效果怪兽全部破坏。那之后，给与对方这个效果破坏的怪兽数量×500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c80666118.destg)
	e2:SetOperation(c80666118.desop)
	c:RegisterEffect(e2)
end
-- 过滤出场上表侧表示、攻击力在指定数值以下、特殊召唤的效果怪兽
function c80666118.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
		and c:IsType(TYPE_EFFECT)
end
-- 效果②的发动准备与目标确认函数
function c80666118.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动时，检查场上是否存在至少1只除这张卡以外、满足破坏条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80666118.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetAttack()) end
	-- 获取场上所有除这张卡以外、满足破坏条件的怪兽组
	local g=Duel.GetMatchingGroup(c80666118.filter,tp,LOCATION_MZONE,LOCATION_MZONE,c,c:GetAttack())
	-- 设置连锁信息，表示该效果的操作分类包含破坏，目标为上述获取的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置连锁信息，表示该效果的操作分类包含伤害，对象为对方玩家，预计伤害数值为破坏怪兽数量乘以500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- 效果②的破坏与伤害处理函数
function c80666118.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 在效果处理时，重新获取场上除这张卡以外、满足破坏条件的怪兽组
	local g=Duel.GetMatchingGroup(c80666118.filter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e),c:GetAttack())
	-- 因效果破坏上述获取的怪兽组，并记录实际被破坏的怪兽数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 中断当前效果处理，使后续的伤害处理与破坏处理不视为同时进行
		Duel.BreakEffect()
		-- 给与对方玩家等同于“实际破坏的怪兽数量 × 500”数值的效果伤害
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
