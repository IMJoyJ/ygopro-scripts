--砂塵の悪霊
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到主人的手卡。这张卡召唤·反转时，场上的这张卡以外的全部表侧表示的怪兽破坏。
function c89111398.initial_effect(c)
	-- 设定灵魂怪兽在召唤·反转的回合的结束阶段回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为恒假，使该怪兽无法被任何方式特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡召唤·反转时，场上的这张卡以外的全部表侧表示的怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(89111398,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c89111398.destg)
	e4:SetOperation(c89111398.desop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 过滤条件：筛选表侧表示的卡片。
function c89111398.filter(c)
	return c:IsFaceup()
end
-- 破坏效果的发动目标确认（必发效果）。
function c89111398.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上除这张卡以外的所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(c89111398.filter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置操作信息，表明此效果将破坏上述获取的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的实际执行。
function c89111398.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时双方场上除这张卡以外的所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(c89111398.filter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 因效果破坏这些怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
