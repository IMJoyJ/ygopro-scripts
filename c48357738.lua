--暴君の暴飲暴食
-- 效果：
-- 把自己场上存在的1只怪兽解放发动。只要这张卡在场上存在，双方不能把6星以上的怪兽特殊召唤。自己手卡是3张以上的场合，这张卡破坏。
function c48357738.initial_effect(c)
	-- 把自己场上存在的1只怪兽解放发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c48357738.cost)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，双方不能把6星以上的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	-- 设置效果目标为等级6以上的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,6))
	c:RegisterEffect(e2)
	-- 自己手卡是3张以上的场合，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(c48357738.descon)
	c:RegisterEffect(e3)
end
-- 支付代价时检查是否能选择1只怪兽进行解放，并选择该怪兽进行解放。
function c48357738.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张可解放的卡。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 从玩家场上选择1张满足条件的卡进行解放。
	local rg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 以代價原因解放选中的卡。
	Duel.Release(rg,REASON_COST)
end
-- 判断自身手牌数量是否大于等于3。
function c48357738.descon(e)
	-- 获取当前控制者手牌数量并判断是否大于等于3。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)>=3
end
