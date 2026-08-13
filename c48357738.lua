--暴君の暴飲暴食
-- 效果：
-- 把自己场上存在的1只怪兽解放发动。只要这张卡在场上存在，双方不能把6星以上的怪兽特殊召唤。自己手卡是3张以上的场合，这张卡破坏。
function c48357738.initial_effect(c)
	-- 对应效果原文：把自己场上存在的1只怪兽解放发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c48357738.cost)
	c:RegisterEffect(e1)
	-- 对应效果原文：只要这张卡在场上存在，双方不能把6星以上的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	-- 设定不能特殊召唤的判定条件：对象怪兽必须是6星以上。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,6))
	c:RegisterEffect(e2)
	-- 对应效果原文：自己手卡是3张以上的场合，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(c48357738.descon)
	c:RegisterEffect(e3)
end
-- 发动代价的处理函数：检查、选择并解放自己场上1只怪兽作为发动代价。
function c48357738.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己场上是否存在至少1只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只怪兽作为解放对象（代价）。
	local rg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选择的怪兽解放，作为发动代价（REASON_COST）。
	Duel.Release(rg,REASON_COST)
end
-- 自破坏效果的条件判断函数：当自己手牌数为3张以上时满足自毁条件。
function c48357738.descon(e)
	-- 判断自己手牌区的卡数量是否不少于3张。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)>=3
end
