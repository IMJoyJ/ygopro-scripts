--トライアングル・X・スパーク
-- 效果：
-- ①：场上的全部「鹰身女郎三姐妹」的攻击力直到回合结束时变成2700。这个回合，对方不能把陷阱卡发动，对方场上的陷阱卡的效果无效化。
function c12181376.initial_effect(c)
	-- 为卡片注册「鹰身女郎三姐妹」的卡片代码，用于后续效果判断
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
-- 过滤函数，用于判断目标怪兽是否为表侧表示的「鹰身女郎三姐妹」
function c12181376.filter(c)
	return c:IsFaceup() and c:IsCode(12206212)
end
-- 效果的发动时点处理函数，用于判断是否满足发动条件
function c12181376.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张表侧表示的「鹰身女郎三姐妹」
	if chk==0 then return Duel.IsExistingMatchingCard(c12181376.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果的发动处理函数，用于执行效果内容
function c12181376.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有表侧表示的「鹰身女郎三姐妹」
	local g=Duel.GetMatchingGroup(c12181376.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使目标怪兽的攻击力变为2700
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(2700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 使对方在本回合不能发动陷阱卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c12181376.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 使对方场上的陷阱卡效果无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(0,LOCATION_SZONE)
	e2:SetTarget(c12181376.distg)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
	-- 使对方场上的陷阱怪兽效果无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c12181376.distg)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e3,tp)
end
-- 用于判断是否为陷阱卡发动的限制条件
function c12181376.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
-- 用于判断目标是否为陷阱卡
function c12181376.distg(e,c)
	return c:IsType(TYPE_TRAP)
end
