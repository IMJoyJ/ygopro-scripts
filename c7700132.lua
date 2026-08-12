--ワーム・ノーブル
-- 效果：
-- 反转：被对方怪兽的攻击反转的场合，给与对方基本分向这张卡攻击的对方怪兽的攻击力一半数值的伤害。
function c7700132.initial_effect(c)
	-- 反转：被对方怪兽的攻击反转的场合，给与对方基本分向这张卡攻击的对方怪兽的攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(c7700132.damtg)
	e1:SetOperation(c7700132.damop)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与操作信息设置函数
function c7700132.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 判断当前是否在伤害步骤且自身是攻击对象（即被攻击反转）
	if Duel.GetCurrentPhase()==PHASE_DAMAGE and e:GetHandler()==Duel.GetAttackTarget() then
		-- 设置效果的对象玩家为对方
		Duel.SetTargetPlayer(1-tp)
		-- 设置效果的对象参数为攻击怪兽攻击力的一半（向下取整）
		Duel.SetTargetParam(math.floor(Duel.GetAttacker():GetAttack()/2))
		-- 设置当前连锁的操作信息为给与对方攻击怪兽攻击力一半的伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(Duel.GetAttacker():GetAttack()/2))
	end
end
-- 效果处理的执行函数
function c7700132.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，再次确认当前是否在伤害步骤且自身为攻击对象
	if Duel.GetCurrentPhase()==PHASE_DAMAGE and e:GetHandler()==Duel.GetAttackTarget() then
		-- 获取当前连锁中设定的目标玩家和伤害数值
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 因效果给与目标玩家对应的伤害
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
