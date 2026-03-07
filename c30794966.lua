--聖刻龍－ウシルドラゴン
-- 效果：
-- 这张卡可以把自己墓地的龙族·光属性怪兽和龙族的通常怪兽各1只从游戏中除外，从手卡特殊召唤。场上的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「圣刻」的怪兽解放。
function c30794966.initial_effect(c)
	-- 效果原文：这张卡可以把自己墓地的龙族·光属性怪兽和龙族的通常怪兽各1只从游戏中除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c30794966.hspcon)
	e1:SetTarget(c30794966.hsptg)
	e1:SetOperation(c30794966.hspop)
	c:RegisterEffect(e1)
	-- 效果原文：场上的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「圣刻」的怪兽解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c30794966.desreptg)
	e2:SetOperation(c30794966.desrepop)
	c:RegisterEffect(e2)
end
-- 过滤函数：返回满足龙族、可除外作为费用、并且是光属性或通常怪兽的卡片。
function c30794966.rfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost()
		and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsType(TYPE_NORMAL))
end
-- 特殊召唤条件判断：检查玩家场上是否有足够的怪兽区域，并且墓地中有满足条件的2张卡片组合。
function c30794966.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足条件的墓地卡片组。
	local g=Duel.GetMatchingGroup(c30794966.rfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查玩家场上是否有足够的怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地卡片组中是否存在满足条件的2张卡片组合（一张光属性，一张通常怪兽）。
		and g:CheckSubGroup(aux.gffcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,Card.IsType,TYPE_NORMAL)
end
-- 特殊召唤目标选择：从墓地选择满足条件的2张卡片。
function c30794966.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的墓地卡片组。
	local g=Duel.GetMatchingGroup(c30794966.rfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从满足条件的卡片组中选择2张符合条件的卡片组合。
	local sg=g:SelectSubGroup(tp,aux.gffcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,Card.IsType,TYPE_NORMAL)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤操作：将选中的卡片从游戏中除外。
function c30794966.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡片从游戏中除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 代替破坏的过滤函数：返回场上表侧表示、名字带有「圣刻」且未被预定破坏的怪兽。
function c30794966.repfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x69) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏的目标判断：检查是否可以解放满足条件的怪兽。
function c30794966.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE)
		-- 检查玩家场上是否存在满足条件的可解放怪兽。
		and Duel.CheckReleaseGroupEx(tp,c30794966.repfilter,1,REASON_EFFECT,false,c) end
	-- 询问玩家是否发动代替破坏效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要代替破坏的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 从满足条件的怪兽中选择1只进行解放。
		local g=Duel.SelectReleaseGroupEx(tp,c30794966.repfilter,1,1,REASON_EFFECT,false,c)
		e:SetLabelObject(g:GetFirst())
		return true
	else return false end
end
-- 代替破坏操作：将选中的怪兽解放。
function c30794966.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将选中的怪兽进行解放。
	Duel.Release(tc,REASON_EFFECT)
end
