--CNo.107 超銀河眼の時空龍
-- 效果：
-- 9星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这个回合对方不能把场上发动的效果发动，这张卡以外的场上的全部表侧表示卡的效果直到回合结束时无效化。
-- ②：这张卡有「No.107 银河眼时空龙」在作为超量素材的场合，得到以下效果。
-- ●把自己场上2只其他怪兽解放才能发动。这个回合，这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
function c68396121.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：需要3只9星怪兽。
	aux.AddXyzProcedure(c,nil,9,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这个回合对方不能把场上发动的效果发动，这张卡以外的场上的全部表侧表示卡的效果直到回合结束时无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68396121,0))  --"效果无效"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c68396121.negcost)
	e1:SetOperation(c68396121.negop)
	c:RegisterEffect(e1)
	-- ②：这张卡有「No.107 银河眼时空龙」在作为超量素材的场合，得到以下效果。●把自己场上2只其他怪兽解放才能发动。这个回合，这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68396121,1))  --"多次攻击"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c68396121.atkcon)
	e2:SetCost(c68396121.atkcost)
	e2:SetTarget(c68396121.atktg)
	e2:SetOperation(c68396121.atkop)
	c:RegisterEffect(e2)
end
-- 设定这张卡的「No.」编号为107。
aux.xyz_number[68396121]=107
-- 效果①的Cost：检查并取除这张卡的1个超量素材。
function c68396121.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的Operation：将这张卡以外场上所有表侧表示卡的效果无效，并限制对方本回合不能发动场上的效果。
function c68396121.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上除这张卡以外的所有可无效的表侧表示卡片。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	local tc=g:GetFirst()
	while tc do
		-- 这张卡以外的场上的全部表侧表示卡的效果直到回合结束时无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这张卡以外的场上的全部表侧表示卡的效果直到回合结束时无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 这个回合对方不能把场上发动的效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c68396121.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局玩家效果，使对方玩家不能发动场上的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的过滤函数：判定发动的效果是否在场上发动（在场上存在，或者是魔法·陷阱卡的发动）。
function c68396121.aclimit(e,re,tp)
	return re:GetHandler():IsOnField() or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果②的Condition：检查当前是否能进入战斗阶段，且这张卡有「No.107 银河眼时空龙」作为超量素材。
function c68396121.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段。
	return Duel.IsAbleToEnterBP()
		and e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,88177324)
end
-- 效果②的Cost：检查并解放自己场上2只其他怪兽。
function c68396121.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外的2只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,e:GetHandler()) end
	-- 选自己场上除这张卡以外的2只怪兽。
	local g=Duel.SelectReleaseGroup(tp,nil,2,2,e:GetHandler())
	-- 将选中的怪兽作为代价解放。
	Duel.Release(g,REASON_COST)
end
-- 效果②的Target：检查这张卡是否尚未获得追加攻击怪兽的效果。
function c68396121.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK_MONSTER)==0 end
end
-- 效果②的Operation：赋予这张卡在同一次战斗阶段中最多3次可以向怪兽攻击的效果。
function c68396121.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
