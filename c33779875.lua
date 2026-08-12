--六花聖ティアドロップ
-- 效果：
-- 8星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除，以自己·对方场上1只怪兽为对象才能发动。那只怪兽解放。这张卡有植物族怪兽在作为超量素材的场合，这个效果在对方回合也能发动。
-- ②：每次怪兽被解放发动。这张卡的攻击力直到回合结束时上升解放的怪兽数量×200。
function c33779875.initial_effect(c)
	-- 添加XYZ召唤手续，使用8星怪兽2只进行叠放
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以自己·对方场上1只怪兽为对象才能发动。那只怪兽解放。这张卡有植物族怪兽在作为超量素材的场合，这个效果在对方回合也能发动。
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
-- 效果条件：当此卡没有植物族超量素材时才能发动
function c33779875.rlcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():FilterCount(Card.IsRace,nil,RACE_PLANT)==0
end
-- 效果条件：当此卡有植物族超量素材时才能发动
function c33779875.rlcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():FilterCount(Card.IsRace,nil,RACE_PLANT)~=0
end
-- 效果费用：支付1个超量素材的取除作为代价
function c33779875.rlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 提示玩家选择要取除的超量素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果目标：选择1只可以被解放的怪兽作为对象
function c33779875.rltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsReleasableByEffect() end
	-- 判断是否存在可解放的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择1只可以被解放的怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，确定解放的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
end
-- 效果处理：将选定的怪兽进行解放
function c33779875.rlop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽进行解放
		Duel.Release(tc,REASON_EFFECT)
	end
end
-- 判断解放的怪兽是否为怪兽卡且不是从魔陷区离开
function c33779875.atkfilter(c)
	return (c:IsType(TYPE_MONSTER) and not c:IsPreviousLocation(LOCATION_SZONE)) or c:IsPreviousLocation(LOCATION_MZONE)
end
-- 触发条件：当有怪兽被解放时发动
function c33779875.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33779875.atkfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 效果处理：使此卡攻击力上升解放怪兽数量×200
function c33779875.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=eg:FilterCount(c33779875.atkfilter,nil)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使此卡攻击力上升解放怪兽数量×200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
