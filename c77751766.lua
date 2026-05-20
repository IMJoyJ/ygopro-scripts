--火器の祝台
-- 效果：
-- 这张卡发动的场合，给这张卡放置5个祝台指示物来发动。
-- ①：因魔法·陷阱卡的效果，从额外卡组有怪兽特殊召唤的场合或者从卡组有卡被送去墓地的场合发动。这张卡1个祝台指示物取除。那之后，这张卡的祝台指示物数量是0的场合，这张卡破坏，自己回复4000基本分。那之后，从自己的卡组·墓地把1张「祝台」陷阱卡在自己场上盖放。那之后，自己卡组的数量是1张以下的场合，自己决斗胜利。
local s,id,o=GetID()
-- 初始化卡片效果：允许放置祝台指示物，注册卡片发动效果，注册在魔陷区且连锁中允许放置指示物的效果，以及注册因魔陷效果特召/送墓时取除指示物并处理后续效果的诱发效果。
function s.initial_effect(c)
	c:EnableCounterPermit(0x6d)
	-- 这张卡发动的场合，给这张卡放置5个祝台指示物来发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	-- 给这张卡放置5个祝台指示物来发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_COUNTER_PERMIT+0x6d)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.ctpermit)
	c:RegisterEffect(e2)
	-- ①：因魔法·陷阱卡的效果，从额外卡组有怪兽特殊召唤的场合或者从卡组有卡被送去墓地的场合发动。这张卡1个祝台指示物取除。那之后，这张卡的祝台指示物数量是0的场合，这张卡破坏，自己回复4000基本分。那之后，从自己的卡组·墓地把1张「祝台」陷阱卡在自己场上盖放。那之后，自己卡组的数量是1张以下的场合，自己决斗胜利。
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
-- 卡片发动时的效果处理：检查并给这张卡放置5个祝台指示物。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否能向这张卡放置5个祝台指示物。
	if chk==0 then return Duel.IsCanAddCounter(tp,0x6d,5,c) end
	c:AddCounter(0x6d,5)
end
-- 限制仅在魔陷区且处于连锁中时才允许放置指示物。
function s.ctpermit(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsStatus(STATUS_CHAINING)
end
-- 过滤条件：从额外卡组因效果特殊召唤的怪兽。
function s.cfilter1(c,loc)
	return c:IsPreviousLocation(loc) and c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT)
end
-- 过滤条件：从卡组因效果送去墓地的卡。
function s.cfilter2(c,loc)
	return c:IsPreviousLocation(loc) and c:IsReason(REASON_EFFECT)
end
-- 触发条件：因魔法·陷阱卡的效果，从额外卡组有怪兽特殊召唤的场合。
function s.ccon1(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_TRAP+TYPE_SPELL)
		and eg:IsExists(s.cfilter1,1,nil,LOCATION_EXTRA)
end
-- 触发条件：因魔法·陷阱卡的效果，从卡组有卡被送去墓地的场合。
function s.ccon2(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_TRAP+TYPE_SPELL)
		and eg:IsExists(s.cfilter2,1,nil,LOCATION_DECK)
end
-- 效果发动成本：限制同一连锁内只能发动1次该效果（注册连锁标记）。
function s.ccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前连锁中是否尚未注册过该效果的标记。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 给玩家注册一个在连锁结束时重置的标记，用于防止同连锁重复发动。
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
-- 过滤条件：卡名包含「祝台」且可以盖放的陷阱卡。
function s.setfilter(c)
	return c:IsSetCard(0x1bd) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果处理：取除1个指示物，若数量变为0则破坏此卡并回复4000基本分，之后从卡组·墓地盖放1张「祝台」陷阱卡，若卡组剩1张以下则决斗胜利。
function s.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:RemoveCounter(tp,0x6d,1,REASON_EFFECT) and c:GetCounter(0x6d)==0 then
		-- 中断当前效果，使后续的破坏与回复处理与取除指示物不同时进行。
		Duel.BreakEffect()
		-- 破坏这张卡，并使自己回复4000基本分。
		if Duel.Destroy(c,REASON_EFFECT)~=0 and Duel.Recover(tp,4000,REASON_EFFECT)~=0 then
			-- 提示玩家选择要盖放的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 从自己的卡组或墓地选择1张满足条件的「祝台」陷阱卡（受「王家之谷」影响）。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				-- 中断当前效果，使后续的盖放卡片处理与之前的破坏回复不同时进行。
				Duel.BreakEffect()
				-- 盖放选择的卡，并检查此时自己卡组的数量是否在1张以下。
				if Duel.SSet(tp,g:GetFirst()) and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_DECK,0,nil)<=1 then
					-- 中断当前效果，使后续的决斗胜利判定与盖放卡片不同时进行。
					Duel.BreakEffect()
					-- 判定自己决斗胜利。
					Duel.Win(tp,0x23)
				end
			end
		end
	end
end
