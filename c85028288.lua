--ジュラック・タイタン
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：双方不能把场上的这张卡作为陷阱·怪兽的效果的对象。
-- ②：1回合1次，从自己墓地把1只攻击力1700以下的「朱罗纪」怪兽除外才能发动。这张卡的攻击力直到回合结束时上升1000。
function c85028288.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：双方不能把场上的这张卡作为陷阱·怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c85028288.efilter)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从自己墓地把1只攻击力1700以下的「朱罗纪」怪兽除外才能发动。这张卡的攻击力直到回合结束时上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85028288,0))  --"攻击上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c85028288.atkcost)
	e3:SetOperation(c85028288.atkop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断效果来源是否为陷阱卡或怪兽卡
function c85028288.efilter(e,re,rp)
	return re:GetHandler():IsType(TYPE_TRAP+TYPE_MONSTER)
end
-- 过滤条件：自己墓地中攻击力1700以下且可以作为代价除外的「朱罗纪」怪兽
function c85028288.cfilter(c)
	return c:IsAttackBelow(1700) and c:IsSetCard(0x22) and c:IsAbleToRemoveAsCost()
end
-- 效果发动代价：从自己墓地将1只满足条件的「朱罗纪」怪兽除外
function c85028288.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己墓地是否存在至少1只满足条件的「朱罗纪」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85028288.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的「朱罗纪」怪兽
	local g=Duel.SelectMatchingCard(tp,c85028288.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：若此卡在场上表侧表示存在，则使其攻击力直到回合结束时上升1000
function c85028288.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
