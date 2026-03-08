--古代の機械爆弾
-- 效果：
-- 把自己场上表侧表示存在的1只名字带有「古代的机械」的怪兽作为对象才能发动。对象的怪兽破坏，给与对方基本分那只怪兽的原本攻击力一半数值的伤害。
function c4446672.initial_effect(c)
	-- 效果原文内容：把自己场上表侧表示存在的1只名字带有「古代的机械」的怪兽作为对象才能发动。对象的怪兽破坏，给与对方基本分那只怪兽的原本攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c4446672.target)
	e1:SetOperation(c4446672.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：表侧表示且名字带有「古代的机械」的怪兽
function c4446672.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7)
end
-- 效果作用：选择对象怪兽并设置操作信息
function c4446672.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4446672.filter(chkc) end
	-- 效果作用：判断是否满足发动条件，即自己场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c4446672.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c4446672.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 效果作用：设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 效果作用：设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果作用：处理效果发动后的破坏与伤害
function c4446672.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：执行破坏操作并判断是否成功
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			-- 效果作用：对对方造成伤害，伤害值为对象怪兽原本攻击力的一半
			Duel.Damage(1-tp,math.floor(tc:GetBaseAttack()/2),REASON_EFFECT)
		end
	end
end
