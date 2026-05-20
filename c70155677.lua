--夢見るネムレリア
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，自己主要阶段才能发动。从自己的卡组·墓地选1张「妮穆蕾莉娅」永续魔法卡在自己场上表侧表示放置，这张卡表侧表示加入额外卡组。这个效果发动的回合，自己不能把「梦见之妮穆蕾莉娅」特殊召唤。
-- 【怪兽效果】
-- 这张卡不能通常召唤。这张卡在额外卡组表侧表示存在，自己的额外卡组只有「梦见之妮穆蕾莉娅」存在的场合才能特殊召唤。自己对「梦见之妮穆蕾莉娅」1回合只能有1次特殊召唤。
-- ①：这张卡特殊召唤成功的场合才能发动。里侧表示除外的自己的卡每有3张，选对方的场上·墓地最多1张卡里侧表示除外。那之后，选这个效果除外的卡数量的里侧表示除外的自己的卡回到卡组。
function c70155677.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(70155677)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、作为灵摆卡发动等基本规则）。
	aux.EnablePendulumAttribute(c)
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 这张卡在额外卡组表侧表示存在，自己的额外卡组只有「梦见之妮穆蕾莉娅」存在的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(c70155677.sprcon)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。从自己的卡组·墓地选1张「妮穆蕾莉娅」永续魔法卡在自己场上表侧表示放置，这张卡表侧表示加入额外卡组。这个效果发动的回合，自己不能把「梦见之妮穆蕾莉娅」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c70155677.mvcost)
	e2:SetTarget(c70155677.mvtg)
	e2:SetOperation(c70155677.mvop)
	c:RegisterEffect(e2)
	-- 注册一个用于记录本回合是否特殊召唤过「梦见之妮穆蕾莉娅」以外怪兽的计数器。
	Duel.AddCustomActivityCounter(70155677,ACTIVITY_SPSUMMON,c70155677.counterfilter)
	-- ①：这张卡特殊召唤成功的场合才能发动。里侧表示除外的自己的卡每有3张，选对方的场上·墓地最多1张卡里侧表示除外。那之后，选这个效果除外的卡数量的里侧表示除外的自己的卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c70155677.drmtg)
	e3:SetOperation(c70155677.drmop)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的允许条件判断函数。
function c70155677.sprcon(e,c)
	if c==nil then return true end
	if c:IsFacedown() then return false end
	local tp=c:GetControler()
	-- 获取自己额外卡组的所有卡片。
	local exg=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	-- 过滤并计算自己额外卡组中表侧表示且卡名为「梦见之妮穆蕾莉娅」的卡片数量。
	local ct=exg:FilterCount(aux.AND(Card.IsFaceup,Card.IsCode),nil,70155677)
	-- 检查额外卡组不为空、额外卡组的卡全部是表侧表示的「梦见之妮穆蕾莉娅」，且自己场上有可用于从额外卡组特殊召唤该怪兽的空格。
	return #exg>0 and #exg==ct and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 计数器过滤函数，用于筛选出卡名不是「梦见之妮穆蕾莉娅」的怪兽。
function c70155677.counterfilter(c)
	return not c:IsCode(70155677)
