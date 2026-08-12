--クマモール
-- 效果：
-- ①：只要这张卡在怪兽区域存在，对方回合内，自己的魔法与陷阱区域盖放的卡不会被效果破坏。
-- ②：每次自己的魔法与陷阱区域盖放的卡被对方的效果破坏发动。这张卡的攻击力直到回合结束时上升800。
function c80141055.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方回合内，自己的魔法与陷阱区域盖放的卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetCondition(c80141055.indcon)
	e1:SetTarget(c80141055.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：每次自己的魔法与陷阱区域盖放的卡被对方的效果破坏发动。这张卡的攻击力直到回合结束时上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80141055,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c80141055.atkcon)
	e2:SetOperation(c80141055.atkop)
	c:RegisterEffect(e2)
end
-- 定义效果①的生效条件函数，限制仅在对方回合适用
function c80141055.indcon(e)
	-- 判断当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 定义效果①的影响对象过滤函数，筛选出魔法与陷阱区域（不含场地区）盖放的卡
function c80141055.indtg(e,c)
	return c:GetSequence()<5 and c:IsFacedown()
end
-- 过滤出原本在自己的魔法与陷阱区域（不含场地区）盖放且因效果被破坏的卡
function c80141055.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousSequence()<5 and c:IsPreviousPosition(POS_FACEDOWN) and c:IsReason(REASON_EFFECT)
end
-- 定义效果②的触发条件，判断是否由对方的效果破坏了自己魔陷区盖放的卡
function c80141055.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c80141055.cfilter,1,nil,tp)
end
-- 定义效果②的解决函数，使这张卡的攻击力直到回合结束时上升800
function c80141055.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
