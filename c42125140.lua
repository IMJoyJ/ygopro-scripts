--星辰鋏竜シャウラス
-- 效果：
-- 「星辰」怪兽＋手卡的怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地2张「星辰」卡和与那其中任意张是相同种类（怪兽·魔法·陷阱）的场上1张表侧表示卡为对象才能发动。那3张卡回到卡组。
-- ②：这张卡在墓地存在的状态，怪兽2只以上同时被送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化效果，设置融合召唤条件并启用复活限制
function s.initial_effect(c)
	-- 添加融合召唤手续，使用1只「星辰」怪兽和1只手卡怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1c9),aux.FilterBoolFunction(Card.IsLocation,LOCATION_HAND),true)
	c:EnableReviveLimit()
	-- ①：以自己墓地2张「星辰」卡和与那其中任意张是相同种类（怪兽·魔法·陷阱）的场上1张表侧表示卡为对象才能发动。那3张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	local custom_code=s.RegisterMergedEvent_ToSingleCard(c,id,EVENT_TO_GRAVE)
	-- ②：这张卡在墓地存在的状态，怪兽2只以上同时被送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

-- 注册合并事件，用于处理多个事件合并为一个自定义事件
function s.RegisterMergedEvent_ToSingleCard(c,code,events)
	local g=Group.CreateGroup()
	g:KeepAlive()
	local mt=getmetatable(c)
	local seed=0
	if type(events) == "table" then
		for _, event in ipairs(events) do
			seed = seed + event
		end
	else
		seed = events
	end
	while(mt[seed]==true) do
		seed = seed + 1
	end
	mt[seed]=true
	local event_code_single = (code ~ (seed << 16)) | EVENT_CUSTOM
	if type(events) == "table" then
		for _, event in ipairs(events) do
			s.RegisterMergedEvent_ToSingleCard_AddOperation(c,g,event,event_code_single)
		end
	else
		s.RegisterMergedEvent_ToSingleCard_AddOperation(c,g,events,event_code_single)
	end
	-- 为卡片注册一个持续效果，用于检测卡片移动到公开区域时重置事件组
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EVENT_MOVE)
	e3:SetLabelObject(g)
	e3:SetOperation(s.ThisCardMovedToPublicResetCheck_ToSingleCard)
	c:RegisterEffect(e3)
	return event_code_single
end
-- 添加事件处理效果，将指定事件合并到自定义事件中
function s.RegisterMergedEvent_ToSingleCard_AddOperation(c,g,event,event_code_single)
	-- 为指定事件注册一个处理效果，用于收集事件并触发自定义事件
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(event)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(0xff)
	e1:SetLabel(event_code_single)
	e1:SetLabelObject(g)
	e1:SetOperation(s.MergedDelayEventCheck1_ToSingleCard)
	c:RegisterEffect(e1)
	local ec={
		EVENT_CHAIN_ACTIVATING,
		EVENT_CHAINING,
		EVENT_ATTACK_ANNOUNCE,
		EVENT_BREAK_EFFECT,
		EVENT_CHAIN_SOLVING,
		EVENT_CHAIN_SOLVED,
		EVENT_CHAIN_END,
		EVENT_SUMMON,
		EVENT_SPSUMMON,
		EVENT_MSET,
		EVENT_BATTLE_DESTROYED
	}
	for _,code in ipairs(ec) do
		local ce=e1:Clone()
		ce:SetCode(code)
		ce:SetOperation(s.MergedDelayEventCheck2_ToSingleCard)
		c:RegisterEffect(ce)
	end
end
-- 处理合并事件检查，当事件发生时将事件对象加入组并触发自定义事件
function s.MergedDelayEventCheck1_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local c=e:GetOwner()
	g:Merge(eg)
	-- 检查是否为EVENT_MOVE事件
	if Duel.CheckEvent(EVENT_MOVE) then
		-- 获取EVENT_MOVE事件的详细信息
		local _,meg=Duel.CheckEvent(EVENT_MOVE,true)
		if meg:IsContains(c) and (c:IsFaceup() or c:IsPublic()) then
			g:Clear()
		end
	end
	-- 检查当前连锁是否为空且组中有卡且存在REASON_ADJUST或REASON_EFFECT原因的卡
	if Duel.GetCurrentChain()==0 and #g>0 and g:IsExists(Card.IsReason,1,nil,REASON_ADJUST|REASON_EFFECT) then
		local _eg=g:Clone()
		-- 触发自定义事件
		Duel.RaiseEvent(_eg,e:GetLabel(),re,r,rp,ep,ev)
		g:Clear()
	end
end
-- 处理合并事件检查2，用于处理其他类型的事件
function s.MergedDelayEventCheck2_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	-- 检查是否为EVENT_MOVE事件
	if Duel.CheckEvent(EVENT_MOVE) then
		-- 获取EVENT_MOVE事件的详细信息
		local _,meg=Duel.CheckEvent(EVENT_MOVE,true)
		local c=e:GetOwner()
		if meg:IsContains(c) and (c:IsFaceup() or c:IsPublic()) then
			g:Clear()
		end
	end
	if #g>0 then
		local _eg=g:Clone()
		-- 触发自定义事件
		Duel.RaiseEvent(_eg,e:GetLabel(),re,r,rp,ep,ev)
		g:Clear()
	end
end
-- 检测卡片移动到公开区域时清除事件组
function s.ThisCardMovedToPublicResetCheck_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local g=e:GetLabelObject()
	if c:IsFaceup() or c:IsPublic() then
		g:Clear()
	end
end

-- 过滤墓地中的「星辰」卡
function s.tdfilter1(c,e)
	return c:IsSetCard(0x1c9) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
end
-- 判断两张卡的类型是否相同
function s.typefilter(c,ec)
	return (c:GetType()&ec:GetType())&(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)~=0
end
-- 过滤场上的表侧表示卡，确保其类型与墓地卡组中的卡类型一致
function s.tdfilter2(c,g)
	return c:IsFaceup() and g:IsExists(s.typefilter,1,nil,c) and c:IsAbleToDeck()
end
-- 检查是否存在满足条件的卡组组合
function s.gcheck(g,tp)
	-- 检查是否存在满足条件的卡组组合
	return Duel.IsExistingTarget(s.tdfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,g)
end
-- 设置①效果的目标选择逻辑
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取满足条件的墓地卡组
	local g=Duel.GetMatchingGroup(s.tdfilter1,tp,LOCATION_GRAVE,0,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2,tp) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	-- 设置目标卡组
	Duel.SetTargetCard(sg)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上的表侧表示卡作为目标
	local tg=Duel.SelectTarget(tp,s.tdfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,sg)
	sg:Merge(tg)
	-- 设置操作信息，指定将3张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,3,0,0)
end
-- 执行①效果的操作，将目标卡返回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组并过滤
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.NecroValleyFilter(Card.IsRelateToChain),nil)
	if g:GetCount()~=3 then return end
	-- 将卡返回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 设置②效果的发动条件，当有2只以上怪兽同时被送去墓地时发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,2,nil,TYPE_MONSTER) and not eg:IsContains(e:GetHandler())
end
-- 设置②效果的目标选择逻辑
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，指定将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行②效果的操作，将此卡特殊召唤并设置离开场时的处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否与效果相关且未受王家长眠之谷影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c)
		-- 执行特殊召唤操作
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置特殊召唤后离开场时的处理，将此卡移除
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
