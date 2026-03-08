--硫酸のたまった落とし穴
-- 效果：
-- ①：以场上1只里侧守备表示怪兽为对象才能发动。那只怪兽变成表侧守备表示，守备力是2000以下的场合破坏。守备力比2000高的场合回到里侧守备表示。
function c41356845.initial_effect(c)
	-- 效果原文内容：①：以场上1只里侧守备表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c41356845.target)
	e1:SetOperation(c41356845.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选位置为里侧守备表示的怪兽
function c41356845.filter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- 效果作用：选择1只里侧守备表示的怪兽作为效果对象
function c41356845.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c41356845.filter(chkc) end
	-- 效果作用：检查场上是否存在里侧守备表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c41356845.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 效果作用：提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果作用：选择目标怪兽
	local g=Duel.SelectTarget(tp,c41356845.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 效果作用：设置连锁操作信息，指定改变表示形式的效果
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果原文内容：那只怪兽变成表侧守备表示，守备力是2000以下的场合破坏。守备力比2000高的场合回到里侧守备表示。
function c41356845.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 效果作用：确认对象怪兽有效且成功改变表示形式为表侧守备
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		if tc:IsDefenseBelow(2000) then
			-- 效果作用：中断当前效果处理
			Duel.BreakEffect()
			-- 效果作用：破坏对象怪兽
			Duel.Destroy(tc,REASON_EFFECT)
		else
			-- 效果作用：向对方确认对象怪兽的卡面
			Duel.ConfirmCards(1-tc:GetControler(),tc)
			-- 效果作用：将对象怪兽改变为里侧守备表示
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
