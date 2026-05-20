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
-- 遍历特殊召唤成功的怪兽，若其在对方场上表侧表示存在，则给其放置1个A指示物
function c64160836.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsFaceup() and tc:IsControler(1-tp) then
			tc:AddCounter(0x100e,1)
		end
		tc=eg:GetNext()
	end
end
-- 设置攻击力·守备力下降效果的生效条件为伤害计算时且存在战斗对象
function c64160836.adcon(e)
	-- 判断当前是否为伤害计算阶段，且存在攻击对象（即正在进行战斗）
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 筛选自身带有A指示物，且其战斗对象是名字带有「外星」的怪兽
function c64160836.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 计算并返回攻击力·守备力下降的数值，即每个A指示物下降300点
function c64160836.adval(e,c)
	return c:GetCounter(0x100e)*-300
end
