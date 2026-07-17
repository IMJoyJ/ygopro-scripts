--星辰爪竜アルザリオン
-- 效果：
-- 「星辰」怪兽＋手卡的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，以最多有那些作为融合素材的手卡的怪兽数量的自己·对方的场上·墓地的怪兽为对象才能发动。那些怪兽回到手卡。
-- ②：这张卡在墓地存在的状态，怪兽2只以上同时被送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化函数：设置融合召唤手续与苏生限制，注册①效果（融合召唤成功时取对象使怪兽回到手卡，1回合1次）、融合素材检查效果（记录作为素材的手卡怪兽数量并传给①效果），以及墓地中的②效果（怪兽2只以上同时送去墓地的场合把这张卡特殊召唤，1回合1次）。
function s.initial_effect(c)
	-- 设置这张卡的融合召唤手续：以1只「星辰」（0x1c9）怪兽加上1只以上（最多127只）手卡的怪兽为融合素材。
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1c9),aux.FilterBoolFunction(Card.IsLocation,LOCATION_HAND),1,127,true)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡融合召唤的场合，以最多有那些作为融合素材的手卡的怪兽数量的自己·对方的场上·墓地的怪兽为对象才能发动。那些怪兽回到手卡。
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
	-- 最多有那些作为融合素材的手卡的怪兽数量（注册素材检查效果，把作为融合素材的手卡怪兽数量记录到①效果中）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	local custom_code=s.RegisterMergedEvent_ToSingleCard(c,id,EVENT_TO_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的状态，怪兽2只以上同时被送去墓地的场合才能发动。这张卡特殊召唤。
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

-- 合并时点工具函数的前半：创建常驻卡组g用于缓存送去墓地的卡，并根据事件数值累加生成种子，取尚未被占用的种子，用于构造不重复的自定义事件代码。
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
	-- 这张卡在墓地存在的状态（这张卡以表侧或公开状态移动时清空缓存组，保证只对应这张卡在墓地存在期间送去墓地的怪兽）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EVENT_MOVE)
	e3:SetLabelObject(g)
	e3:SetOperation(s.ThisCardMovedToPublicResetCheck_ToSingleCard)
	c:RegisterEffect(e3)
	return event_code_single
end
-- 为这张卡注册监听送去墓地事件的不入连锁持续效果，把送去墓地的卡记入缓存组；并对连锁发动·处理·结束、攻击宣言、召唤·特殊召唤·里侧设置、战斗破坏等一系列检查点事件注册克隆效果，在这些节点统一抛出缓存的合并时点。
function s.RegisterMergedEvent_ToSingleCard_AddOperation(c,g,event,event_code_single)
	-- 怪兽2只以上同时被送去墓地的场合（注册持续监听怪兽送去墓地事件的效果，将送去墓地的卡缓存起来）。
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
-- 送去墓地事件的缓存处理：把本次送去墓地的卡组合并进缓存组；若这张卡同时以表侧或公开状态移动则清空缓存；当前不在连锁处理中且缓存组中存在因效果或调整送去墓地的卡时，抛出自定义合并时点并清空缓存。
function s.MergedDelayEventCheck1_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local c=e:GetOwner()
	g:Merge(eg)
	-- 检查当前是否正在发生卡片位置移动（EVENT_MOVE）时点。
	if Duel.CheckEvent(EVENT_MOVE) then
		-- 获取本次位置移动事件涉及的卡组meg，用于判断这张卡自身是否同时发生了移动。
		local _,meg=Duel.CheckEvent(EVENT_MOVE,true)
		if meg:IsContains(c) and (c:IsFaceup() or c:IsPublic()) then
			g:Clear()
		end
	end
	-- 满足抛出条件：当前没有正在处理的连锁、缓存组非空，且其中至少1张是因效果或调整被送去墓地的卡。
	if Duel.GetCurrentChain()==0 and #g>0 and g:IsExists(Card.IsReason,1,nil,REASON_ADJUST|REASON_EFFECT) then
		local _eg=g:Clone()
		-- 以缓存组中的卡为对象抛出自定义的「怪兽被送去墓地」合并时点事件，供②效果连锁发动。
		Duel.RaiseEvent(_eg,e:GetLabel(),re,r,rp,ep,ev)
		g:Clear()
	end
