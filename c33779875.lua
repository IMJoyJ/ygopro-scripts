--六花聖ティアドロップ
-- 效果：
-- 8星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除，以自己·对方场上1只怪兽为对象才能发动。那只怪兽解放。这张卡有植物族怪兽在作为超量素材的场合，这个效果在对方回合也能发动。
-- ②：每次怪兽被解放发动。这张卡的攻击力直到回合结束时上升解放的怪兽数量×200。
function c33779875.initial_effect(c)
	-- 为这张卡添加超量召唤手续：需要用2只8星怪兽叠放进行超量召唤。
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：把这张卡1个超量素材取除，以自己·对方场上1只怪兽为对象才能发动。那只怪兽解放。这张卡有植物族怪兽在作为超量素材的场合，这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33779875,0))  --"怪兽解放"
	e1:SetCategory(CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,33779875)
	e1:SetCondition(c33779875.rlcon1)
	e1:SetCost(c33779875.rlcost)
	e1:SetTarget(c33779875.rltg)
	e1:SetOperation(c33779875.rlop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(c33779875.rlcon2)
	c:RegisterEffect(e2)
	-- ②：每次怪兽被解放发动。这张卡的攻击力直到回合结束时上升解放的怪兽数量×200。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33779875,1))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_RELEASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c33779875.atkcon)
	e3:SetOperation(c33779875.atkop)
	c:RegisterEffect(e3)
end
-- ①效果作为起动效果的发动条件：这张卡的超量素材中没有植物族怪兽时才可发动（对应主阶段起动效果）。
function c33779875.rlcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():FilterCount(Card.IsRace,nil,RACE_PLANT)==0
end
-- ①效果作为诱发即时效果的发动条件：这张卡的超量素材中有植物族怪兽时，才可在对方回合发动。
function c33779875.rlcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():FilterCount(Card.IsRace,nil,RACE_PLANT)~=0
end
-- 发动代价：检查并取除这张卡的1个超量素材（作为发动COST）。
function c33779875.rlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 弹出选择提示，让玩家选择要取除的超量素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 目标选择：选择自己或对方场上1只可被效果解放的怪兽为对象，并设置解放的操作信息。
function c33779875.rltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsReleasableByEffect() end
	-- 发动合法性检查：自己或对方场上是否存在至少1只可被效果解放的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，让玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择1只可被效果解放的怪兽并登记为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置后续处理将进行的解放操作信息，用于连锁检测和效果发动判定。
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
end
-- 效果处理：将选择的对象怪兽解放。
function c33779875.rlop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽解放。
		Duel.Release(tc,REASON_EFFECT)
	end
end
-- 过滤函数：判断被解放的怪兽是否计入②效果的数量——被解放的卡属于怪兽且此前不在魔陷区，或此前位于主要怪兽区（即从场上怪兽区解放）。
function c33779875.atkfilter(c)
	return (c:IsType(TYPE_MONSTER) and not c:IsPreviousLocation(LOCATION_SZONE)) or c:IsPreviousLocation(LOCATION_MZONE)
end
-- ②效果发动条件：本连锁中有符合条件的怪兽被解放，且解放怪兽中不包含这张卡自身。
function c33779875.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33779875.atkfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 效果处理：统计符合条件的被解放怪兽数量，使这张卡的攻击力直到回合结束时上升对应数量×200。
function c33779875.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=eg:FilterCount(c33779875.atkfilter,nil)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升解放的怪兽数量×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
