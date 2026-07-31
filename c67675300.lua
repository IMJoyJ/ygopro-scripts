--スノーダスト・ドラゴン
-- 效果：
-- 这张卡可以把场上4个冰指示物取除，从手卡特殊召唤。只要这张卡在场上表侧表示存在，这张卡以外的有冰指示物放置的怪兽不能攻击，也不能作表示形式的变更。
function c67675300.initial_effect(c)
	-- 这张卡可以把场上4个冰指示物去除，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c67675300.spcon)
	e1:SetOperation(c67675300.spop)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，这张卡以外的有冰指示物放置的怪兽不能攻击，也不能作表示形式的变更。
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
c67675300.mentioned_counter={
	[0x1015]=true,
}
-- 特殊召唤手续条件检查：主要怪兽区域有空位且场上有4个冰指示物
function c67675300.spcon(e,c)
	if c==nil then return true end
	-- 检查怪兽区域是否有空位及场上是否可以去除4个冰指示物
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.IsCanRemoveCounter(c:GetControler(),1,1,0x1015,4,REASON_COST)
end
-- 特殊召唤手续效果处理：去除场上4个冰指示物
function c67675300.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 从场上去除4个冰指示物
	Duel.RemoveCounter(tp,1,1,0x1015,4,REASON_RULE)
end
-- 攻击与表示形式变更限制对象过滤：此卡以外有冰指示物放置的怪兽
function c67675300.target(e,c)
	return c~=e:GetHandler() and c:GetCounter(0x1015)~=0
end
