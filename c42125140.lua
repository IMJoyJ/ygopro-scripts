--星辰鋏竜シャウラス
-- 效果：
-- 「星辰」怪兽＋手卡的怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地2张「星辰」卡和与那其中任意张是相同种类（怪兽·魔法·陷阱）的场上1张表侧表示卡为对象才能发动。那3张卡回到卡组。
-- ②：这张卡在墓地存在的状态，怪兽2只以上同时被送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化卡片效果：添加融合召唤手续，注册①回卡组起动效果和②墓地特殊召唤诱发效果
function s.initial_effect(c)
	-- 设定这张卡的融合素材条件：「星辰」怪兽1只＋手卡的怪兽1只
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
	-- ②：这张卡在墓地存在的状态，怪兽2只以上同时被送去墓地的场合才能发动。这张卡特殊召唤。
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

-- 注册合并事件的通用函数：创建常驻卡组收集触发的卡，并基于事件生成不重复的自定义事件代码
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
	-- 这张卡在墓地存在的状态
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EVENT_MOVE)
	e3:SetLabelObject(g)
	e3:SetOperation(s.ThisCardMovedToPublicResetCheck_ToSingleCard)
	c:RegisterEffect(e3)
	return event_code_single
end
-- 为每个事件注册场上永续检测效果，并对连锁发动、处理、召唤等关键时点克隆注册延迟检查效果，实现把同时送去墓地的卡合并为一次时点
function s.RegisterMergedEvent_ToSingleCard_AddOperation(c,g,event,event_code_single)
	-- 怪兽2只以上同时被送去墓地的场合才能发动
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
-- 延迟事件检查：把送去墓地的卡合并进收集卡组，并在非连锁处理时对其中因效果或规则调整送墓的卡统一触发自定义时点
function s.MergedDelayEventCheck1_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local c=e:GetOwner()
	g:Merge(eg)
	-- 检查当前是否处于卡的位置移动时点
	if Duel.CheckEvent(EVENT_MOVE) then
		-- 取得位置移动时点中实际移动的卡片组
		local _,meg=Duel.CheckEvent(EVENT_MOVE,true)
		if meg:IsContains(c) and (c:IsFaceup() or c:IsPublic()) then
			g:Clear()
		end
	end
	-- 判断当前不在连锁处理中，且收集的卡组里有因效果或规则调整被送去墓地的卡
	if Duel.GetCurrentChain()==0 and #g>0 and g:IsExists(Card.IsReason,1,nil,REASON_ADJUST|REASON_EFFECT) then
		local _eg=g:Clone()
		-- 以收集到的卡组触发自定义事件，供②效果检测发动时机
		Duel.RaiseEvent(_eg,e:GetLabel(),re,r,rp,ep,ev)
		g:Clear()
	end
end
-- 延迟事件检查2：在连锁处理等关键时点，直接对已收集的卡组触发自定义事件并清空
function s.MergedDelayEventCheck2_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	-- 检查当前是否处于卡的位置移动时点
	if Duel.CheckEvent(EVENT_MOVE) then
		-- 取得位置移动时点中实际移动的卡片组
		local _,meg=Duel.CheckEvent(EVENT_MOVE,true)
		local c=e:GetOwner()
		if meg:IsContains(c) and (c:IsFaceup() or c:IsPublic()) then
			g:Clear()
		end
	end
	if #g>0 then
		local _eg=g:Clone()
		-- 以收集到的卡组触发自定义事件，供②效果检测发动时机
		Duel.RaiseEvent(_eg,e:GetLabel(),re,r,rp,ep,ev)
		g:Clear()
	end
end
-- 这张卡变成表侧表示或公开状态时清空已收集的卡组，避免误触发②效果
function s.ThisCardMovedToPublicResetCheck_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local g=e:GetLabelObject()
	if c:IsFaceup() or c:IsPublic() then
		g:Clear()
	end
end

-- ①效果的墓地对象过滤：「星辰」卡，能成为效果对象且能回到卡组
function s.tdfilter1(c,e)
	return c:IsSetCard(0x1c9) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
end
-- 判断两张卡的种类（怪兽·魔法·陷阱）是否相同
function s.typefilter(c,ec)
	return (c:GetType()&ec:GetType())&(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)~=0
end
-- ①效果的场上对象过滤：表侧表示、与所选墓地卡中至少1张种类相同且能回到卡组
function s.tdfilter2(c,g)
	return c:IsFaceup() and g:IsExists(s.typefilter,1,nil,c) and c:IsAbleToDeck()
end
-- 检查以所选墓地2张卡为前提，场上是否存在能作为对象的表侧表示卡
function s.gcheck(g,tp)
	-- 检查场上是否存在1张满足条件的表侧表示卡可成为效果对象
	return Duel.IsExistingTarget(s.tdfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,g)
end
-- ①效果的对象选择处理：选出墓地2张「星辰」卡和场上1张同种类表侧表示卡为对象
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取得自己墓地全部满足条件的「星辰」卡作为候选卡组
	local g=Duel.GetMatchingGroup(s.tdfilter1,tp,LOCATION_GRAVE,0,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2,tp) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	-- 将选出的墓地2张卡设置为当前效果的对象
	Duel.SetTargetCard(sg)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1张与所选墓地卡同种类的表侧表示卡作为效果对象
	local tg=Duel.SelectTarget(tp,s.tdfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,sg)
	sg:Merge(tg)
	-- 设置操作信息：合计3张对象卡将回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,3,0,0)
end
-- ①效果的处理：将那3张对象卡回到卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与当前连锁相关的全部对象卡
	local g=Duel.GetTargetsRelateToChain()
	-- 若3张对象卡未能全部满足不受「王家长眠之谷」影响且仍能回到卡组，则中断处理
	if g:FilterCount(aux.NecroValleyFilter(Card.IsAbleToDeck),nil)~=3 then return end
	-- 以效果原因把那3张卡回到卡组并洗切卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- ②效果的发动条件：同时有2只以上怪兽被送去墓地，且其中不含这张卡自身
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,2,nil,TYPE_MONSTER) and not eg:IsContains(e:GetHandler())
end
-- ②效果的目标处理：确认主要怪兽区有空位且这张卡可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区存在可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：这张卡将被特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：把这张卡特殊召唤，并赋予其从场上离开的场合除外的永续效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与该效果关联且不受「王家长眠之谷」影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c)
		-- 将这张卡从墓地以表侧表示特殊召唤到自己场上
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
