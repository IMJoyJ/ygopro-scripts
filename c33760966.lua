--星辰爪竜アルザリオン
-- 效果：
-- 「星辰」怪兽＋手卡的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，以最多有那些作为融合素材的手卡的怪兽数量的自己·对方的场上·墓地的怪兽为对象才能发动。那些怪兽回到手卡。
-- ②：这张卡在墓地存在的状态，怪兽2只以上同时被送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化本卡效果：注册融合召唤手续和苏生限制，创建①融合召唤时回手效果（回手分类、自身触发的选发效果、取对象、延迟型、1回合1次）、②素材检查效果（把作为融合素材的手卡怪兽数量写入①的Label）以及③墓地怪兽同时送墓时特殊召唤自身的诱发效果（场上触发型、墓地发动范围、自定义事件、1回合1次）
function s.initial_effect(c)
	-- 为本卡添加融合召唤手续：用1只「星辰」怪兽加1只以上手卡的怪兽作为融合素材
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
	-- ①：这张卡融合召唤的场合，以最多有那些作为融合素材的手卡的怪兽数量的自己·对方的场上·墓地的怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	local custom_code=s.RegisterMergedEvent_ToSingleCard(c,id,EVENT_TO_GRAVE)
	-- ②：这张卡在墓地存在的状态，怪兽2只以上同时被送去墓地的场合才能发动。这张卡特殊召唤。
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

-- 为这张卡注册合并事件工具：创建并保活一个暂存事件卡片的卡组，以传入事件编号之和为种子（若metatable中已占用则递增避让）生成不冲突的事件种子
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
	-- 注册这张卡的持续效果：这张卡移动后若处于公开状态（表侧或公开区域），就清空暂存的事件卡组，用于检测「这张卡在墓地存在的状态」这一前提
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EVENT_MOVE)
	e3:SetLabelObject(g)
	e3:SetOperation(s.ThisCardMovedToPublicResetCheck_ToSingleCard)
	c:RegisterEffect(e3)
	return event_code_single
end
-- 为每个被监听的事件注册一个全区域持续效果：事件发生时暂存涉及的卡片；并为连锁开始/连锁处理/召唤/特殊召唤/盖放/战斗破坏等节点事件克隆注册副本，在这些节点把暂存的事件作为合并后的自定义事件抛出
function s.RegisterMergedEvent_ToSingleCard_AddOperation(c,g,event,event_code_single)
	-- 注册监听指定事件的持续效果：发生该事件（如怪兽被送去墓地）时，把涉及的卡片暂存起来，以便随后合并抛出自定义时点
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
-- 事件监听处理：把本时点涉及的卡片并入暂存组；若当前处于卡片移动时点且这张卡本身移动后处于公开状态则清空暂存组；当不在连锁处理中且暂存组里存在以调整或效果原因送去墓地的卡时，把暂存组作为自定义合并事件抛出并清空
function s.MergedDelayEventCheck1_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local c=e:GetOwner()
	g:Merge(eg)
	-- 检查当前是否正处于卡片移动的时点
	if Duel.CheckEvent(EVENT_MOVE) then
		-- 以获取详细信息的方式检查移动时点，取得本次移动的卡片组meg
		local _,meg=Duel.CheckEvent(EVENT_MOVE,true)
		if meg:IsContains(c) and (c:IsFaceup() or c:IsPublic()) then
			g:Clear()
		end
	end
	-- 判断当前不在任何连锁处理中、暂存组非空，且其中至少有1张卡是以调整或效果原因被送去墓地的
	if Duel.GetCurrentChain()==0 and #g>0 and g:IsExists(Card.IsReason,1,nil,REASON_ADJUST|REASON_EFFECT) then
		local _eg=g:Clone()
		-- 把暂存的卡片组作为自定义事件抛出，从而触发③效果的「怪兽被送去墓地的场合」时点
		Duel.RaiseEvent(_eg,e:GetLabel(),re,r,rp,ep,ev)
		g:Clear()
	end
end
-- 节点事件监听处理：同样先在本卡移动后处于公开状态时清空暂存组；在连锁/召唤等节点事件发生时，若暂存组非空就把暂存组作为自定义合并事件抛出并清空
function s.MergedDelayEventCheck2_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	-- 检查当前是否正处于卡片移动的时点
	if Duel.CheckEvent(EVENT_MOVE) then
		-- 以获取详细信息的方式检查移动时点，取得本次移动的卡片组meg
		local _,meg=Duel.CheckEvent(EVENT_MOVE,true)
		local c=e:GetOwner()
		if meg:IsContains(c) and (c:IsFaceup() or c:IsPublic()) then
			g:Clear()
		end
	end
	if #g>0 then
		local _eg=g:Clone()
		-- 把暂存的卡片组作为自定义事件抛出，触发③效果的送墓时点
		Duel.RaiseEvent(_eg,e:GetLabel(),re,r,rp,ep,ev)
		g:Clear()
	end
end
-- 这张卡移动的持续处理：当这张卡处于表侧表示或公开状态时，清空暂存的事件卡片组，保证③效果只在这张卡于墓地存在时响应送墓事件
function s.ThisCardMovedToPublicResetCheck_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local g=e:GetLabelObject()
	if c:IsFaceup() or c:IsPublic() then
		g:Clear()
	end
end

-- 融合素材检查：取得融合召唤使用的素材，筛出其中位于手卡的怪兽，把其数量存入①效果的Label，作为可取对象数量的上限
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	local mg1=mg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	e:GetLabelObject():SetLabel(#mg1)
end
-- ①效果的发动条件：这张卡是融合召唤的场合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 回手对象过滤条件：是怪兽并且可以回到手卡
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的对象选择前置处理：取出素材中手卡怪兽的数量ct；校验预选对象须在场上或墓地；发动条件为ct大于0且双方场上·墓地存在至少1只可取为对象的可回手怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and s.thfilter(chkc) end
	if chk==0 then return ct and ct>0
		-- 确认自己·对方的场上·墓地存在至少1只满足条件且能成为效果对象的怪兽
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil) end
	-- 向玩家提示「请选择要返回手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家以1～ct只双方场上·墓地的可回手怪兽为对象进行选择，并设为当前连锁的对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,ct,nil)
	-- 设置操作信息：这些被取为对象的怪兽将因回手效果回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时的过滤条件：该卡仍与这个效果相关（未被移动导致脱离对象）并且是怪兽
function s.thopfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsType(TYPE_MONSTER)
end
-- ①效果的处理：取得当前连锁的对象卡，筛出仍与效果相关且不受王家长眠之谷影响的怪兽，将它们以效果原因送回持有者的手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡片组，过滤出仍与效果相关、是怪兽且不受王家长眠之谷影响的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.NecroValleyFilter(s.thopfilter),nil,e)
	if g:GetCount()>0 then
		-- 把那些怪兽以效果原因送回持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：同时被送去墓地的卡中有2只以上是怪兽，且其中不包含这张卡本身
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,2,nil,TYPE_MONSTER) and not eg:IsContains(e:GetHandler())
end
-- ②效果的发动可行性检查：自己主要怪兽区域有空位，且这张卡可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区域是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：这张卡将被特殊召唤（数量为1）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：确认这张卡仍与效果相关且不受王家长眠之谷影响后，把这张卡以表侧表示特殊召唤到自己场上；特殊召唤成功后为其注册一个离场时改为除外的持续效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与这个效果相关，并且不受王家长眠之谷的影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c)
		-- 把这张卡以表侧表示特殊召唤到自己场上，并确认特殊召唤成功
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
