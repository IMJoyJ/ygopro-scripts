--トライアングル・X・スパーク
-- 效果：
-- ①：场上的全部「鹰身女郎三姐妹」的攻击力直到回合结束时变成2700。这个回合，对方不能把陷阱卡发动，对方场上的陷阱卡的效果无效化。
function c12181376.initial_effect(c)
	-- 将卡号12206212（鹰身女郎三姐妹）加入这张卡记载的卡名列表，用于后续效果关联判定。
	aux.AddCodeList(c,12206212)
	-- ①：场上的全部「鹰身女郎三姐妹」的攻击力直到回合结束时变成2700。这个回合，对方不能把陷阱卡发动，对方场上的陷阱卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c12181376.target)
	e1:SetOperation(c12181376.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定场上表侧表示且卡号为12206212的怪兽，即「鹰身女郎三姐妹」。
function c12181376.filter(c)
	return c:IsFaceup() and c:IsCode(12206212)
end
-- 效果发动前的目标判定函数：确认场上是否存在至少1只符合条件的「鹰身女郎三姐妹」，作为发动条件。
function c12181376.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点（chk==0）检查场上是否存在至少1只表侧表示的「鹰身女郎三姐妹」，若存在则可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c12181376.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果处理函数：使场上所有「鹰身女郎三姐妹」攻击力变成2700，并给对方附加“不能发动陷阱卡”和“陷阱卡效果无效化”的回合限制。
function c12181376.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有表侧表示的「鹰身女郎三姐妹」的集合，用于统一改变攻击力。
	local g=Duel.GetMatchingGroup(c12181376.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 场上的全部「鹰身女郎三姐妹」的攻击力直到回合结束时变成2700。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(2700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 这个回合，对方不能把陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c12181376.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对方不能发动陷阱卡”的永续效果注册到场上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 对方场上的陷阱卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(0,LOCATION_SZONE)
	e2:SetTarget(c12181376.distg)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对方魔陷区的陷阱卡效果无效化”的永续效果注册到场上，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
	-- 对方场上的陷阱卡的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c12181376.distg)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对方怪兽区的陷阱怪兽效果无效化”的永续效果注册到场上，持续到回合结束。
	Duel.RegisterEffect(e3,tp)
end
-- 限制函数：判断对方发动的效果是否为陷阱卡的发动，若是则不能发动。
function c12181376.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
-- 目标筛选函数：判断卡片是否为陷阱卡，用于无效化处理。
function c12181376.distg(e,c)
	return c:IsType(TYPE_TRAP)
end
