--リチュア・エミリア
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。这张卡召唤·反转时，自己场上有这张卡以外的名字带有「遗式」的怪兽存在的场合，直到结束阶段时场上的陷阱卡的效果无效。
function c73551138.initial_effect(c)
	-- 注册灵魂怪兽在召唤或翻转成功的回合的结束阶段回到持有者手卡的效果。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为始终返回false，即不能特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡召唤·反转时，自己场上有这张卡以外的名字带有「遗式」的怪兽存在的场合，直到结束阶段时场上的陷阱卡的效果无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(73551138,1))  --"陷阱的效果无效"
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCondition(c73551138.negcon)
	e4:SetOperation(c73551138.negop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 过滤条件：场上表侧表示的名字带有「遗式」的怪兽。
function c73551138.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3a)
end
-- 判定自己场上是否存在除这张卡以外的名字带有「遗式」的怪兽作为发动条件。
function c73551138.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张除自身以外表侧表示的名字带有「遗式」的怪兽。
	return Duel.IsExistingMatchingCard(c73551138.filter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 召唤·反转成功时效果的处理：在场上注册使陷阱卡效果无效的永续效果和连锁处理时使陷阱卡效果无效的事件。
function c73551138.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，若自己场上已不存在除自身以外的名字带有「遗式」的怪兽，则效果不适用。
	if not Duel.IsExistingMatchingCard(c73551138.filter,tp,LOCATION_MZONE,0,1,c) then return end
	-- 直到结束阶段时场上的陷阱卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c73551138.distg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使场上陷阱卡效果无效的全局效果。
	Duel.RegisterEffect(e1,tp)
	-- 直到结束阶段时场上的陷阱卡的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetOperation(c73551138.disop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在连锁处理时使陷阱卡效果无效的全局效果。
	Duel.RegisterEffect(e2,tp)
	-- 直到结束阶段时场上的陷阱卡的效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c73551138.distg)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使场上陷阱怪兽效果无效的全局效果。
	Duel.RegisterEffect(e3,tp)
end
-- 过滤条件：除自身以外的陷阱卡。
function c73551138.distg(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_TRAP)
end
-- 连锁处理时的操作：若连锁发生位置在魔陷区且卡片类型为陷阱卡，则使该连锁的效果无效。
function c73551138.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的发动位置。
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) then
		-- 使该连锁的效果无效。
		Duel.NegateEffect(ev)
	end
end
