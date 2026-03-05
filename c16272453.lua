--機甲忍法ゴールド・コンバージョン
-- 效果：
-- 自己场上有名字带有「忍法」的卡存在的场合才能发动。自己场上的名字带有「忍法」的卡全部破坏。那之后，从卡组抽2张卡。
function c16272453.initial_effect(c)
	-- 效果原文内容：自己场上有名字带有「忍法」的卡存在的场合才能发动。自己场上的名字带有「忍法」的卡全部破坏。那之后，从卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c16272453.condition)
	e1:SetTarget(c16272453.target)
	e1:SetOperation(c16272453.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤出场上的表侧表示的「忍法」卡
function c16272453.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x61)
end
-- 效果作用：检查自己场上是否存在名字带有「忍法」的卡
function c16272453.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查自己场上是否存在名字带有「忍法」的卡
	return Duel.IsExistingMatchingCard(c16272453.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果作用：过滤出场上的表侧表示的「忍法」卡
function c16272453.dfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x61)
end
-- 效果作用：设置连锁处理时的抽卡和破坏效果信息
function c16272453.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 效果作用：获取自己场上所有名字带有「忍法」的卡
	local g=Duel.GetMatchingGroup(c16272453.dfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	-- 效果作用：设置破坏效果的目标卡组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 效果作用：设置抽卡效果的目标和数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果作用：执行效果处理，先破坏再抽卡
function c16272453.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取自己场上所有名字带有「忍法」的卡（排除此卡）
	local g=Duel.GetMatchingGroup(c16272453.dfilter,tp,LOCATION_ONFIELD,0,aux.ExceptThisCard(e))
	-- 效果作用：将满足条件的卡全部破坏
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 效果作用：中断当前效果处理，使后续效果视为错时点处理
		Duel.BreakEffect()
		-- 效果作用：让玩家从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
