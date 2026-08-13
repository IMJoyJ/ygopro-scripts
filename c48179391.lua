--オレイカルコスの結界
-- 效果：
-- 这个卡名的卡在决斗中只能发动1张。
-- ①：作为这张卡的发动时的效果处理，自己场上有特殊召唤的怪兽存在的场合，那些怪兽全部破坏。
-- ②：自己不能从额外卡组把怪兽特殊召唤。
-- ③：自己场上的怪兽的攻击力上升500。
-- ④：自己场上有表侧攻击表示怪兽2只以上存在的场合，对方不能选择自己场上的攻击力最低的怪兽作为攻击对象。
-- ⑤：这张卡1回合只有1次不会被效果破坏。
function c48179391.initial_effect(c)
	-- 这个卡名的卡在决斗中只能发动1张。①：作为这张卡的发动时的效果处理，自己场上有特殊召唤的怪兽存在的场合，那些怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,48179391+EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c48179391.acttg)
	e1:SetOperation(c48179391.actop)
	c:RegisterEffect(e1)
	-- ②：自己不能从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c48179391.sumlimit)
	c:RegisterEffect(e2)
	-- ③：自己场上的怪兽的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	-- ⑤：这张卡1回合只有1次不会被效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e4:SetCountLimit(1)
	e4:SetValue(c48179391.valcon)
	c:RegisterEffect(e4)
	-- ④：自己场上有表侧攻击表示怪兽2只以上存在的场合，对方不能选择自己场上的攻击力最低的怪兽作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetCondition(c48179391.atkcon)
	e5:SetValue(c48179391.atlimit)
	c:RegisterEffect(e5)
end
-- 此过滤函数用于判断怪兽是否为特殊召唤怪兽，即召唤类型包含SUMMON_TYPE_SPECIAL。
function c48179391.desfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 发动时的目标处理：无发动条件限制；检索自己场上所有特殊召唤的怪兽，并设置破坏这些怪兽的操作信息。
function c48179391.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上所有特殊召唤的怪兽，存入组g。
	local g=Duel.GetMatchingGroup(c48179391.desfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置本次效果处理为破坏操作，对象为g中的怪兽，数量为g的怪兽数，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 发动时的效果处理：再次获取自己场上所有特殊召唤的怪兽，若有则将其全部破坏。
function c48179391.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有特殊召唤的怪兽，存入组g。
	local g=Duel.GetMatchingGroup(c48179391.desfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 以效果原因将组g中的怪兽全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 此函数作为限制特殊召唤的目标判定：若尝试特殊召唤的怪兽位于额外卡组，则禁止该特殊召唤。
function c48179391.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 此函数判断本次破坏是否为效果破坏，若是效果破坏则允许使用1回合1次的无效破坏效果。
function c48179391.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 此函数为④的发动条件：自己场上有2只以上表侧攻击表示怪兽时满足条件。
function c48179391.atkcon(e)
	-- 检查自己场上是否存在至少2只表侧攻击表示怪兽。
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil,POS_FACEUP_ATTACK)
end
-- 此过滤函数用于判断怪兽是否为表侧表示且攻击力低于指定攻击力。
function c48179391.atkfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
-- 此函数作为④的限制条件：对方只能选择自己场上攻击力最低的表侧表示怪兽为攻击对象；若不存在攻击力更低的表侧攻击表示怪兽，则允许选择该怪兽。
function c48179391.atlimit(e,c)
	-- 判断c是否为表侧表示，且自己场上不存在攻击力低于c攻击力的表侧表示怪兽，即c是攻击力最低的表侧怪兽。
	return c:IsFaceup() and not Duel.IsExistingMatchingCard(c48179391.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,c,c:GetAttack())
end
