--オレイカルコスの結界
-- 效果：
-- 这个卡名的卡在决斗中只能发动1张。
-- ①：作为这张卡的发动时的效果处理，自己场上有特殊召唤的怪兽存在的场合，那些怪兽全部破坏。
-- ②：自己不能从额外卡组把怪兽特殊召唤。
-- ③：自己场上的怪兽的攻击力上升500。
-- ④：自己场上有表侧攻击表示怪兽2只以上存在的场合，对方不能选择自己场上的攻击力最低的怪兽作为攻击对象。
-- ⑤：这张卡1回合只有1次不会被效果破坏。
function c48179391.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，自己场上有特殊召唤的怪兽存在的场合，那些怪兽全部破坏。
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
-- 过滤出场上特殊召唤的怪兽
function c48179391.desfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 设置发动时的处理目标为场上所有特殊召唤的怪兽
function c48179391.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c48179391.desfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行发动时的效果处理，破坏场上所有特殊召唤的怪兽
function c48179391.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c48179391.desfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 将场上所有特殊召唤的怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 限制从额外卡组特殊召唤怪兽
function c48179391.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 判断是否为效果破坏
function c48179391.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 检查自己场上有无至少2只表侧攻击表示怪兽
function c48179391.atkcon(e)
	-- 检查自己场上有无至少2只表侧攻击表示怪兽
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil,POS_FACEUP_ATTACK)
end
-- 过滤出攻击力低于指定值的表侧表示怪兽
function c48179391.atkfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
-- 设置不能选择攻击力最低的怪兽为攻击对象
function c48179391.atlimit(e,c)
	-- 判断目标怪兽是否为表侧表示且其攻击力不为场上最低
	return c:IsFaceup() and not Duel.IsExistingMatchingCard(c48179391.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,c,c:GetAttack())
end
