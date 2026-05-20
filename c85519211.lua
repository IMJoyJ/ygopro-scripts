--岩盤爆破
-- 效果：
-- 自己场上表侧表示存在的「地雷石人」每有1只，给与对方基本分1000分的伤害。之后自己场上表侧表示存在的「地雷石人」全部破坏。
function c85519211.initial_effect(c)
	-- 自己场上表侧表示存在的「地雷石人」每有1只，给与对方基本分1000分的伤害。之后自己场上表侧表示存在的「地雷石人」全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c85519211.target)
	e1:SetOperation(c85519211.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「地雷石人」
function c85519211.filter(c)
	return c:IsFaceup() and c:IsCode(76321376)
end
-- 效果发动的目标确认与操作信息设置
function c85519211.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的「地雷石人」
	if chk==0 then return Duel.IsExistingMatchingCard(c85519211.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有表侧表示的「地雷石人」卡片组
	local g=Duel.GetMatchingGroup(c85519211.filter,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息：预计破坏自己场上所有表侧表示的「地雷石人」
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：预计给与对方「地雷石人」数量×1000的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*1000)
end
-- 效果处理：给与对方伤害，之后破坏自己场上所有的「地雷石人」
function c85519211.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上所有表侧表示的「地雷石人」卡片组
	local g=Duel.GetMatchingGroup(c85519211.filter,tp,LOCATION_MZONE,0,nil)
	-- 给与对方「地雷石人」数量×1000的伤害，若未成功造成伤害则不继续处理
	if Duel.Damage(1-tp,g:GetCount()*1000,REASON_EFFECT)==0 then return end
	-- 中断当前效果，使之后的破坏处理与伤害处理视为不同时进行
	Duel.BreakEffect()
	-- 破坏自己场上所有表侧表示的「地雷石人」
	Duel.Destroy(g,REASON_EFFECT)
end
