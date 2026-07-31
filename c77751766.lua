--火器の祝台
-- 效果：
-- 这张卡发动的场合，给这张卡放置5个祝台指示物来发动。
-- ①：因魔法·陷阱卡的效果，从额外卡组有怪兽特殊召唤的场合或者从卡组有卡被送去墓地的场合发动。这张卡1个祝台指示物取除。那之后，这张卡的祝台指示物数量是0的场合，这张卡破坏，自己回复4000基本分。那之后，从自己的卡组·墓地把1张「祝台」陷阱卡在自己场上盖放。那之后，自己卡组的数量是1张以下的场合，自己决斗胜利。
local s,id,o=GetID()
-- 初始化卡片效果：注册①卡片发动并放置指示物、②指示物放置许可、③魔陷效果导致额外特召或卡组送墓时取除指示物（归零时破坏·恢复LP·盖放祝台陷阱·满条件胜利）效果
function s.initial_effect(c)
	c:EnableCounterPermit(0x6d)
	-- ①：作为这张卡的发动时的效果处理，在这张卡放置5个祝台指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	-- 指示物放置许可：限制此卡仅在魔法与陷阱区域且处于连锁处理中时才能放置指示物
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_COUNTER_PERMIT+0x6d)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.ctpermit)
	c:RegisterEffect(e2)
	-- ②：魔法·陷阱卡的效果从额外卡组有怪兽特殊召唤的场合或从卡组有卡被送去墓地的场合取除这卡的1个祝台指示物。之后，这卡的祝台指示物是0的场合，这卡破坏，自己回复4000基本分。之后，从自己的卡组·墓地把1张「祝台」陷阱卡盖放。之后，自己卡组是1张以下的场合，自己决斗胜利。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"取除指示物"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS+CATEGORY_SSET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.ccon1)
	e3:SetCost(s.ccost)
	e3:SetOperation(s.cop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.ccon2)
	c:RegisterEffect(e4)
end
s.mentioned_counter={
	[0x6d]=true,
}
-- ①效果发动准备：检查是否可放置指示物并执行放置5个指示物
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：判断此卡能否放置5个祝台指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x6d,5,c) end
	c:AddCounter(0x6d,5)
end
-- 指示物许可条件：必须在魔陷区且正在连锁处理中
function s.ctpermit(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsStatus(STATUS_CHAINING)
end
-- 过滤条件1：从指定区域离场且因魔法·陷阱卡效果特殊召唤
function s.cfilter1(c,loc)
	return c:IsPreviousLocation(loc) and c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT)
end
-- 过滤条件2：从指定区域离场且因魔法·陷阱卡效果送去墓地
function s.cfilter2(c,loc)
	return c:IsPreviousLocation(loc) and c:IsReason(REASON_EFFECT)
end
-- 取除指示物触发条件1：因魔法·陷阱卡效果从额外卡组有怪兽特殊召唤
function s.ccon1(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_TRAP+TYPE_SPELL)
		and eg:IsExists(s.cfilter1,1,nil,LOCATION_EXTRA)
end
-- 取除指示物触发条件2：因魔法·陷阱卡效果从卡组有卡被送去墓地
function s.ccon2(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_TRAP+TYPE_SPELL)
		and eg:IsExists(s.cfilter2,1,nil,LOCATION_DECK)
end
-- 效果发动Cost：同一连锁中限制发动1次
function s.ccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：确认同一连锁中尚未注册发动标记
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 在同一连锁中注册发动标记
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
-- 盖放卡片过滤条件：卡名带有「祝台」的陷阱卡且可以盖放
function s.setfilter(c)
	return c:IsSetCard(0x1bd) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 取除指示物效果处理：取除1个指示物，归零时破坏自己、恢复4000LP、盖放「祝台」陷阱卡，若卡组仅剩1张以下则直接胜利
function s.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:RemoveCounter(tp,0x6d,1,REASON_EFFECT) and c:GetCounter(0x6d)==0 then
		-- 连接效果块：分隔指示物取除与后续破坏·回复处理
		Duel.BreakEffect()
		-- 破坏此卡并恢复自己4000基本分，两者皆成功时执行后续处理
		if Duel.Destroy(c,REASON_EFFECT)~=0 and Duel.Recover(tp,4000,REASON_EFFECT)~=0 then
			-- 提示玩家选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 从卡组或墓地选择1张满足条件的「祝台」陷阱卡
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				-- 连接效果块：分隔回复基本分与盖放卡片处理
				Duel.BreakEffect()
				-- 成功盖放卡片且检查卡组剩余卡片数量是否在1张以下
				if Duel.SSet(tp,g:GetFirst())>0 and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_DECK,0,nil)<=1 then
					-- 连接效果块：分隔盖放卡片与特殊胜利处理
					Duel.BreakEffect()
					-- 判定自己因卡片效果直接获得决斗胜利
					Duel.Win(tp,0x23)
				end
			end
		end
	end
end
