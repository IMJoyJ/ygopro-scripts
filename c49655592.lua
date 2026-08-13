--F.A.ウィップクロッサー
-- 效果：
-- ①：这张卡的攻击力上升这张卡的等级×300，对方若不支付300基本分，则不能把原本的等级或者阶级比这张卡的等级低的怪兽的效果发动。
-- ②：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
-- ③：这张卡的等级是7星以上的场合，对方不能把要把手卡丢弃发动的效果以及要把手卡送去墓地发动的效果发动。
function c49655592.initial_effect(c)
	-- ①：这张卡的攻击力上升这张卡的等级×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c49655592.atkval)
	c:RegisterEffect(e1)
	-- ①：对方若不支付300基本分，则不能把原本的等级或者阶级比这张卡的等级低的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCost(c49655592.costchk)
	e2:SetTarget(c49655592.costtg)
	e2:SetOperation(c49655592.costop)
	c:RegisterEffect(e2)
	-- ①：对方若不支付300基本分
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_FLAG_EFFECT+49655592)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
	-- ②：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(49655592,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(c49655592.lvcon)
	e4:SetOperation(c49655592.lvop)
	c:RegisterEffect(e4)
	-- ③：这张卡的等级是7星以上的场合，对方不能把要把手卡丢弃发动的效果发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetCode(EFFECT_CANNOT_DISCARD_HAND)
	e5:SetCondition(c49655592.excon)
	e5:SetTarget(c49655592.extarget)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- ③：这张卡的等级是7星以上的场合，对方不能把要把手卡送去墓地发动的效果发动。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_TO_GRAVE_AS_COST)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_HAND)
	e6:SetCondition(c49655592.excon)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end
-- 计算这张卡的攻击力上升值：这张卡的当前等级×300。
function c49655592.atkval(e,c)
	return c:GetLevel()*300
end
-- ②的发动条件：判定正在连锁的效果是否为「方程式运动员」魔法·陷阱卡的效果发动（伤害步骤也能发动）。
function c49655592.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(0x107)
end
-- ②效果处理：此卡仍存在于场上且表侧表示时，使其等级上升1星，等级提升持续到标准重置条件触发。
function c49655592.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 检查对方能否支付发动怪兽效果所需的基本分：根据其身上本卡效果标志数计算所需LP，并判定LP是否足够。
function c49655592.costchk(e,te_or_c,tp)
	-- 获取对方玩家身上本卡效果标志的数量（场上同名卡数量），用于计算需要支付的基本分。
	local ct=Duel.GetFlagEffect(tp,49655592)
	-- 检查对方玩家能否支付 ct×300 基本分作为发动代价。
	return Duel.CheckLPCost(tp,ct*300)
end
-- 判定对方发动的效果是否为原本等级或阶级低于此卡当前等级的怪兽效果，若是则需要支付300基本分才能发动。
function c49655592.costtg(e,te,tp)
	if not te:IsActiveType(TYPE_MONSTER) then return false end
	local tc=te:GetHandler()
	local lv=e:GetHandler():GetLevel()
	if tc:GetRank()>0 then
		return tc:GetOriginalRank()<lv
	elseif tc:GetLevel()>0 then
		return tc:GetOriginalLevel()<lv
	else return false end
end
-- 对方发动符合条件的怪兽效果时，强制支付300基本分作为发动代价。
function c49655592.costop(e,tp,eg,ep,ev,re,r,rp)
	-- 对方支付300基本分。
	Duel.PayLPCost(tp,300)
end
-- ③的限制条件：此卡等级为7星以上时，对方不能把手卡丢弃或送去墓地作为发动效果的费用。
function c49655592.excon(e)
	return e:GetHandler():IsLevelAbove(7)
end
-- 判断手牌是否将被作为发动效果的代价而丢弃，若是则禁止该效果发动（对应对方不能发动把手卡丢弃的效果）。
function c49655592.extarget(e,dc,re,r)
	return r&REASON_COST==REASON_COST
end
