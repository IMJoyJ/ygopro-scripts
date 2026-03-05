--デストラクト・サークル－A
-- 效果：
-- 把场上表侧表示存在的1只放置有A指示物的怪兽破坏，双方受到1000分伤害。
function c20985997.initial_effect(c)
	-- 效果原文内容：把场上表侧表示存在的1只放置有A指示物的怪兽破坏，双方受到1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20985997.target)
	e1:SetOperation(c20985997.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的怪兽（场上表侧表示存在且放置有A指示物）
function c20985997.filter(c)
	return c:GetCounter(0x100e)>0
end
-- 效果作用：选择1只满足条件的怪兽作为破坏对象
function c20985997.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c20985997.filter(chkc) end
	-- 判断是否满足发动条件（场上是否存在1只放置有A指示物的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c20985997.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1只满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c20985997.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将选中的怪兽破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：双方各受到1000分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- 效果作用：处理破坏和伤害
function c20985997.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:GetCounter(0x100e)>0 and tc:IsRelateToEffect(e) then
		-- 破坏目标怪兽（满足条件且在场）
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			-- 给对方玩家造成1000分伤害
			Duel.Damage(1-tp,1000,REASON_EFFECT,true)
			-- 给发动玩家造成1000分伤害
			Duel.Damage(tp,1000,REASON_EFFECT,true)
			-- 触发伤害处理完成的时点
			Duel.RDComplete()
		end
	end
end
