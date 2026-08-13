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
-- 每次对方场上有怪兽特殊召唤成功时，逐个检查那批特殊召唤的怪兽，给其中表侧表示且由对方控制的怪兽各放置1个A指示物。
function c64160836.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsFaceup() and tc:IsControler(1-tp) then
			tc:AddCounter(0x100e,1)
		end
		tc=eg:GetNext()
	end
end
-- 攻击力变化效果的适用条件：仅在伤害计算时且存在攻击对象（即有怪兽进行战斗）时适用。
function c64160836.adcon(e)
	-- 判断当前是否处于伤害计算时，并且存在攻击对象，两者都满足时才适用攻守下降效果。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 选定适用攻守下降的怪兽：该怪兽放置有A指示物，并且其战斗对象是名字带有「外星」的怪兽。
function c64160836.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 计算攻击力·守备力的变化值：该怪兽每有1个A指示物，攻击力·守备力就下降300（返回负值）。
function c64160836.adval(e,c)
	return c:GetCounter(0x100e)*-300
end
