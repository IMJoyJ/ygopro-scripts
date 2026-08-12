--フリントロック
-- 效果：
-- 场上有表侧表示的「打火石」存在的场合，可以给这张卡装备。这个效果1回合只能使用1次。此外，可以把这张卡装备的1张「打火石」给场上存在的1只表侧表示怪兽装备。这张卡可以装备的「打火石」最多1张。只要这张卡有「打火石」装备，这张卡不受「打火石」的效果影响，并且不会被战斗破坏。
function c83812099.initial_effect(c)
	-- 场上有表侧表示的「打火石」存在的场合，可以给这张卡装备。这个效果1回合只能使用1次。这张卡可以装备的「打火石」最多1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83812099,0))  --"装备给这张卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c83812099.eqcon1)
	e1:SetTarget(c83812099.eqtg1)
	e1:SetOperation(c83812099.eqop1)
	c:RegisterEffect(e1)
	-- 此外，可以把这张卡装备的1张「打火石」给场上存在的1只表侧表示怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83812099,1))  --"装备转移"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c83812099.eqcon2)
	e2:SetTarget(c83812099.eqtg2)
	e2:SetOperation(c83812099.eqop2)
	c:RegisterEffect(e2)
	-- 只要这张卡有「打火石」装备，并且不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(c83812099.eqcon2)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 检查自身是否未装备「打火石」，用于限制最多只能装备1张「打火石」
function c83812099.eqcon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetEquipGroup():IsExists(Card.IsCode,1,nil,75560629)
end
-- 过滤函数：场上表侧表示、卡名为「打火石」且可以装备给当前怪兽的卡
function c83812099.filter1(c,ec)
	return c:IsFaceup() and c:IsCode(75560629) and c:CheckEquipTarget(ec)
end
-- 效果1的Target函数：检查场上是否存在可装备的「打火石」
function c83812099.eqtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查双方魔陷区是否存在至少1张可装备的「打火石」
	if chk==0 then return Duel.IsExistingMatchingCard(c83812099.filter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e:GetHandler()) end
end
-- 效果1的Operation函数：将场上1张表侧表示的「打火石」装备给这张卡
function c83812099.eqop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 向玩家发送提示信息，要求选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方魔陷区选择1张满足条件的「打火石」
	local g=Duel.SelectMatchingCard(tp,c83812099.filter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,c)
	local eqc=g:GetFirst()
	if eqc then
		-- 执行装备操作，将选中的「打火石」装备给这张卡
		Duel.Equip(tp,eqc,c)
	end
end
-- 检查自身是否装备了「打火石」，作为效果2的发动条件或效果3的适用条件
function c83812099.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsCode,1,nil,75560629)
end
-- 过滤函数：场上表侧表示且可以被指定「打火石」装备的怪兽
function c83812099.filter2(c,eqc)
	return c:IsFaceup() and eqc:CheckEquipTarget(c)
end
-- 效果2的Target函数：选择场上1只表侧表示怪兽作为转移装备的对象
function c83812099.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local eqc=e:GetHandler():GetEquipGroup():Filter(Card.IsCode,nil,75560629):GetFirst()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c83812099.filter2(chkc,eqc) end
	-- 在发动准备阶段，检查场上是否存在可作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c83812099.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),eqc) end
	-- 向玩家发送提示信息，要求选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,c83812099.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),eqc)
end
-- 效果2的Operation函数：将自身装备的「打火石」转移装备给目标怪兽
function c83812099.eqop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为装备对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	local eqc=e:GetHandler():GetEquipGroup():Filter(Card.IsCode,nil,75560629):GetFirst()
	if eqc then
		-- 执行装备操作，将「打火石」装备给目标怪兽
		Duel.Equip(tp,eqc,tc)
	end
end
