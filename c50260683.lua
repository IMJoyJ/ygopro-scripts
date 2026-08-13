--No.36 先史遺産－超機関フォーク＝ヒューク
-- 效果：
-- 4星「先史遗产」怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成0。这个效果在对方回合也能发动。
-- ②：把自己场上1只「先史遗产」怪兽解放，以持有和原本攻击力不同攻击力的对方场上1只怪兽为对象才能发动。那只持有和原本攻击力不同攻击力的对方怪兽破坏。
function c50260683.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以2只4星「先史遗产」怪兽作为超量素材叠放召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x70),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成0。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50260683,0))  --"攻击变成0"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果发动条件：伤害步骤的伤害计算中不能发动；作为诱发即时效果，在双方回合自由时点满足条件即可发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c50260683.cost)
	e1:SetTarget(c50260683.target)
	e1:SetOperation(c50260683.operation)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只「先史遗产」怪兽解放，以持有和原本攻击力不同攻击力的对方场上1只怪兽为对象才能发动。那只持有和原本攻击力不同攻击力的对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50260683,1))  --"怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c50260683.descost)
	e2:SetTarget(c50260683.destg)
	e2:SetOperation(c50260683.desop)
	c:RegisterEffect(e2)
end
-- 将该卡登记为No.36，用于No.卡相关判定与显示。
aux.xyz_number[50260683]=36
-- 效果①的发动代价：检查并执行从这张卡取除1个超量素材（COST）。
function c50260683.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的对象筛选条件：对方场上表侧表示且当前攻击力大于0的怪兽。
function c50260683.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 效果①的发动目标处理：选择对方场上1只表侧表示且攻击力大于0的怪兽作为效果对象。
function c50260683.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c50260683.filter(chkc) end
	-- 发动合法性检查（chk=0）：确认对方场上是否存在至少1只符合条件的怪兽可供选择为对象。
	if chk==0 then return Duel.IsExistingTarget(c50260683.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，要求玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只符合条件的怪兽，并设为该连锁的效果对象。
	Duel.SelectTarget(tp,c50260683.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①处理：将对象怪兽的攻击力变为0，直到回合结束。
function c50260683.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()>0 then
		-- 那只怪兽的攻击力直到回合结束时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动代价：检查并执行将自己场上1只「先史遗产」怪兽解放（COST）。
function c50260683.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk=0）：确认自己场上是否存在至少1只可解放的「先史遗产」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x70) end
	-- 选择1只自己场上的「先史遗产」怪兽准备解放。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x70)
	-- 将选择的怪兽解放，作为效果②的发动代价。
	Duel.Release(g,REASON_COST)
end
-- 效果②的对象筛选条件：对方场上表侧表示且当前攻击力与原本攻击力不同的怪兽。
function c50260683.filter2(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
-- 效果②的发动目标处理：选择对方场上1只表侧表示且当前攻击力与原本攻击力不同的怪兽作为对象，并登记破坏信息。
function c50260683.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c50260683.filter2(chkc) end
	-- 发动合法性检查（chk=0）：确认对方场上是否存在至少1只符合条件的怪兽可供选择为对象。
	if chk==0 then return Duel.IsExistingTarget(c50260683.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，要求玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1只符合条件的怪兽，并设为该连锁的效果对象。
	local g=Duel.SelectTarget(tp,c50260683.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	-- 向系统登记本次连锁将破坏的对象怪兽，供其他效果（如星尘龙）检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②处理：若对象怪兽仍在场上且仍满足条件，则将其破坏。
function c50260683.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c50260683.filter2(tc) and tc:IsControler(1-tp) then
		-- 以效果破坏该对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
