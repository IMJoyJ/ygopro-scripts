--No.85 クレイジー・ボックス
-- 效果：
-- 4星怪兽×2
-- ①：这张卡不能攻击。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。掷1次骰子，出现的数目的以下效果适用。
-- ●1：自己基本分变成一半。
-- ●2：自己从卡组抽1张。
-- ●3：对方选1张手卡丢弃。
-- ●4：选场上1张表侧表示的卡，那个效果直到回合结束时无效。
-- ●5：选场上1张卡破坏。
-- ●6：这张卡破坏。
function c42421606.initial_effect(c)
	-- 为卡片添加等级为4、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。掷1次骰子，出现的数目的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42421606,0))  --"投掷骰子"
	e2:SetCategory(CATEGORY_DICE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c42421606.efcost)
	e2:SetTarget(c42421606.eftg)
	e2:SetOperation(c42421606.efop)
	c:RegisterEffect(e2)
end
-- 设置该卡的XYZ编号为85
aux.xyz_number[42421606]=85
-- 支付1个超量素材作为效果的发动费用
function c42421606.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置连锁处理信息，表示将要投掷骰子
function c42421606.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，表示将要投掷骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 处理效果的发动，根据骰子结果执行对应效果
function c42421606.efop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家投掷1次骰子并获取结果
	local dc=Duel.TossDice(tp,1)
	if dc==1 then
		-- 将玩家的基本分变为原来的一半
		Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
	elseif dc==2 then
		-- 让玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif dc==3 then
		-- 判断对方手牌数量是否大于0
		if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
			-- 让对方选择并丢弃1张手卡
			Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	elseif dc==4 then
		-- 提示玩家选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择场上1张表侧表示的卡作为目标
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显示被选为对象的卡
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			-- 使目标卡的效果在回合结束前无效
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使目标卡的效果在回合结束前无效
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	elseif dc==5 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上任意1张卡作为目标
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显示被选为对象的卡
			Duel.HintSelection(g)
			-- 破坏目标卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif dc==6 then
		if e:GetHandler():IsRelateToEffect(e) then
			-- 破坏自身
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
