--ウィンドファーム・ジェネクス
-- 效果：
-- 「次世代控制员」＋调整以外的风属性怪兽1只以上
-- ①：这张卡的攻击力上升场上的里侧表示的魔法·陷阱卡数量×300。
-- ②：把1张手卡送去墓地，以场上1张里侧表示的魔法·陷阱卡为对象才能发动。那张里侧表示卡破坏。
function c43925870.initial_effect(c)
	-- 为这张卡声明同调素材卡名列表，将卡号68505803（次世代控制员）加入关联列表，以便同调召唤时正确判定素材。
	aux.AddMaterialCodeList(c,68505803)
	-- 为这张卡添加同调召唤手续：同调素材为1只以上调整，其中调整必须是卡号68505803（次世代控制员），调整以外必须是风属性怪兽。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,68505803),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WIND),1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升场上的里侧表示的魔法·陷阱卡数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c43925870.val)
	c:RegisterEffect(e1)
	-- ②：把1张手卡送去墓地，以场上1张里侧表示的魔法·陷阱卡为对象才能发动。那张里侧表示卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43925870,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c43925870.descost)
	e2:SetTarget(c43925870.destg)
	e2:SetOperation(c43925870.desop)
	c:RegisterEffect(e2)
end
-- 定义①效果的攻击力变化值计算函数，根据场上里侧表示的魔法·陷阱卡数量决定上升数值。
function c43925870.val(e,c)
	-- 统计双方魔陷区所有里侧表示的魔法·陷阱卡数量，并乘以300作为攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsFacedown,0,LOCATION_SZONE,LOCATION_SZONE,nil)*300
end
-- 定义②效果的发动代价函数：从手牌选择1张卡送去墓地作为发动代价。
function c43925870.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在能够作为代价送去墓地的卡片，存在才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出提示，让玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手牌选择1张卡并送去墓地，作为发动代价。
	Duel.SendtoGrave(Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil),REASON_COST)
end
-- 定义取对象的筛选函数：对象必须是里侧表示的卡。
function c43925870.filter(c)
	return c:IsFacedown()
end
-- 定义②效果的发动目标选择函数：选择场上1张里侧表示的魔法·陷阱卡为对象，并设置破坏信息。
function c43925870.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c43925870.filter(chkc) end
	-- 检查场上是否存在里侧表示的魔法·陷阱卡可以作为效果对象，存在才可发动。
	if chk==0 then return Duel.IsExistingTarget(c43925870.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 弹出提示，让玩家选择要破坏的里侧表示的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张里侧表示的魔法·陷阱卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c43925870.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置操作信息，声明此效果将破坏对象g，破坏数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义②效果处理函数：效果处理时获取对象并将其破坏。
function c43925870.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将仍为里侧表示且与效果相关的对象卡破坏，破坏原因为效果。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
