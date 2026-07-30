--デストラクト・サークル－A
-- 效果：
-- 把场上表侧表示存在的1只放置有A指示物的怪兽破坏，双方受到1000分伤害。
function c20985997.initial_effect(c)
	-- 把场上表侧表示存在的1只放置有A指示物的怪兽破坏，双方受到1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20985997.target)
	e1:SetOperation(c20985997.activate)
	c:RegisterEffect(e1)
end
c20985997.mentioned_counter={
	[0x100e]=true,
}
-- 检索满足条件的卡片组
function c20985997.filter(c)
	return c:GetCounter(0x100e)>0
end
-- 选择破坏对象
function c20985997.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c20985997.filter(chkc) end
	-- 检索满足条件的卡片组
	if chk==0 then return Duel.IsExistingTarget(c20985997.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c20985997.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- 处理效果发动
function c20985997.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:GetCounter(0x100e)>0 and tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			-- 给对方造成1000分伤害
			Duel.Damage(1-tp,1000,REASON_EFFECT,true)
			-- 给自己造成1000分伤害
			Duel.Damage(tp,1000,REASON_EFFECT,true)
			-- 触发伤害/回复LP过程的时点
			Duel.RDComplete()
		end
	end
end
