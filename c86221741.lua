--RR－アルティメット・ファルコン
-- 效果：
-- 鸟兽族10星怪兽×3
-- ①：场上的这张卡不受其他卡的效果影响。
-- ②：把这张卡1个超量素材取除才能发动。这个回合中，对方场上的怪兽的攻击力下降1000，对方不能把卡的效果发动。
-- ③：这张卡有「急袭猛禽」怪兽在作为超量素材的场合，得到以下效果。
-- ●自己·对方的结束阶段才能发动。对方场上有表侧表示怪兽存在的场合，那些攻击力下降1000。不存在的场合，给与对方1000伤害。
function c86221741.initial_effect(c)
	-- 添加XYZ召唤手续，需要3只10星的鸟兽族怪兽。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINDBEAST),10,3)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c86221741.efilter)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除才能发动。这个回合中，对方场上的怪兽的攻击力下降1000，对方不能把卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86221741,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c86221741.cost)
	e2:SetOperation(c86221741.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡有「急袭猛禽」怪兽在作为超量素材的场合，得到以下效果。●自己·对方的结束阶段才能发动。对方场上有表侧表示怪兽存在的场合，那些攻击力下降1000。不存在的场合，给与对方1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86221741,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c86221741.atkcon)
	e3:SetTarget(c86221741.atktg)
	e3:SetOperation(c86221741.atkop)
	c:RegisterEffect(e3)
end
-- 过滤不受影响的效果，判断效果的拥有者是否不等于这张卡的拥有者（即不受其他卡的效果影响）。
function c86221741.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 效果②的代价：检查并取除这张卡的1个超量素材。
function c86221741.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的处理：使对方场上怪兽攻击力下降1000，并使对方在这个回合不能发动卡的效果。
function c86221741.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合中，对方场上的怪兽的攻击力下降1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-1000)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册降低对方怪兽攻击力的全局效果。
	Duel.RegisterEffect(e1,tp)
	-- 对方不能把卡的效果发动。③：这张卡有「急袭猛禽」怪兽在作为超量素材的场合，得到以下效果。●自己·对方的结束阶段才能发动。对方场上有表侧表示怪兽存在的场合，那些攻击力下降1000。不存在的场合，给与对方1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册对方不能发动卡的效果的全局效果。
	Duel.RegisterEffect(e2,tp)
end
-- 过滤超量素材中「急袭猛禽」怪兽的条件。
function c86221741.cfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER)
end
-- 效果③的发动条件：检查这张卡的超量素材中是否存在「急袭猛禽」怪兽。
function c86221741.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(c86221741.cfilter,1,nil)
end
-- 效果③的靶向处理：若对方场上没有表侧表示怪兽，则设置给与对方1000伤害的操作信息。
function c86221741.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查对方场上是否存在表侧表示的怪兽。
	if not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) then
		-- 设置给与对方1000点伤害的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	end
end
-- 效果③的效果处理：对方场上有表侧表示怪兽存在的场合，那些怪兽攻击力下降1000；不存在的场合，给与对方1000伤害。
function c86221741.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		while sc do
			-- 那些攻击力下降1000
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(-1000)
			sc:RegisterEffect(e1)
			sc=g:GetNext()
		end
	else
		-- 给与对方1000点效果伤害。
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
