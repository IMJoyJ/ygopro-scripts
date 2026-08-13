--械貶する肆世壊
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己的场上·墓地1张「肆世坏-恐惧世界」为对象才能发动。那张卡回到持有者手卡。自己场上有「维萨斯-斯塔弗罗斯特」存在的场合，可以再选对方场上1只表侧表示怪兽变成里侧守备表示。
-- ②：场上有守备表示怪兽3只以上存在的场合，把墓地的这张卡除外才能发动。从自己墓地选1张「恐吓爪牙族」卡加入手卡。
function c32152870.initial_effect(c)
	-- 将本卡记载的「维萨斯-斯塔弗罗斯特」（56099748）和「肆世坏-恐惧世界」（56063182）加入代码列表，供相关字段检索联动使用。
	aux.AddCodeList(c,56099748,56063182)
	-- 对应①效果：以自己的场上·墓地1张「肆世坏-恐惧世界」为对象才能发动。那张卡回到持有者手卡。自己场上有「维萨斯-斯塔弗罗斯特」存在的场合，可以再选对方场上1只表侧表示怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32152870,0))  --"回收场地"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32152870.target)
	e1:SetOperation(c32152870.activate)
	c:RegisterEffect(e1)
	-- 对应②效果：场上有守备表示怪兽3只以上存在的场合，把墓地的这张卡除外才能发动。从自己墓地选1张「恐吓爪牙族」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32152870,1))  --"回收「恐吓爪牙族」卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,32152870)
	e2:SetCondition(c32152870.thcon)
	-- 设置②效果的发动COST：将墓地中的这张卡除外（aux.bfgcost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c32152870.thtg)
	e2:SetOperation(c32152870.thop)
	c:RegisterEffect(e2)
end
-- 定义①效果的取对象筛选条件：对象必须是「肆世坏-恐惧世界」，且处于表侧表示或墓地，并且能被加入手卡。
function c32152870.filter(c)
	return c:IsCode(56063182) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToHand()
end
-- 处理连锁中对象确认：校验所选择的对象是否位于自己场上·墓地、由自己控制且满足c32152870.filter。
function c32152870.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(tp)
		and c32152870.filter(chkc) end
	-- 发动合法性检查：确认自己场上·墓地存在至少1张符合条件的「肆世坏-恐惧世界」可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c32152870.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	-- 显示“请选择要返回手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家从自己场上·墓地选择1张「肆世坏-恐惧世界」作为效果对象，并设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c32152870.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的操作信息：确定将该对象卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义“维萨斯-斯塔弗罗斯特”在场判断条件：自己场上有表侧表示的「维萨斯-斯塔弗罗斯特」。
function c32152870.actcfilter(c,tp)
	return c:IsFaceup() and c:IsCode(56099748)
end
-- 定义可被变里侧的怪兽条件：对方场上的表侧表示怪兽，且能够变为里侧守备表示。
function c32152870.actfilter(c,tp)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 处理①效果：将取对象送回持有者手卡；若送回成功、自己场上有维萨斯、对方场上有可变的表侧怪兽且玩家选择是，则选对方1只表侧怪兽变为里侧守备表示。
function c32152870.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取回①效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联，将其送回持有者手卡，并确认送入操作成功且对象已位于手卡。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND)
		-- 检查自己场上是否存在表侧表示的「维萨斯-斯塔弗罗斯特」。
		and Duel.IsExistingMatchingCard(c32152870.actcfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在表侧表示且可以变为里侧守备表示的怪兽。
		and Duel.IsExistingMatchingCard(c32152870.actfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否发动追加效果：将对方场上1只表侧表示怪兽变成里侧守备表示。
		and Duel.SelectYesNo(tp,aux.Stringid(32152870,2)) then  --"是否选对方怪兽变成里侧表示？"
		-- 显示“请选择要改变表示形式的怪兽”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择对方场上1只满足条件（表侧表示且可变里侧）的怪兽。
		local g=Duel.SelectMatchingCard(tp,c32152870.actfilter,tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			-- 中断当前效果处理，使后续的变里侧处理被视作独立处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的怪兽变为里侧守备表示。
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 定义②效果的发动条件：场上存在3只以上守备表示怪兽。
function c32152870.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方主要怪兽区合计是否存在至少3只守备表示怪兽。
	return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,3,nil)
end
-- 定义可回收的「恐吓爪牙族」卡条件：是字段0x17a的卡片，且能够加入手卡。
function c32152870.thfilter(c)
	return c:IsSetCard(0x17a) and c:IsAbleToHand()
end
-- ②效果发动前检查墓地是否存在可加入手卡的「恐吓爪牙族」卡，并设置操作信息为将墓地卡加入手卡。
function c32152870.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性的发动检查：确认墓地存在至少1张符合条件的「恐吓爪牙族」卡（注意排除要被除外的本卡自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(c32152870.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置操作信息：本次效果处理将把1张墓地中的卡加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 处理②效果：从自己墓地选择1张「恐吓爪牙族」卡加入手卡。
function c32152870.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1张符合条件的「恐吓爪牙族」卡。
	local g=Duel.SelectMatchingCard(tp,c32152870.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「恐吓爪牙族」卡送去持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
