--最古式念導
-- 效果：
-- 自己场上有念动力族怪兽表侧表示存在的场合才能发动。场上1张卡破坏，自己受到1000分伤害。
function c32180819.initial_effect(c)
	-- 效果原文内容：自己场上有念动力族怪兽表侧表示存在的场合才能发动。场上1张卡破坏，自己受到1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c32180819.condition)
	e1:SetTarget(c32180819.target)
	e1:SetOperation(c32180819.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查怪兽是否为表侧表示且种族为念动力
function c32180819.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 效果作用：判断自己场上是否存在表侧表示的念动力族怪兽
function c32180819.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己场上是否存在表侧表示的念动力族怪兽
	return Duel.IsExistingMatchingCard(c32180819.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：选择场上一张卡作为破坏对象并设置伤害信息
function c32180819.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 效果作用：判断是否满足发动条件，即场上是否存在可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择场上一张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 效果作用：设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 效果作用：设置受到伤害的效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
-- 效果作用：执行破坏和伤害处理
function c32180819.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 效果作用：判断目标卡是否仍然有效并执行破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 效果作用：对玩家造成1000点伤害
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end
