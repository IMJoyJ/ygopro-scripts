--破壊指輪
-- 效果：
-- 破坏自己场上1只表侧表示的怪兽，双方各受1000点伤害。
function c21219755.initial_effect(c)
	-- 效果原文内容：破坏自己场上1只表侧表示的怪兽，双方各受1000点伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c21219755.target)
	e1:SetOperation(c21219755.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断目标怪兽是否表侧表示
function c21219755.filter(c)
	return c:IsFaceup()
end
-- 效果作用：选择破坏对象，设置破坏和伤害的连锁信息
function c21219755.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21219755.filter(chkc) end
	-- 效果作用：判断是否满足发动条件，即自己场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c21219755.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 效果作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择1只自己场上的表侧表示怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c21219755.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 效果作用：设置连锁操作信息，确定要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 效果作用：设置连锁操作信息，确定双方各受到1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- 效果作用：处理效果发动后的破坏和伤害流程
function c21219755.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 效果作用：执行破坏操作，若成功则继续造成伤害
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			-- 效果作用：给对方造成1000点伤害
			Duel.Damage(1-tp,1000,REASON_EFFECT,true)
			-- 效果作用：给自己造成1000点伤害
			Duel.Damage(tp,1000,REASON_EFFECT,true)
			-- 效果作用：完成伤害处理的时点触发
			Duel.RDComplete()
		end
	end
end
