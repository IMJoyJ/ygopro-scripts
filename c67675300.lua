--スノーダスト・ドラゴン
-- 效果：
-- 这张卡可以把场上4个冰指示物取除，从手卡特殊召唤。只要这张卡在场上表侧表示存在，这张卡以外的有冰指示物放置的怪兽不能攻击，也不能作表示形式的变更。
function c67675300.initial_effect(c)
	-- 这张卡可以把场上4个冰指示物取除，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c67675300.spcon)
	e1:SetOperation(c67675300.spop)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，这张卡以外的有冰指示物放置的怪兽不能攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c67675300.target)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的条件函数，判断是否满足特殊召唤的条件
function c67675300.spcon(e,c)
	if c==nil then return true end
	-- 检查怪兽区域是否有空位，且场上是否能移去4个冰指示物作为特殊召唤的代价
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.IsCanRemoveCounter(c:GetControler(),1,1,0x1015,4,REASON_COST)
end
-- 特殊召唤规则的操作函数，执行特殊召唤时的代价处理
function c67675300.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 从双方场上移去4个冰指示物
	Duel.RemoveCounter(tp,1,1,0x1015,4,REASON_RULE)
end
-- 过滤出场上除自身以外、且放置有冰指示物的怪兽
function c67675300.target(e,c)
	return c~=e:GetHandler() and c:GetCounter(0x1015)~=0
end
