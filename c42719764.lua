--サモンショック
-- 效果：
-- ①：每次怪兽召唤·特殊召唤，给这张卡放置1个召唤指示物（最多4个）。
-- ②：这张卡有召唤指示物被放置，那些召唤指示物数量变成4个的场合发动。这张卡的召唤指示物全部取除，场上的怪兽全部送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果，设置召唤指示物的放置权限与上限，并注册永续发动效果、召唤与特殊召唤时的指示物添加效果，以及触发效果用于处理指示物达到4个时的墓地处理。
function s.initial_effect(c)
	c:EnableCounterPermit(0x4c)
	c:SetCounterLimit(0x4c,4)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次怪兽召唤·特殊召唤，给这张卡放置1个召唤指示物（最多4个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 这张卡有召唤指示物被放置，那些召唤指示物数量变成4个的场合发动。这张卡的召唤指示物全部取除，场上的怪兽全部送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
-- 判断是否可以为该卡添加1个召唤指示物。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x4c,1) end
end
-- 为该卡添加1个召唤指示物，若指示物数量达到4则触发自定义事件。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x4c,1)
	if c:GetCounter(0x4c)==4 then
		-- 触发自定义事件，用于发动效果②。
		Duel.RaiseEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
-- 判断是否满足效果②的发动条件（召唤指示物数量为4），并设置将场上所有怪兽送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x4c)==4 end
	-- 获取场上所有可以送去墓地的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定将场上所有怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 执行效果②的处理，移除所有召唤指示物并将场上所有怪兽送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local ct=c:GetCounter(0x4c)
		if ct>0 then
			c:RemoveCounter(tp,0x4c,ct,REASON_EFFECT)
			-- 获取场上所有可以送去墓地的怪兽。
			local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
			-- 将指定的怪兽组全部送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
