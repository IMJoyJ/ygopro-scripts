--エーリアン・ウォリアー
-- 效果：
-- 这张卡被战斗破坏送去墓地时，破坏这张卡的怪兽放置2个A指示物。放置有A指示物的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
function c98719226.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，破坏这张卡的怪兽放置2个A指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98719226,0))  --"放置「A指示物」"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c98719226.ctcon)
	e1:SetOperation(c98719226.ctop)
	c:RegisterEffect(e1)
	-- 放置有A指示物的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c98719226.adcon)
	e2:SetTarget(c98719226.adtg)
	e2:SetValue(c98719226.adval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
c98719226.counter_add_list={0x100e}
-- 判断此卡是否被战斗破坏并送去墓地
function c98719226.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 在破坏此卡的怪兽上放置2个A指示物
function c98719226.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetReasonCard()
	if tc:IsFaceup() and tc:IsRelateToBattle() then
		tc:AddCounter(0x100e,2)
	end
end
-- 判断是否在伤害计算时进行战斗
function c98719226.adcon(e)
	-- 返回当前阶段是否为伤害计算阶段且存在攻击对象
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 筛选出带有A指示物且与名字带有「外星」的怪兽进行战斗的怪兽
function c98719226.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 计算并返回攻击力下降的数值（每个A指示物下降300）
function c98719226.adval(e,c)
	return c:GetCounter(0x100e)*-300
end
