--エレメント・ザウルス
-- 效果：
-- 这只怪兽在场上有特定属性的怪兽存在的场合，得到以下的效果。
-- ●炎属性：这张卡攻击力上升500。
-- ●地属性：这张卡战斗破坏的怪兽的效果无效化。
function c92755808.initial_effect(c)
	-- 这只怪兽在场上有特定属性的怪兽存在的场合，得到以下的效果。●炎属性：这张卡攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetCondition(c92755808.atkcon)
	c:RegisterEffect(e1)
	-- 这只怪兽在场上有特定属性的怪兽存在的场合，得到以下的效果。●地属性：这张卡战斗破坏的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c92755808.discon)
	e2:SetOperation(c92755808.disop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否为表侧表示且属于指定属性
function c92755808.filter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 攻击力上升效果的生效条件：场上存在炎属性怪兽
function c92755808.atkcon(e)
	-- 检查双方怪兽区是否存在至少1张表侧表示的炎属性怪兽
	return Duel.IsExistingMatchingCard(c92755808.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_FIRE)
end
-- 效果无效化效果的触发条件：自身未被战斗破坏，且与自身进行战斗的怪兽被战斗破坏，同时场上存在地属性怪兽
function c92755808.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		-- 并且双方怪兽区存在至少1张表侧表示的地属性怪兽
		and Duel.IsExistingMatchingCard(c92755808.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_EARTH)
end
-- 效果无效化效果的执行操作：使被战斗破坏的怪兽的效果无效化
function c92755808.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 这张卡战斗破坏的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x17a0000)
	bc:RegisterEffect(e1)
	-- 这张卡战斗破坏的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x17a0000)
	bc:RegisterEffect(e2)
end
