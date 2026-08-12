--械貶する肆世壊
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己的场上·墓地1张「肆世坏-恐惧世界」为对象才能发动。那张卡回到持有者手卡。自己场上有「维萨斯-斯塔弗罗斯特」存在的场合，可以再选对方场上1只表侧表示怪兽变成里侧守备表示。
-- ②：场上有守备表示怪兽3只以上存在的场合，把墓地的这张卡除外才能发动。从自己墓地选1张「恐吓爪牙族」卡加入手卡。
function c32152870.initial_effect(c)
	-- 注册此卡的额外卡名，包括「肆世坏-恐惧世界」和「维萨斯-斯塔弗罗斯特」
	aux.AddCodeList(c,56099748,56063182)
	-- ①：以自己的场上·墓地1张「肆世坏-恐惧世界」为对象才能发动。那张卡回到持有者手卡。自己场上有「维萨斯-斯塔弗罗斯特」存在的场合，可以再选对方场上1只表侧表示怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32152870,0))  --"回收场地"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32152870.target)
	e1:SetOperation(c32152870.activate)
	c:RegisterEffect(e1)
	-- ②：场上有守备表示怪兽3只以上存在的场合，把墓地的这张卡除外才能发动。从自己墓地选1张「恐吓爪牙族」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32152870,1))  --"回收「恐吓爪牙族」卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,32152870)
	e2:SetCondition(c32152870.thcon)
	-- 支付将此卡除外的费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c32152870.thtg)
	e2:SetOperation(c32152870.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于选择「肆世坏-恐惧世界」卡，要求卡在场上或墓地且能回到手牌
function c32152870.filter(c)
	return c:IsCode(56063182) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToHand()
end
-- 设置目标选择的过滤条件，目标必须是自己场上的或墓地的「肆世坏-恐惧世界」卡
function c32152870.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(tp)
		and c32152870.filter(chkc) end
	-- 检查是否满足选择目标的条件，即自己场上或墓地存在「肆世坏-恐惧世界」卡
	if chk==0 then return Duel.IsExistingTarget(c32152870.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的「肆世坏-恐惧世界」卡作为目标
	local g=Duel.SelectTarget(tp,c32152870.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示将目标卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤函数，用于检测自己场上是否存在「维萨斯-斯塔弗罗斯特」
function c32152870.actcfilter(c,tp)
	return c:IsFaceup() and c:IsCode(56099748)
end
-- 过滤函数，用于检测对方场上是否存在可变为里侧守备表示的怪兽
function c32152870.actfilter(c,tp)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 处理效果的主函数，将目标卡返回手牌，并在满足条件时选择对方怪兽变为里侧守备表示
function c32152870.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效，是否成功返回手牌且在手牌位置
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND)
		-- 检查自己场上是否存在「维萨斯-斯塔弗罗斯特」
		and Duel.IsExistingMatchingCard(c32152870.actcfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在可变为里侧守备表示的怪兽
		and Duel.IsExistingMatchingCard(c32152870.actfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否选择对方怪兽变为里侧守备表示
		and Duel.SelectYesNo(tp,aux.Stringid(32152870,2)) then  --"是否选对方怪兽变成里侧表示？"
		-- 提示玩家选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择对方场上可变为里侧守备表示的怪兽
		local g=Duel.SelectMatchingCard(tp,c32152870.actfilter,tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			-- 中断当前效果，使后续效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的怪兽变为里侧守备表示
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 判断场上有3只以上守备表示怪兽的条件
function c32152870.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在3只以上守备表示怪兽
	return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,3,nil)
end
-- 过滤函数，用于选择墓地中的「恐吓爪牙族」卡
function c32152870.thfilter(c)
	return c:IsSetCard(0x17a) and c:IsAbleToHand()
end
-- 设置效果的处理目标，从墓地选择一张「恐吓爪牙族」卡加入手牌
function c32152870.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足选择墓地「恐吓爪牙族」卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c32152870.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置操作信息，表示将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 处理效果的主函数，从墓地选择一张「恐吓爪牙族」卡加入手牌
function c32152870.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「恐吓爪牙族」卡
	local g=Duel.SelectMatchingCard(tp,c32152870.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
