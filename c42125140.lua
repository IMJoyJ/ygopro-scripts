--星辰鋏竜シャウラス
-- 效果：
-- 「星辰」怪兽＋手卡的怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地2张「星辰」卡和与那其中任意张是相同种类（怪兽·魔法·陷阱）的场上1张表侧表示卡为对象才能发动。那3张卡回到卡组。
-- ②：这张卡在墓地存在的状态，怪兽2只以上同时被送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册以「星辰」怪兽与手卡怪兽为素材的融合限制、回收墓地星辰与场上同种类卡片、以及墓地多只怪兽送墓时特召自身且离场除外的效果
function s.initial_effect(c)
	-- 注册融合召唤的素材要求：以场上的「星辰」怪兽与手手中的怪兽为素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1c9),aux.FilterBoolFunction(Card.IsLocation,LOCATION_HAND),true)
	c:EnableReviveLimit()
	-- ①：以自己墓地2张「星辰」卡和与那之中任意张是相同种类（怪兽·魔法·陷阱）的场上1张表侧表示卡为对象才能发动。那3张卡回到卡组。
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
	-- ②:: 这张卡在墓地存在的状态，怪兽2只以上同时被送去墓地的场合才能发动。这张卡特殊召唤。
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

-- 注册用于在多只怪兽同时被送去墓地时触发自定义事件的事件融合管理器
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
	-- 注册使此卡在离开场上时以除外形式离场的单体持续规则重定向效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EVENT_MOVE)
	e3:SetLabelObject(g)
	e3:SetOperation(s.ThisCardMovedToPublicResetCheck_ToSingleCard)
	c:RegisterEffect(e3)
	return event_code_single
end
-- 为自定义事件融合管理器中的每个具体事件注册后台监听收集器
function s.RegisterMergedEvent_ToSingleCard_AddOperation(c,g,event,event_code_single)
	-- 注册后台用于监听多怪兽同时送入墓地状态的单体持续事件监听器
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
-- 检查延迟的卡片移动状态并触发自定义多怪送墓的全局RaiseEvent事件
function s.MergedDelayEventCheck1_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local c=e:GetOwner()
	g:Merge(eg)
	-- 确认被移动的卡片事件类型是否包含EVENT_MOVE
	if Duel.CheckEvent(EVENT_MOVE) then
		-- 确认卡片是否依然处于表侧表示或对双方公开的区域
		local _,meg=Duel.CheckEvent(EVENT_MOVE,true)
		if meg:IsContains(c) and (c:IsFaceup() or c:IsPublic()) then
			g:Clear()
		end
	end
	-- 在当前没有任何连锁正在处理且已累计被移动卡片时，触发卡片移动事件
	if Duel.GetCurrentChain()==0 and #g>0 and g:IsExists(Card.IsReason,1,nil,REASON_ADJUST|REASON_EFFECT) then
		local _eg=g:Clone()
		-- 广播多只卡片同时移动的自定义效果触发事件
		Duel.RaiseEvent(_eg,e:GetLabel(),re,r,rp,ep,ev)
		g:Clear()
	end
end
-- 在特定游戏步骤或攻击声明时，执行卡片移动事件的延迟广播处理
function s.MergedDelayEventCheck2_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	-- 确认延迟监听中卡片事件类型是否属于EVENT_MOVE
	if Duel.CheckEvent(EVENT_MOVE) then
		-- 确认卡片依然对双方公开
		local _,meg=Duel.CheckEvent(EVENT_MOVE,true)
		local c=e:GetOwner()
		if meg:IsContains(c) and (c:IsFaceup() or c:IsPublic()) then
			g:Clear()
		end
	end
	if #g>0 then
		local _eg=g:Clone()
		-- 广播延迟累加的自定义卡片移动事件
		Duel.RaiseEvent(_eg,e:GetLabel(),re,r,rp,ep,ev)
		g:Clear()
	end
end
-- 当此卡移动至表侧表示的公开位置时，重置并清空已监听记录的卡片组
function s.ThisCardMovedToPublicResetCheck_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local g=e:GetLabelObject()
	if c:IsFaceup() or c:IsPublic() then
		g:Clear()
	end
end

-- 墓地中属于「星辰」字段、可作为对象且能够返回卡组的卡片的过滤条件
function s.tdfilter1(c,e)
	return c:IsSetCard(0x1c9) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
end
-- 用于比对两个卡片的类型是否同属怪兽、魔法或陷阱卡
function s.typefilter(c,ec)
	return (c:GetType()&ec:GetType())&(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)~=0
end
-- 场上表侧表示存在的、与所选墓地卡片同属怪兽/魔法/陷阱且能返回卡组的卡片的过滤条件
function s.tdfilter2(c,g)
	return c:IsFaceup() and g:IsExists(s.typefilter,1,nil,c) and c:IsAbleToDeck()
end
-- 检查所选的墓地卡片是否能在场上找到至少1张同类型的表侧卡片以供回收
function s.gcheck(g,tp)
	-- 如果是则此回收组合合法
	return Duel.IsExistingTarget(s.tdfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,g)
end
-- 墓地与场上卡片返回卡组效果的发动准备与对象选择
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中符合回收条件的全部「星辰」卡片
	local g=Duel.GetMatchingGroup(s.tdfilter1,tp,LOCATION_GRAVE,0,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2,tp) end
	-- 向玩家发送提示，请选择墓地回收的「星辰」卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	-- 将从墓地中选出的这2张「星辰」卡作为效果的对象注册
	Duel.SetTargetCard(sg)
	-- 向玩家发送提示，请选择要回收的场上卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从场上选择1张与上述墓地卡片相同种类的表侧表示卡作为回收对象
	local tg=Duel.SelectTarget(tp,s.tdfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,sg)
	sg:Merge(tg)
	-- 设置操作信息为将这3张卡片返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,3,0,0)
end
-- 墓地与场上卡片返回卡组效果的执行
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中关联的全部作为对象的卡片
	local g=Duel.GetTargetsRelateToChain()
	-- 确认这3张卡片均依然符合返回卡组的条件，若否则停止处理
	if g:FilterCount(aux.NecroValleyFilter(Card.IsAbleToDeck),nil)~=3 then return end
	-- 将这3张卡片全部送回持有者的卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 判断当前是否至少有2只怪兽同时被送去墓地，且其中不包含此卡本身
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,2,nil,TYPE_MONSTER) and not eg:IsContains(e:GetHandler())
end
-- 墓地特召自身效果的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 将此卡从墓地特殊召唤以及为其注册离场除外效果的执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡依然正常处于墓地且效果处理未受墓地无效影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c)
		-- 将此卡以表侧表示特殊召唤到场上
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 注册在此卡以该效果特召状态离开场上时，必须被里侧或表侧除外的重定向效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
