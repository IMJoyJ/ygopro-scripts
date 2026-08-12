--オートマチック・レーザー
-- 效果：
-- 对方对攻击力1000以上的怪兽的召唤·特殊召唤成功时，把手卡1张「核成兽的钢核」给对方观看发动。那些怪兽破坏。
function c58990631.initial_effect(c)
	-- 注册卡片记有「核成兽的钢核」卡名
	aux.AddCodeList(c,36623431)
	-- 对方对攻击力1000以上的怪兽的召唤成功时，把手卡1张「核成兽的钢核」给对方观看发动。那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(c58990631.cost)
	e1:SetTarget(c58990631.target)
	e1:SetOperation(c58990631.activate)
	c:RegisterEffect(e1)
	-- 对方对攻击力1000以上的怪兽的特殊召唤成功时，把手卡1张「核成兽的钢核」给对方观看发动。那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCost(c58990631.cost)
	e2:SetTarget(c58990631.target2)
	e2:SetOperation(c58990631.activate2)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中未公开的「核成兽的钢核」
function c58990631.cfilter(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- Cost处理：把手卡1张「核成兽的钢核」给对方观看
function c58990631.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在未公开的「核成兽的钢核」
	if chk==0 then return Duel.IsExistingMatchingCard(c58990631.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置选择卡片时的提示信息为确认卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中1张未公开的「核成兽的钢核」
	local g=Duel.SelectMatchingCard(tp,c58990631.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 给对方玩家确认选中的卡片
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自身手卡
	Duel.ShuffleHand(tp)
end
-- 过滤条件：对方召唤成功的表侧表示且攻击力1000以上的怪兽
function c58990631.filter(c,tp,ep)
	return c:IsFaceup() and c:IsAttackAbove(1000)
		and ep~=tp
end
-- 召唤成功时的效果靶向处理：检查并设置要破坏的怪兽
function c58990631.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return c58990631.filter(tc,tp,ep) end
	-- 将召唤成功的怪兽群设为效果处理的目标
	Duel.SetTargetCard(eg)
	-- 设置效果处理信息：破坏该召唤成功的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 召唤成功时的效果执行处理：破坏该怪兽
function c58990631.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackAbove(1000) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤条件：对方特殊召唤成功的表侧表示且攻击力1000以上的怪兽
function c58990631.filter2(c,tp)
	return c:IsFaceup() and c:IsAttackAbove(1000) and c:IsSummonPlayer(1-tp)
end
-- 特殊召唤成功时的效果靶向处理：检查并设置要破坏的怪兽群
function c58990631.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c58990631.filter2,1,nil,tp) end
	local g=eg:Filter(c58990631.filter2,nil,tp)
	-- 将特殊召唤成功的怪兽群设为效果处理的目标
	Duel.SetTargetCard(eg)
	-- 设置效果处理信息：破坏这些特殊召唤成功的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤条件：特殊召唤成功、表侧表示、攻击力1000以上、由对方特殊召唤且仍与本效果存在联系的怪兽
function c58990631.filter3(c,e,tp)
	return c:IsFaceup() and c:IsAttackAbove(1000) and c:IsSummonPlayer(1-tp)
		and c:IsRelateToEffect(e)
end
-- 特殊召唤成功时的效果执行处理：破坏这些怪兽
function c58990631.activate2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c58990631.filter3,nil,e,tp)
	if g:GetCount()>0 then
		-- 因效果破坏这些怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
