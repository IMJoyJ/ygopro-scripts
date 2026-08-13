--アークネメシス・エスカトス
-- 效果：
-- 这张卡不能通常召唤。从自己墓地以及自己场上的表侧表示怪兽之中把3只种族不同的怪兽除外的场合可以特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：场上的这张卡不会被效果破坏。
-- ②：宣言场上的怪兽1个种族才能发动。场上的宣言种族的怪兽全部破坏。直到下个回合的结束时，双方不能把宣言的种族的怪兽特殊召唤。
function c33212663.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应效果原文：这张卡不能通常召唤。从自己墓地以及自己场上的表侧表示怪兽之中把3只种族不同的怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c33212663.sprcon)
	e1:SetTarget(c33212663.sprtg)
	e1:SetOperation(c33212663.sprop)
	c:RegisterEffect(e1)
	-- 对应效果原文：①：场上的这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 对应效果原文：②：宣言场上的怪兽1个种族才能发动。场上的宣言种族的怪兽全部破坏。直到下个回合的结束时，双方不能把宣言的种族的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33212663,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,33212663)
	e3:SetTarget(c33212663.destg)
	e3:SetOperation(c33212663.desop)
	c:RegisterEffect(e3)
end
-- 筛选可作为特殊召唤代价除外的怪兽：必须是表侧表示或位于墓地，且可作为代价除外，同时是怪兽卡。
function c33212663.sprfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 检查所选的3张卡是否满足特殊召唤条件：将它们除外后，自己场上仍有空余的怪兽区，且3张卡种族各不相同（按种族分类的种类数等于卡数）。
function c33212663.fselect(g,tp)
	-- 判断“除外后仍有可用的怪兽区”且“3张卡种族互不相同”，以确保能作为特殊召唤的素材。
	return Duel.GetMZoneCount(tp,g)>0 and g:GetClassCount(Card.GetRace)==#g
end
-- 特殊召唤规则条件的判定：若c为空表示仅询问可否特殊召唤，返回true；否则取控制者，检索满足条件的怪兽组，并检查其中是否存在3张种族互异且除外后有空余怪兽区的组合。
function c33212663.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上表侧表示怪兽以及自己墓地中所有可作为代价除外的怪兽集合。
	local rg=Duel.GetMatchingGroup(c33212663.sprfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return rg:CheckSubGroup(c33212663.fselect,3,3,tp)
end
-- 特殊召唤手续的选择阶段：取得候选组，提示玩家选择要除外的卡，从候选组中选择3张满足种族互异且除外后有格子的卡；选中则保存该组并返回true，否则返回false。
function c33212663.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上表侧表示怪兽以及自己墓地中所有可作为代价除外的怪兽集合，供玩家选择。
	local rg=Duel.GetMatchingGroup(c33212663.sprfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 弹出“请选择要除外的卡”的选择提示，并将选择消息设置为除外相关。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=rg:SelectSubGroup(tp,c33212663.fselect,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的实际处理：取出之前选定的3张卡，以表侧表示形式除外作为召唤代价，并清理Group对象。
function c33212663.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将作为特殊召唤素材的3张怪兽以表侧表示除外，除外原因是特殊召唤（召唤手续）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ②效果的破坏筛选：判定卡是否表侧表示且属于被宣言的种族。
function c33212663.desfilter(c,race)
	return c:IsFaceup() and c:IsRace(race)
end
-- ②效果的发动条件与处理预设置：确认场上有表侧表示怪兽；统计场上所有表侧怪兽的种族集合；让玩家宣言其中1个种族；再获取该种族的场上表侧怪兽组，并将破坏信息写入连锁。
function c33212663.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时的合法检查：在效果发动确认阶段（chk==0），场上至少要存在1张表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上双方所有表侧表示怪兽的集合，用于计算玩家可以宣言的种族范围。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	local race=0
	while tc do
		race=race|tc:GetRace()
		tc=g:GetNext()
	end
	-- 显示“请选择要宣言的种族”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从场上表侧怪兽所含的种族中宣言1个种族，结果赋值给rc。
	local rc=Duel.AnnounceRace(tp,1,race)
	e:SetLabel(rc)
	-- 获取当前场上所有表侧表示且属于宣言种族的怪兽，作为②效果要破坏的目标组。
	local dg=Duel.GetMatchingGroup(c33212663.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,rc)
	-- 设置本次连锁的操作信息：类别为破坏，目标是这些同种族怪兽，数量为其张数，以配合其他卡的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- ②效果的实际处理：取出宣言的种族，重新获取场上属于该种族的表侧怪兽并全部破坏；随后创建一个影响双方的永续效果，使直到下个回合结束时双方不能特殊召唤该种族的怪兽。
function c33212663.desop(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	-- 在实际处理时重新获取场上属于宣言种族的表侧怪兽组，防止因处理前场上变化导致目标失效。
	local dg=Duel.GetMatchingGroup(c33212663.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,race)
	if dg:GetCount()>0 then
		-- 以效果原因破坏该种族怪兽组。
		Duel.Destroy(dg,REASON_EFFECT)
	end
	-- 对应效果原文：直到下个回合的结束时，双方不能把宣言的种族的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,1)
	e1:SetLabel(race)
	e1:SetTarget(c33212663.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将“宣言种族不能特殊召唤”的限制效果注册到场上，使其持续影响双方玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的判定：若被特殊召唤的怪兽与宣言的种族相同，则不允许特殊召唤。
function c33212663.splimit(e,c)
	return c:IsRace(e:GetLabel())
end
