--ペンドラザクション
-- 效果：
-- 4星怪兽×2
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。自己的额外卡组的数量比对方多的场合，那个相差数量的以下效果各适用。
-- ●1张以上：这张卡的攻击力直到对方回合结束时上升1000。
-- ●5张以上：这张卡直到对方回合结束时不会成为效果的对象。
-- ●10张以上：选对方场上1张卡除外。
-- ●15张以上：对方基本分变成3000。
function c58720904.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 这个卡名的效果1回合只能使用1次。①：把这张卡1个超量素材取除才能发动。自己的额外卡组的数量比对方多的场合，那个相差数量的以下效果各适用。●1张以上：这张卡的攻击力直到对方回合结束时上升1000。●5张以上：这张卡直到对方回合结束时不会成为效果的对象。●10张以上：选对方场上1张卡除外。●15张以上：对方基本分变成3000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58720904,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,58720904)
	e1:SetCost(c58720904.cost)
	e1:SetTarget(c58720904.target)
	e1:SetOperation(c58720904.operation)
	c:RegisterEffect(e1)
end
-- 检查并取除1个超量素材作为发动的代价
function c58720904.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动阶段的目标确认，若额外卡组差值达到10张以上则注册除外效果的操作信息
function c58720904.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己与对方额外卡组数量的差值
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	if chk==0 then return ct>0 end
	if ct>=10 then
		-- 设置除外对方场上1张卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
	end
end
-- 效果处理：根据额外卡组数量的差值，依次适用对应的效果
function c58720904.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算自己与对方额外卡组数量的差值
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	if ct>=1 and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- ●1张以上：这张卡的攻击力直到对方回合结束时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
	if ct>=5 and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 中断效果处理，使前后的效果处理不视为同时进行
		Duel.BreakEffect()
		-- ●5张以上：这张卡直到对方回合结束时不会成为效果的对象。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e2)
	end
	if ct>=10 then
		-- 向发动玩家发送选择除外卡的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择对方场上1张可以除外的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			-- 中断效果处理，使前后的效果处理不视为同时进行
			Duel.BreakEffect()
			-- 为选中的卡片显示被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将选中的卡片以表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
	if ct>=15 then
		-- 中断效果处理，使前后的效果处理不视为同时进行
		Duel.BreakEffect()
		-- 将对方玩家的生命值（LP）设置为3000
		Duel.SetLP(1-tp,3000)
	end
end
