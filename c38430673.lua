--グランドクロス
-- 效果：
-- 自己场上有「大宇宙」存在时才能发动。给与对方基本分300分伤害，场上的怪兽全部破坏。
function c38430673.initial_effect(c)
	-- 将卡号30241314（「大宇宙」）加入本卡的代码列表，标记这张卡的效果文中记载了「大宇宙」的卡名，用于相关关联判定。
	aux.AddCodeList(c,30241314)
	-- 自己场上有「大宇宙」存在时才能发动。给与对方基本分300分伤害，场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c38430673.condition)
	e1:SetTarget(c38430673.target)
	e1:SetOperation(c38430673.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器：匹配表侧表示且卡号为30241314（「大宇宙」）的卡。
function c38430673.filter(c)
	return c:IsFaceup() and c:IsCode(30241314)
end
-- 定义发动条件：自己场上存在1张以上符合filter的表侧表示「大宇宙」。
function c38430673.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以自己视角看，自己场上（怪兽区域+魔法与陷阱区域）是否存在至少1张表侧表示且卡号为30241314的卡。
	return Duel.IsExistingMatchingCard(c38430673.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 发动时的目标与操作信息设定：无对象，登记将造成300伤害和破坏场上所有怪兽；chk==0时先返回true表示可以正常发动。
function c38430673.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得双方场上所有怪兽区域中的怪兽（不排除任何卡），作为后续要破坏的候选集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 登记操作信息：本连锁将给与对方（1-tp）300点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
	-- 登记操作信息：本连锁将破坏怪兽集合g中的所有怪兽，数量为g:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：先给与对方300点伤害，再取场上所有怪兽并全部破坏。
function c38430673.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因给与对方（1-tp）300点伤害。
	Duel.Damage(1-tp,300,REASON_EFFECT)
	-- 效果伤害处理后，重新获取当前场上双方所有怪兽，作为破坏的对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因破坏场上所有怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