end
-- 灵摆效果的发动代价与限制处理函数。
function c70155677.mvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查本回合自己是否未曾特殊召唤过「梦见之妮穆蕾莉娅」以外的怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(70155677,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不能把「梦见之妮穆蕾莉娅」特殊召唤。从自己的卡组·墓地选1张「妮穆蕾莉娅」永续魔法卡在自己场上表侧表示放置，这张卡表侧表示加入额外卡组。里侧表示除外的自己的卡每有3张，选对方的场上·墓地最多1张卡里侧表示除外。那之后，选这个效果除外的卡数量的里侧表示除外的自己的卡回到卡组。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c70155677.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制玩家在本回合不能特殊召唤「梦见之妮穆蕾莉娅」。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，锁定卡名为「梦见之妮穆蕾莉娅」的怪兽。
function c70155677.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(70155677)
end
-- 过滤满足条件的卡片：非禁止卡、属于「妮穆蕾莉娅」系列、是永续魔法卡，且在场上唯一存在。
function c70155677.mvfilter(c,tp)
	return not c:IsForbidden() and c:IsSetCard(0x191) and c:GetType()==TYPE_CONTINUOUS+TYPE_SPELL and c:CheckUniqueOnField(tp)
end
-- 灵摆效果的发动条件与目标检查函数。
function c70155677.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己的卡组或墓地是否存在至少1张满足条件的「妮穆蕾莉娅」永续魔法卡。
		and Duel.IsExistingMatchingCard(c70155677.mvfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
-- 灵摆效果的效果处理函数。
function c70155677.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己卡组或墓地中不受「王家之谷」影响且满足条件的「妮穆蕾莉娅」永续魔法卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c70155677.mvfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	-- 如果没有符合条件的卡，或者魔法与陷阱区域没有空位，则不处理效果。
	if #g==0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将选中的永续魔法卡在自己的魔法与陷阱区域表侧表示放置，若放置成功且此卡仍存在于灵摆区域。
	if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) and c:IsRelateToEffect(e) then
		-- 将作为灵摆卡发动的此卡表侧表示加入额外卡组。
		Duel.SendtoExtraP(c,nil,REASON_EFFECT)
	end
end
-- 怪兽效果①的发动条件与目标检查函数。
function c70155677.drmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己里侧表示除外的所有卡片。
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)
	local tg=g:Filter(Card.IsAbleToDeck,nil)
	-- 获取对方场上或墓地中可以被里侧表示除外的卡片。
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil,tp,POS_FACEDOWN)
	local ct=math.floor(#g/3)
	if chk==0 then return ct>0 and #tg>0 and #rg>0 end
	-- 设置连锁处理信息，表示此效果包含除外对方卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,1,0,0)
	-- 设置连锁处理信息，表示此效果包含将自己里侧除外的卡片送回卡组的操作。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,0,0)
end
-- 过滤实际被除外的卡片，排除因转移去向等原因未成功除外的卡。
function c70155677.rmdfilter(c)
	return c:IsLocation(LOCATION_REMOVED) and not c:IsReason(REASON_REDIRECT)
end
-- 过滤自己里侧表示除外且可以送回卡组的卡片。
function c70155677.tdfilter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
-- 怪兽效果①的效果处理函数。
function c70155677.drmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 重新获取自己里侧表示除外的所有卡片。
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)
	local tg=g:Filter(Card.IsAbleToDeck,nil)
	-- 获取对方场上或墓地中不受「王家之谷」影响且可以被里侧表示除外的卡片。
	local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil,tp,POS_FACEDOWN)
	local ct=math.floor(#g/3)
	if ct==0 or #tg==0 or #rg==0 then return end
	if ct>#tg then ct=#tg end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local mg=rg:Select(tp,1,ct,nil)
	-- 显式示出被选中的对方卡片。
	Duel.HintSelection(mg)
	-- 将选中的对方卡片里侧表示除外。
	Duel.Remove(mg,POS_FACEDOWN,REASON_EFFECT)
	-- 过滤本次操作中实际被成功除外的卡片。
	local og=Duel.GetOperatedGroup():Filter(c70155677.rmdfilter,nil)
	if #og==0 then return end
	-- 提示玩家选择要送回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择与被除外卡片数量相同的自己里侧表示除外的卡片。
	local tg1=Duel.SelectMatchingCard(tp,c70155677.tdfilter,tp,LOCATION_REMOVED,0,#og,#og,nil)
	-- 中断当前效果处理，使后续的送回卡组动作与除外动作不视为同时进行。
	Duel.BreakEffect()
	-- 显式示出被选中的自己里侧表示除外的卡片。
	Duel.HintSelection(tg1)
	-- 将选中的卡片送回持有者卡组并洗牌。
	Duel.SendtoDeck(tg1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
