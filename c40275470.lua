--人造人間－サイコ・エナジー・ショッカー
local s,id,o=GetID()
-- 初始化效果，注册多个效果，包括召唤成功时的破坏效果、特殊召唤成功时的相同效果以及场上的陷阱卡不能发动效果
function s.initial_effect(c)
	-- 使该卡在怪兽区和墓地时可以变更为卡号为77585513的卡片
	aux.EnableChangeCode(c,77585513,LOCATION_MZONE+LOCATION_GRAVE)
	-- 记录该卡上记载着卡号为40235813的卡片
	aux.AddCodeList(c,40235813)
	-- 设置一个诱发选发效果，当此卡通常召唤成功时发动，破坏对方场上的陷阱卡或里侧魔陷
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 设置一个场地区域的永续效果，当满足条件时使对方不能发动陷阱卡
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,0xff)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.distg)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为陷阱卡或位于魔陷区且非场地区（5号位）的里侧卡
function s.desfilter(c)
	return c:IsType(TYPE_TRAP) or c:IsFacedown() and c:IsLocation(LOCATION_SZONE) and c:GetSequence()~=5
end
-- 过滤函数，用于判断是否为正面表示的陷阱卡
function s.qdesfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP)
end
-- 破坏效果的处理函数，检查是否有满足条件的卡并设置操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在满足破坏条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取所有满足确认条件的卡组成的组
	local sg=Duel.GetMatchingGroup(s.qdesfilter,tp,0,LOCATION_ONFIELD,nil)
	if sg:GetCount()>0 then
		-- 设置连锁操作信息，指定要破坏的卡组和数量
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	end
end
-- 过滤函数，用于判断是否为位于魔陷区且非场地区（5号位）的里侧卡
function s.cffilter(c)
	return c:IsFacedown() and c:IsLocation(LOCATION_SZONE) and c:GetSequence()~=5
end
-- 破坏效果的执行函数，确认对方场上的卡并进行破坏处理，根据破坏数量提升攻击力
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取所有满足确认条件的卡组成的组
	local sg=Duel.GetMatchingGroup(s.cffilter,tp,0,LOCATION_ONFIELD,nil)
	-- 如果存在需要确认的卡，则向玩家展示这些卡
	if sg:GetCount()>0 then Duel.ConfirmCards(tp,sg) end
	-- 获取对方场上所有陷阱卡组成的组
	local dg=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_TRAP)
	if dg:GetCount()>0 then
		-- 将指定的卡组以效果原因破坏，返回实际破坏的数量
		local atk=Duel.Destroy(dg,REASON_EFFECT)
		if atk>0 and c:IsRelateToChain() and c:IsFaceup() then
			-- 中断当前效果处理，使后续效果视为错时点处理
			Duel.BreakEffect()
			-- 设置一个提升攻击力的效果，增加量为破坏数量乘以300
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk*300)
			c:RegisterEffect(e2)
		end
	end
end
-- 过滤函数，用于判断是否为正面表示且记载着卡号40235813的怪兽卡
function s.cfilter(c)
	-- 返回该卡为正面表示、记载着卡号40235813且为怪兽类型的卡
	return c:IsFaceupEx() and aux.IsCodeListed(c,40235813) and c:IsType(TYPE_MONSTER)
end
-- 条件函数，检查对方场上或墓地是否存在满足条件的卡
function s.condition(e)
	-- 返回对方场上或墓地是否存在至少一张满足条件的卡
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler())
end
-- 目标函数，用于判断是否为陷阱卡
function s.distg(e,c)
	return c:IsType(TYPE_TRAP)
end
