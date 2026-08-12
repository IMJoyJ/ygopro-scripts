--電磁シールド
-- 效果：
-- 自己场上表侧守备表示存在的3星以下的雷族怪兽不会被战斗破坏。自己场上有怪兽表侧攻击表示存在的场合，这张卡破坏。
function c91107093.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上表侧守备表示存在的3星以下的雷族怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c91107093.infilter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 自己场上有怪兽表侧攻击表示存在的场合，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(c91107093.descon)
	c:RegisterEffect(e3)
end
-- 过滤守备表示、3星以下且是雷族的怪兽
function c91107093.infilter(e,c)
	return c:IsDefensePos() and c:IsLevelBelow(3) and c:IsRace(RACE_THUNDER)
end
-- 过滤表侧攻击表示的怪兽
function c91107093.filter(c)
	return c:IsFaceup() and c:IsAttackPos()
end
-- 判断自己场上是否存在表侧攻击表示怪兽的自我破坏条件函数
function c91107093.descon(e)
	-- 检查自己场上是否存在至少1只表侧攻击表示的怪兽
	return Duel.IsExistingMatchingCard(c91107093.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
