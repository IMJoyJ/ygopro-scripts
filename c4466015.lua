--ヴェノム・スプラッシュ
-- 效果：
-- 选择1只放置有毒指示物的怪兽发动。把那张卡的毒指示物取除，给与对方基本分取除的毒指示物数量×700的数值的伤害。
function c4466015.initial_effect(c)
	-- 效果原文内容：选择1只放置有毒指示物的怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c4466015.target)
	e1:SetOperation(c4466015.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检索满足条件的卡片组（有毒素指示物的怪兽）
function c4466015.filter(c)
	return c:GetCounter(0x1009)>0
end
-- 效果原文内容：把那张卡的毒指示物取除，给与对方基本分取除的毒指示物数量×700的数值的伤害。
function c4466015.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4466015.filter(chkc) end
	-- 效果作用：判断是否满足发动条件（场上存在1只以上有毒素指示物的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c4466015.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 效果作用：向玩家提示“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果作用：选择目标怪兽（必须是场上表侧表示且有毒素指示物的怪兽）
	local g=Duel.SelectTarget(tp,c4466015.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 效果作用：设置连锁操作信息，确定将要造成伤害的数值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetCounter(0x1009)*700)
end
-- 效果作用：处理效果的发动，移除目标怪兽上的毒素指示物并造成伤害
function c4466015.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	local ct=tc:GetCounter(0x1009)
	if ct>0 then
		tc:RemoveCounter(tp,0x1009,ct,REASON_EFFECT)
		-- 效果作用：对对方玩家造成伤害，伤害值为毒素指示物数量×700
		Duel.Damage(1-tp,ct*700,REASON_EFFECT)
	end
end
