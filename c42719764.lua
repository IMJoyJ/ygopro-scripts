--サモンショック
-- 效果：
-- ①：每次怪兽召唤·特殊召唤，给这张卡放置1个召唤指示物（最多4个）。
-- ②：这张卡有召唤指示物被放置，那些召唤指示物数量变成4个的场合发动。这张卡的召唤指示物全部取除，场上的怪兽全部送去墓地。
local s,id,o=GetID()
-- 初始化「召唤电击」：允许并限制最多放置4个召唤指示物；注册使这张永续陷阱可以发动的空效果（自由时点）；注册在召唤成功时和特殊召唤成功时触发的放置指示物永续效果；注册在召唤指示物达到4个的场合必发的将场上怪兽全部送去墓地的诱发效果（场合型、延迟触发）。
function s.initial_effect(c)
	c:EnableCounterPermit(0x4c)
	c:SetCounterLimit(0x4c,4)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次怪兽召唤·特殊召唤，给这张卡放置1个召唤指示物（最多4个）。
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
	-- ②：这张卡有召唤指示物被放置，那些召唤指示物数量变成4个的场合发动。这张卡的召唤指示物全部取除，场上的怪兽全部送去墓地。
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
s.mentioned_counter={
	[0x4c]=true,
}
-- 永续效果的适用检查：确认这张卡可以放置1个召唤指示物（未达上限），可以放置才执行放置操作。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x4c,1) end
end
-- 给这张卡放置1个召唤指示物，并检查放置后召唤指示物数量是否变成4个；若变成4个则触发自定义事件，以发动②效果。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x4c,1)
	if c:GetCounter(0x4c)==4 then
		-- 召唤指示物数量变成4个的场合，以这张卡为对象触发自定义事件（EVENT_CUSTOM+id），用于让②的诱发必发效果在之后的时点发动。
		Duel.RaiseEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
-- ②效果的发动检查与操作信息设置：确认这张卡的召唤指示物为4个才能发动；检索双方场上所有可以送去墓地的怪兽，并将送去墓地的操作信息（对象与数量）登记到连锁上。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x4c)==4 end
	-- 检索双方主要怪兽区和额外怪兽区所有可以送去墓地的怪兽，作为送去墓地的预计对象。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 把场上全部怪兽设置为本次连锁「送去墓地」分类的操作信息对象，数量为检索到的怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- ②效果处理：确认这张卡仍与这条连锁关联，取除这张卡放置的全部召唤指示物，然后检索场上所有可以送去墓地的怪兽并以效果原因全部送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local ct=c:GetCounter(0x4c)
		if ct>0 then
			c:RemoveCounter(tp,0x4c,ct,REASON_EFFECT)
			-- 检索双方场上所有可以送去墓地的怪兽，作为实际送去墓地的对象组。
			local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
			-- 以效果原因将检索到的场上全部怪兽送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
