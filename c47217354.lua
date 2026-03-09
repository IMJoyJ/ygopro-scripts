--魔轟神レイヴン
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。选自己手卡任意数量丢弃，直到回合结束时，这张卡的等级上升丢弃数量的数值，攻击力上升丢弃数量×400。
function c47217354.initial_effect(c)
	-- 效果原文内容：①：1回合1次，自己主要阶段才能发动。选自己手卡任意数量丢弃，直到回合结束时，这张卡的等级上升丢弃数量的数值，攻击力上升丢弃数量×400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47217354,0))  --"等级、攻击上升"
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c47217354.tg)
	e1:SetOperation(c47217354.op)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否可以发动此效果，条件为己方手牌数量大于0
function c47217354.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否可以发动此效果，条件为己方手牌数量大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 效果作用：设置连锁操作信息，表示将要处理丢弃手牌的效果
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果作用：执行效果的处理流程，包括丢弃手牌并根据丢弃数量提升攻击力和等级
function c47217354.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：检索满足条件的卡片组并丢弃1至60张手牌
	local ct=Duel.DiscardHand(tp,aux.TRUE,1,60,REASON_EFFECT+REASON_DISCARD)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 效果原文内容：直到回合结束时，这张卡的攻击力上升丢弃数量×400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*400)
		c:RegisterEffect(e1)
		-- 效果原文内容：直到回合结束时，这张卡的等级上升丢弃数量的数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e2:SetValue(ct)
		c:RegisterEffect(e2)
	end
end
