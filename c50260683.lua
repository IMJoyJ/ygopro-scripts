--No.36 先史遺産－超機関フォーク＝ヒューク
-- 效果：
-- 4星「先史遗产」怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成0。这个效果在对方回合也能发动。
-- ②：把自己场上1只「先史遗产」怪兽解放，以持有和原本攻击力不同攻击力的对方场上1只怪兽为对象才能发动。那只持有和原本攻击力不同攻击力的对方怪兽破坏。
function c50260683.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，要求满足条件的怪兽等级为4且数量为2
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
	-- 设置效果发动条件为伤害步骤前，防止在伤害计算后发动
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
-- 设置该卡的XYZ编号为36
aux.xyz_number[50260683]=36
-- 支付效果代价：从自己场上把1张超量素材取除
function c50260683.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于筛选满足条件的怪兽（表侧表示且攻击力大于0）
function c50260683.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 设置效果目标选择函数，选择对方场上的表侧表示怪兽作为目标
function c50260683.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c50260683.filter(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c50260683.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c50260683.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 设置效果处理函数，将目标怪兽攻击力变为0
function c50260683.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()>0 then
		-- 将目标怪兽的攻击力设置为0，直到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 支付效果代价：解放场上1只「先史遗产」怪兽
function c50260683.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件（场上存在1只「先史遗产」怪兽）
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x70) end
	-- 选择满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x70)
	-- 将选中的怪兽从场上解放
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，用于筛选满足条件的怪兽（表侧表示且攻击力与原本不同）
function c50260683.filter2(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
-- 设置效果目标选择函数，选择对方场上的攻击力与原本不同的怪兽作为目标
function c50260683.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c50260683.filter2(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c50260683.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c50260683.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，记录将要破坏的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 设置效果处理函数，破坏目标怪兽
function c50260683.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c50260683.filter2(tc) and tc:IsControler(1-tp) then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
