--ガスタの神官 ムスト
-- 效果：
-- 可以选择自己墓地存在的1只名字带有「薰风」的怪兽回到卡组，选择场上表侧表示存在的1只怪兽把那个效果直到结束阶段时无效。这个效果1回合只能发动1次。
function c9837195.initial_effect(c)
	-- 可以选择自己墓地存在的1只名字带有「薰风」的怪兽回到卡组，选择场上表侧表示存在的1只怪兽把那个效果直到结束阶段时无效。这个效果1回合只能发动1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9837195,0))  --"效果无效化"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c9837195.target)
	e1:SetOperation(c9837195.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中名字带有「薰风」且可以回到卡组的怪兽卡
function c9837195.filter1(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤场上表侧表示的效果怪兽
function c9837195.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 效果发动时的对象合法性检测与选择
function c9837195.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己墓地是否存在至少1只可以回到卡组的「薰风」怪兽
	if chk==0 then return Duel.IsExistingTarget(c9837195.filter1,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查场上是否存在至少1只表侧表示的效果怪兽
		and Duel.IsExistingTarget(c9837195.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只「薰风」怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c9837195.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的效果怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c9837195.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	-- 设置当前连锁的操作信息为：使选中的怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g2,1,0,0)
end
-- 效果处理，将选中的墓地怪兽送回卡组，并使选中的场上怪兽效果直到结束阶段时无效
function c9837195.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中关于“返回卡组”的操作信息和对应的卡片组
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	-- 获取当前连锁中关于“效果无效”的操作信息和对应的卡片组
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_DISABLE)
	if g1:GetFirst():IsRelateToEffect(e) then
		-- 将选中的墓地怪兽送回卡组并洗牌
		Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	local tc=g2:GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 把那个效果直到结束阶段时无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 把那个效果直到结束阶段时无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
