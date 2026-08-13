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
-- 效果发动条件：这张卡的召唤类型为上级召唤（即上级召唤成功时），才满足发动条件。
function c2158562.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 筛选条件：场上表侧表示的魔法卡，用于确定要被破坏的卡片。
function c2158562.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 效果发动时的目标处理：该效果不取对象，取得场上所有表侧表示的魔法卡作为破坏对象，并设置对应的破坏操作信息。
function c2158562.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取以当前玩家视角看到的场上（双方场上）所有满足条件的表侧表示魔法卡。
	local g=Duel.GetMatchingGroup(c2158562.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本次效果将破坏上述所有卡片，数量为g:GetCount()，用于给其他卡片（如星尘龙）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时的操作：再次获取场上所有表侧表示的魔法卡，并将其全部破坏。
function c2158562.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取场上所有表侧表示的魔法卡，防止发动时和處理时场上的卡发生变化。
	local g=Duel.GetMatchingGroup(c2158562.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 以效果（REASON_EFFECT）为原因，将获取到的那些魔法卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
