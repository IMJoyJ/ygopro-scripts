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
-- 过滤器函数：判定该卡是否放置有A指示物（0x100e类型指示物数量大于0）。
function c20985997.filter(c)
	return c:GetCounter(0x100e)>0
end
-- 取对象目标函数：确认对象在场上怪兽区且放置有A指示物，检查场上是否存在满足条件的卡，让玩家选择1只要破坏的怪兽并设为对象，同时设置破坏和伤害的操作信息。
function c20985997.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c20985997.filter(chkc) end
	-- 发动条件检测：检查双方场上是否存在至少1只放置有A指示物且能成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c20985997.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动玩家发送选择提示："请选择要破坏的卡"。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方怪兽区选择1只放置有A指示物的怪兽，并将其设为当前连锁效果的对象。
	local g=Duel.SelectTarget(tp,c20985997.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息：确定要破坏的是所选对象那1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置伤害效果的操作信息：将给双方玩家各造成1000分伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- 效果处理函数：取得对象怪兽，确认其仍放置有A指示物且与本效果有联系，将其以效果破坏，破坏成功则双方各受到1000分伤害。
function c20985997.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（即选择要破坏的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:GetCounter(0x100e)>0 and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象怪兽，并确认破坏成功（实际破坏数量大于0）。
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			-- 给对方玩家造成1000分效果伤害（is_step为true，进入伤害处理步骤）。
			Duel.Damage(1-tp,1000,REASON_EFFECT,true)
			-- 给发动玩家自己造成1000分效果伤害（is_step为true，进入伤害处理步骤）。
			Duel.Damage(tp,1000,REASON_EFFECT,true)
			-- 完成分解的伤害处理步骤，触发伤害相关的时点。
			Duel.RDComplete()
		end
	end
end
