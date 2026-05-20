--弾幕回避
-- 效果：
-- 把自己场上的「幻兽机衍生物」全部解放才能发动。效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
function c6260554.initial_effect(c)
	-- 把自己场上的「幻兽机衍生物」全部解放才能发动。效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c6260554.condition)
	e1:SetCost(c6260554.cost)
	e1:SetTarget(c6260554.target)
	e1:SetOperation(c6260554.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c6260554.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的发动是否可以被无效，且该发动是效果怪兽的效果、魔法或陷阱卡的发动
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 过滤可以被解放且未处于战斗破坏确定状态的卡片
function c6260554.filter(c)
	return c:IsReleasable() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 定义发动代价函数，检查并解放自己场上所有的「幻兽机衍生物」
function c6260554.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有的「幻兽机衍生物」（卡号为31533705）
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705)
	if chk==0 then return g:GetCount()>0 and g:FilterCount(c6260554.filter,nil)==g:GetCount() end
	-- 解放这些「幻兽机衍生物」作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 定义效果目标函数，设置无效与破坏的操作信息
function c6260554.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果包含使发动无效的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示此效果包含破坏该卡的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果处理函数，执行无效并破坏的操作
function c6260554.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该连锁的发动无效，且该卡在效果处理时仍与该效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效发动的卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
