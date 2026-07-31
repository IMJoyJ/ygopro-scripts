--エーリアン・キッズ
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，每次对方场上有怪兽特殊召唤，给那个时候特殊召唤的怪兽放置1个A指示物。有A指示物放置的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
function c64160836.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，每次对方场上有怪兽特殊召唤，给那个时候特殊召唤的怪兽放置1个A指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c64160836.ctop)
	c:RegisterEffect(e1)
	-- 有A指示物放置的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c64160836.adcon)
	e2:SetTarget(c64160836.adtg)
	e2:SetValue(c64160836.adval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
c64160836.counter_add_list={0x100e}
c64160836.mentioned_counter={
	[0x100e]=true,
}
-- 放置指示物处理：遍历对方特殊召唤的怪兽，为其放置1个A指示物
function c64160836.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsFaceup() and tc:IsControler(1-tp) then
			tc:AddCounter(0x100e,1)
		end
		tc=eg:GetNext()
	end
end
-- 攻守下降条件：伤害计算阶段且存在攻击目标
function c64160836.adcon(e)
	-- 检查当前阶段是否为伤害计算阶段且存在攻击目标
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 攻守下降过滤条件：该怪兽拥有A指示物且其战斗对象为「外星」怪兽
function c64160836.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 攻守下降数值计算：此卡上的A指示物数量×-300
function c64160836.adval(e,c)
	return c:GetCounter(0x100e)*-300
end
