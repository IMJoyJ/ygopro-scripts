--星辰爪竜アルザリオン
-- 效果：
-- 「星辰」怪兽＋手卡的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，以最多有那些作为融合素材的手卡的怪兽数量的自己·对方的场上·墓地的怪兽为对象才能发动。那些怪兽回到手卡。
-- ②：这张卡在墓地存在的状态，怪兽2只以上同时被送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤条件、启用复活限制，并注册①②两个效果
function s.initial_effect(c)
	-- 设置融合召唤条件：以1只「星辰」怪兽和1到127只手卡怪兽为融合素材
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1c9),aux.FilterBoolFunction(Card.IsLocation,LOCATION_HAND),1,127,true)
	c:EnableReviveLimit()
	-- ①：这张卡融合召唤的场合，以最多有那些作为融合素材的手卡的怪兽数量的自己·对方的场上·墓地的怪兽为对象才能发动。那些怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 记录融合素材中手卡怪兽数量，用于①效果的发动条件
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	local custom_code=s.RegisterMergedEvent_ToSingleCard(c,id,EVENT_TO_GRAVE)
	-- ②：这张卡在墓地存在的状态，怪兽2只以上同时被送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(custom_code)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

-- 注册自定义事件，用于合并多个事件为一个触发条件
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
	-- 当卡片移至公开区域时，清空事件记录组
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EVENT_MOVE)
	e3:SetLabelObject(g)
	e3:SetOperation(s.ThisCardMovedToPublicResetCheck_ToSingleCard)
	c:RegisterEffect(e3)
	return event_code_single
end
-- 为指定事件类型注册处理函数，用于延迟事件的检测与触发
function s.RegisterMergedEvent_ToSingleCard_AddOperation(c,g,event,event_code_single)
	-- 为指定事件注册处理函数，用于延迟事件的检测与触发
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
-- 处理延迟事件，将符合条件的事件加入记录组并触发自定义事件
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
	-- 判断当前无连锁处理且记录组中有卡，且存在REASON_ADJUST或REASON_EFFECT原因的卡
	if Duel.GetCurrentChain()==0 and #g>0 and g:IsExists(Card.IsReason,1,nil,REASON_ADJUST|REASON_EFFECT) then
		local _eg=g:Clone()
		-- 触发自定义事件，将记录组中的卡作为事件对象
		Duel.RaiseEvent(_eg,e:GetLabel(),re,r,rp,ep,ev)
		g:Clear()
	end
end
-- 处理延迟事件，检查卡片移至公开区域并触发自定义事件
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
		-- 触发自定义事件，将记录组中的卡作为事件对象
		Duel.RaiseEvent(_eg,e:GetLabel(),re,r,rp,ep,ev)
		g:Clear()
	end
end
-- 当卡片移至公开区域时，清空事件记录组
function s.ThisCardMovedToPublicResetCheck_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local g=e:GetLabelObject()
	if c:IsFaceup() or c:IsPublic() then
		g:Clear()
	end
end

-- 记录融合素材中手卡怪兽数量，用于①效果的发动条件
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	local mg1=mg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	e:GetLabelObject():SetLabel(#mg1)
end
-- ①效果的发动条件：确认此卡为融合召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 筛选可返回手卡的怪兽
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的目标选择函数，选择场上或墓地的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and s.thfilter(chkc) end
	if chk==0 then return ct and ct>0
		-- 判断是否满足①效果发动条件
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,ct,nil)
	-- 设置操作信息，指定将要返回手牌的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 筛选可返回手牌的怪兽
function s.thopfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsType(TYPE_MONSTER)
end
-- ①效果的处理函数，将目标怪兽返回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标怪兽组，并过滤受王家长眠之谷影响的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.NecroValleyFilter(s.thopfilter),nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的怪兽返回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：怪兽2只以上同时被送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,2,nil,TYPE_MONSTER) and not eg:IsContains(e:GetHandler())
end
-- ②效果的目标选择函数，判断是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足②效果发动条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数，将此卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否可特殊召唤
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter(c)
		-- 执行特殊召唤操作
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 特殊召唤后，设置此卡离开场时移至除外区的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
