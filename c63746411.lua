--No.106 巨岩掌ジャイアント・ハンド
-- 效果：
-- 4星怪兽×2
-- ①：对方场上的怪兽的效果发动时，把这张卡2个超量素材取除，以对方场上1只效果怪兽为对象才能发动。这只怪兽表侧表示存在期间，作为对象的效果怪兽的效果无效化，也不能作表示形式的变更。
function c63746411.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：对方场上的怪兽的效果发动时，把这张卡2个超量素材取除，以对方场上1只效果怪兽为对象才能发动。这只怪兽表侧表示存在期间，作为对象的效果怪兽的效果无效化，也不能作表示形式的变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63746411,0))  --"效果无效化"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c63746411.condition)
	e1:SetCost(c63746411.cost)
	e1:SetTarget(c63746411.target)
	e1:SetOperation(c63746411.operation)
	c:RegisterEffect(e1)
end
-- 设置该卡片的No.编号为106
aux.xyz_number[63746411]=106
-- 判定效果发动条件是否满足
function c63746411.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
		-- 判定发动效果的怪兽在场上（怪兽区域）
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
end
-- 扣除发动代价：把这张卡2个超量素材取除
function c63746411.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤条件：表侧表示的效果怪兽
function c63746411.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 选择对象并设置效果分类
function c63746411.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c63746411.filter(chkc) end
	-- 在chk==0时，判定对方场上是否存在符合条件的对象
	if chk==0 then return Duel.IsExistingTarget(c63746411.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c63746411.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为无效化该对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 执行效果处理：使对象怪兽效果无效且不能变更表示形式
function c63746411.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and tc:IsType(TYPE_EFFECT) and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 这只怪兽表侧表示存在期间，作为对象的效果怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c63746411.rcon)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		tc:RegisterEffect(e2)
	end
end
-- 判定持续条件：只要这张卡（巨岩掌）对目标怪兽的指向关系存在（即这张卡在场上表侧表示存在）
function c63746411.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
