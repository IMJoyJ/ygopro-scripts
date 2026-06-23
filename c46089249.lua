--コアキリング
-- 效果：
-- 把手卡1张「核成兽的钢核」给对方观看发动。把场上表侧表示存在的1只怪兽破坏，双方受到1000分伤害。
function c46089249.initial_effect(c)
	-- 记录此卡具有「核成兽的钢核」这张卡名
	aux.AddCodeList(c,36623431)
	-- 把手卡1张「核成兽的钢核」给对方观看发动。把场上表侧表示存在的1只怪兽破坏，双方受到1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c46089249.cost)
	e1:SetTarget(c46089249.target)
	e1:SetOperation(c46089249.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查手牌中是否存在未公开的「核成兽的钢核」
function c46089249.cfilter(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- 费用处理：确认手牌中存在「核成兽的钢核」并展示给对方玩家，然后洗切自己的手牌
function c46089249.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张「核成兽的钢核」
	if chk==0 then return Duel.IsExistingMatchingCard(c46089249.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要展示给对方的「核成兽的钢核」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择1张手牌中的「核成兽的钢核」
	local g=Duel.SelectMatchingCard(tp,c46089249.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的「核成兽的钢核」
	Duel.ConfirmCards(1-tp,g)
	-- 将自己的手牌洗切
	Duel.ShuffleHand(tp)
end
-- 过滤函数：检查目标是否为表侧表示怪兽
function c46089249.filter(c)
	return c:IsFaceup()
end
-- 效果发动时点处理：选择场上1只表侧表示怪兽作为破坏对象，并设置操作信息
function c46089249.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c46089249.filter(chkc) end
	-- 检查场上是否存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c46089249.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示怪兽作为目标
	local g=Duel.SelectTarget(tp,c46089249.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置双方各受到1000伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- 效果发动处理：对选定怪兽进行破坏，并使双方各受到1000伤害
function c46089249.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 若目标怪兽存在且有效，则进行破坏操作
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			-- 给对方造成1000点伤害
			Duel.Damage(1-tp,1000,REASON_EFFECT,true)
			-- 给自己造成1000点伤害
			Duel.Damage(tp,1000,REASON_EFFECT,true)
			-- 触发伤害处理完成的时点
			Duel.RDComplete()
		end
	end
end
