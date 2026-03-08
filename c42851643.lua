--穿孔重機ドリルジャンボ
-- 效果：
-- 这张卡召唤成功时，可以把自己场上的全部机械族怪兽的等级上升1星。这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。此外，这张卡攻击的场合，伤害步骤结束时变成守备表示。
function c42851643.initial_effect(c)
	-- 这张卡召唤成功时，可以把自己场上的全部机械族怪兽的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42851643,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c42851643.lvtg)
	e1:SetOperation(c42851643.lvop)
	c:RegisterEffect(e1)
	-- 这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c42851643.poscon)
	e2:SetOperation(c42851643.posop)
	c:RegisterEffect(e2)
	-- 此外，这张卡攻击的场合，伤害步骤结束时变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选场上表侧表示、等级高于1、种族为机械的怪兽。
function c42851643.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsRace(RACE_MACHINE)
end
-- 检查场上是否存在满足条件的机械族怪兽，用于发动等级上升效果的条件判断。
function c42851643.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的机械族怪兽，用于发动等级上升效果的条件判断。
	if chk==0 then return Duel.IsExistingMatchingCard(c42851643.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 将场上所有满足条件的机械族怪兽等级上升1星。
function c42851643.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的机械族怪兽组成卡片组。
	local g=Duel.GetMatchingGroup(c42851643.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为满足条件的机械族怪兽注册等级上升1星的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 判断该卡是否为本次战斗的攻击怪兽且参与了战斗。
function c42851643.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该卡是否为本次战斗的攻击怪兽且参与了战斗。
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
-- 在伤害步骤结束时，若该卡处于攻击表示则将其变为守备表示。
function c42851643.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将该卡变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
