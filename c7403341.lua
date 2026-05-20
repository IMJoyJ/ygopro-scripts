--サイバネット・コンフリクト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「码语者」怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并除外。直到下个回合的结束时，对方不能把原本卡名和这个效果除外的卡相同的卡的效果发动。
function c7403341.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「码语者」怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并除外。直到下个回合的结束时，对方不能把原本卡名和这个效果除外的卡相同的卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,7403341+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c7403341.condition)
	-- 设置效果的目标为无效并除外操作
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c7403341.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「码语者」怪兽
function c7403341.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x101)
end
-- 发动条件：自己场上有「码语者」怪兽存在，且有怪兽的效果·魔法·陷阱卡发动，并且该发动可以被无效
function c7403341.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「码语者」怪兽
	return Duel.IsExistingMatchingCard(c7403341.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查被连锁的效果是否为怪兽效果或魔陷的发动，且该发动可以被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 效果处理：使发动无效并除外，并限制对方直到下个回合结束时不能发动同名卡的效果
function c7403341.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	-- 如果成功无效该发动，且该卡与效果相关，则将其除外
	if Duel.NegateActivation(ev) and tc:IsRelateToEffect(re) and Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_REMOVED) and not tc:IsReason(REASON_REDIRECT) then
		-- 直到下个回合的结束时，对方不能把原本卡名和这个效果除外的卡相同的卡的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(c7403341.aclimit)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将限制对方发动效果的永续效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制发动的条件：不能发动与被除外卡片原本卡名相同的卡的效果
function c7403341.aclimit(e,re,tp)
	local c=re:GetHandler()
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