end
-- 连锁内检查点处理：同样在这张卡以表侧或公开状态移动时清空缓存；只要缓存组非空就立即抛出自定义合并时点并清空，保证送去墓地时点不被连锁处理错过。
function s.MergedDelayEventCheck2_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	-- 检查当前是否正在发生卡片位置移动（EVENT_MOVE）时点。
	if Duel.CheckEvent(EVENT_MOVE) then
		-- 获取本次位置移动事件涉及的卡组meg，用于判断这张卡自身是否同时发生了移动。
		local _,meg=Duel.CheckEvent(EVENT_MOVE,true)
		local c=e:GetOwner()
		if meg:IsContains(c) and (c:IsFaceup() or c:IsPublic()) then
			g:Clear()
		end
	end
	if #g>0 then
		local _eg=g:Clone()
		-- 以缓存组中的卡为对象抛出自定义的「怪兽被送去墓地」合并时点事件。
		Duel.RaiseEvent(_eg,e:GetLabel(),re,r,rp,ep,ev)
		g:Clear()
	end
end
-- 这张卡自身位置移动时的重置检查：若这张卡处于表侧或公开状态（已离开墓地），则清空缓存的送去墓地卡组，确保②效果只对应这张卡在墓地存在期间送去墓地的怪兽。
function s.ThisCardMovedToPublicResetCheck_ToSingleCard(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local g=e:GetLabelObject()
	if c:IsFaceup() or c:IsPublic() then
		g:Clear()
	end
end

-- 融合素材检查：统计这张卡的融合素材中原本在手卡的怪兽数量，并将该数量记录到①效果的标签中，作为①效果可取对象的最大张数。
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	local mg1=mg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	e:GetLabelObject():SetLabel(#mg1)
end
-- ①效果发动条件：这张卡是融合召唤而特殊召唤成功的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 对象过滤条件：是怪兽卡且可以回到手卡。
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果目标选择的前半：读取素材检查记录的手卡素材数量ct；chkc分支确认被选的卡位于场上或墓地且满足回手卡过滤；发动可行性检查要求ct大于0。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and s.thfilter(chkc) end
	if chk==0 then return ct and ct>0
		-- 并且自己·对方的场上·墓地存在至少1张可作为效果对象的能回到手卡的怪兽。
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil) end
	-- 向自己玩家发出选择提示：请选择要回到手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让自己玩家从自己·对方的场上·墓地选择1～ct只能回到手卡的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,ct,nil)
	-- 设置操作信息：声明本连锁将把作为对象的怪兽（数量为所选张数）回到手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 处理时过滤条件：该卡仍与本效果相关联且是怪兽卡。
function s.thopfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsType(TYPE_MONSTER)
end
-- ①效果处理：取得本连锁的对象卡组，过滤出仍与效果关联、是怪兽且不受王家长眠之谷影响的卡，将它们因效果全部回到持有者的手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡组，并过滤出仍与本效果关联、是怪兽且不受王家长眠之谷影响的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.NecroValleyFilter(s.thopfilter),nil,e)
	if g:GetCount()>0 then
		-- 将这些怪兽因效果送回各自持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- ②效果发动条件：同时送去墓地的卡中包含2只以上怪兽，且其中不包含这张卡自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,2,nil,TYPE_MONSTER) and not eg:IsContains(e:GetHandler())
end
-- ②效果目标：发动可行性检查要求自己场上有可用的主要怪兽区域空格，且墓地的这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：自己场上的主要怪兽区域有1格以上的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本连锁将把墓地的这张卡1只特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：这张卡仍与效果关联且不受王家长眠之谷影响时，把它以表侧表示特殊召唤到自己场上；特殊召唤成功后注册单体永续效果，使这张卡从场上离开的场合除外。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡仍与本效果相关联，且不受王家长眠之谷的影响。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c)
		-- 并确认这张卡以表侧表示特殊召唤到自己场上成功（特殊召唤数量不为0）。
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
