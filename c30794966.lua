--聖刻龍－ウシルドラゴン
-- 效果：
-- 这张卡可以把自己墓地的龙族·光属性怪兽和龙族的通常怪兽各1只从游戏中除外，从手卡特殊召唤。场上的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「圣刻」的怪兽解放。
function c30794966.initial_effect(c)
	-- 这张卡可以把自己墓地的龙族·光属性怪兽和龙族的通常怪兽各1只从游戏中除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c30794966.hspcon)
	e1:SetTarget(c30794966.hsptg)
	e1:SetOperation(c30794966.hspop)
	c:RegisterEffect(e1)
	-- 场上的这张卡被破坏的场合，可以作为代替把这张卡以外的自己场上表侧表示存在的1只名字带有「圣刻」的怪兽解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c30794966.desreptg)
	e2:SetOperation(c30794966.desrepop)
	c:RegisterEffect(e2)
end
-- 筛选可作为除外素材的卡：种族为龙族、可以作为代价除外，且满足光属性或通常怪兽之一。
function c30794966.rfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost()
		and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsType(TYPE_NORMAL))
end
-- 特殊召唤手续的条件判定：无具体卡片时返回true；否则要求我方主要怪兽区有空位，并且墓地中存在2张能分别满足光属性龙族与通常龙族条件的素材组合。
function c30794966.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取我方墓地中所有满足rfilter过滤条件（龙族且可除外，光属性或通常）的卡，作为候选组。
	local g=Duel.GetMatchingGroup(c30794966.rfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查我方主要怪兽区是否存在可用的空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查候选组中能否选出2张卡，使其中一张为光属性龙族、另一张为龙族通常怪兽，即两只素材各满足对应条件。
		and g:CheckSubGroup(aux.gffcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,Card.IsType,TYPE_NORMAL)
end
-- 特殊召唤手续的目标选择阶段：从墓地候选卡中选择2张（光属性龙族和通常龙族各1只）作为除外素材；选择成功后保存该组并返回true，否则返回false。
function c30794966.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取我方墓地中可作为特殊召唤除外素材的龙族候选卡组。
	local g=Duel.GetMatchingGroup(c30794966.rfilter,tp,LOCATION_GRAVE,0,nil)
	-- 发送选择提示消息，引导玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从候选组中选择2张卡，要求其中1张为光属性龙族、1张为龙族通常怪兽，作为从手卡特殊召唤的代价。
	local sg=g:SelectSubGroup(tp,aux.gffcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,Card.IsType,TYPE_NORMAL)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的处理阶段：取出之前保存的素材组，将选中的卡除外，然后释放组对象。
function c30794966.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的两张素材卡以表侧表示从游戏中除外，作为这次特殊召唤手续的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 筛选可代替破坏的解放对象：必须为表侧表示、卡名带有「圣刻」、且不是已经确定要被破坏的那张卡（从而排除自身）。
function c30794966.repfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x69) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏效果的发动条件：本卡不是因代替破坏而触发，并且自己场上存在1只可解放的、满足repfilter条件的其他「圣刻」怪兽。
function c30794966.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE)
		-- 检查自己场上是否存在1只可解放的、满足repfilter条件的「圣刻」怪兽（排除作为本卡的c）。
		and Duel.CheckReleaseGroupEx(tp,c30794966.repfilter,1,REASON_EFFECT,false,c) end
	-- 让玩家选择是否发动代替破坏效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择用于代替破坏而解放的「圣刻」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 玩家从自己场上选择1只满足条件且可解放的「圣刻」怪兽（排除自身），作为代替破坏的解放对象。
		local g=Duel.SelectReleaseGroupEx(tp,c30794966.repfilter,1,1,REASON_EFFECT,false,c)
		e:SetLabelObject(g:GetFirst())
		return true
	else return false end
end
-- 代替破坏效果的处理：取出之前选择的怪兽并将其解放，以此代替这张卡被破坏。
function c30794966.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将选择的怪兽解放，作为代替破坏的代价，使本卡免于被破坏。
	Duel.Release(tc,REASON_EFFECT)
end
