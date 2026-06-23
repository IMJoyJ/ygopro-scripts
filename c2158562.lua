--サイバー・プリマ
-- 效果：
-- ①：这张卡上级召唤的场合发动。场上的表侧表示的魔法卡全部破坏。
function c2158562.initial_effect(c)
	-- ①：这张卡上级召唤的场合发动。场上的表侧表示的魔法卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2158562,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c2158562.descon)
	e1:SetTarget(c2158562.destg)
	e1:SetOperation(c2158562.desop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡是上级召唤成功时才能发动
function c2158562.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤函数：筛选场上表侧表示的魔法卡
function c2158562.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 效果处理目标设定：检索满足条件的魔法卡并设置为破坏对象
function c2158562.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索满足条件的场上魔法卡组
	local g=Duel.GetMatchingGroup(c2158562.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息为破坏效果，目标为检索到的魔法卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理执行：将满足条件的魔法卡全部破坏
function c2158562.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的场上魔法卡组
	local g=Duel.GetMatchingGroup(c2158562.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将目标魔法卡以效果原因破坏
	Duel.Destroy(g,REASON_EFFECT)
end
