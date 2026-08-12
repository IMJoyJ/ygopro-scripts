--セイバー・スラッシュ
-- 效果：
-- ①：把自己场上的攻击表示的「X-剑士」怪兽数量的场上的表侧表示卡破坏。
function c11052544.initial_effect(c)
	-- ①：把自己场上的攻击表示的「X-剑士」怪兽数量的场上的表侧表示卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c11052544.target)
	e1:SetOperation(c11052544.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡是否为表侧表示
function c11052544.filter(c)
	return c:IsFaceup()
end
-- 过滤函数，用于判断卡是否为攻击表示且为「X-剑士」族
function c11052544.cfilter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsSetCard(0x100d)
end
-- 效果的发动时点处理函数
function c11052544.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 统计自己场上攻击表示的「X-剑士」怪兽数量
		local ct=Duel.GetMatchingGroupCount(c11052544.cfilter,tp,LOCATION_MZONE,0,nil)
		e:SetLabel(ct)
		-- 检查自己场上是否存在满足条件的表侧表示卡
		return Duel.IsExistingMatchingCard(c11052544.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,c)
	end
	local ct=e:GetLabel()
	-- 获取自己场上所有表侧表示卡的集合
	local sg=Duel.GetMatchingGroup(c11052544.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置连锁处理信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,ct,0,0)
end
-- 效果的发动处理函数
function c11052544.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己场上攻击表示的「X-剑士」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c11052544.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取自己场上所有表侧表示卡的集合（排除此卡）
	local g=Duel.GetMatchingGroup(c11052544.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if g:GetCount()>=ct then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,ct,ct,nil)
		-- 显示选中的卡被选为对象的动画效果
		Duel.HintSelection(sg)
		-- 将选中的卡以效果原因破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
