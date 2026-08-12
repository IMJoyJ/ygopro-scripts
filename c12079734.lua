--デルタトライ
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，从下面效果选择1个发动。
-- ●选择自己墓地存在的1只可以装备的同盟怪兽给这张卡装备。
-- ●选择自己场上表侧表示存在的1只机械族·光属性怪兽回到卡组，从自己卡组抽1张卡。
function c12079734.initial_effect(c)
	-- 选择自己墓地存在的1只可以装备的同盟怪兽给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12079734,0))  --"选择效果"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测本次战斗是否为该卡与对方怪兽的战斗
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c12079734.target)
	e1:SetOperation(c12079734.operation)
	c:RegisterEffect(e1)
end
c12079734.has_text_type=TYPE_UNION
-- 判断目标是否为可以装备的同盟怪兽
function c12079734.filter1(c,ec)
	-- 检查同盟怪兽能否作为同盟装备在目标怪兽上
	return c:IsType(TYPE_UNION) and c:CheckUnionTarget(ec) and aux.CheckUnionEquip(c,ec)
end
-- 判断目标是否为场上的机械族·光属性怪兽
function c12079734.filter2(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
-- 处理效果选择和目标选择的函数
function c12079734.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		if e:GetLabel()==0 then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12079734.filter1(chkc,c)
		else return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12079734.filter2(chkc) end
	end
	-- 判断玩家场上是否有可用的装备区域
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断玩家墓地是否存在符合条件的同盟怪兽
		and Duel.IsExistingTarget(c12079734.filter1,tp,LOCATION_GRAVE,0,1,nil,c)
	-- 判断玩家是否可以抽卡
	local b2=Duel.IsExistingTarget(c12079734.filter2,tp,LOCATION_MZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 让玩家选择发动效果1（装备）
		op=Duel.SelectOption(tp,aux.Stringid(12079734,1),aux.Stringid(12079734,2))  --"同盟怪兽给这张卡装备" / "回到卡组并抽卡"
	elseif b1 then
		-- 让玩家选择发动效果1（装备）
		op=Duel.SelectOption(tp,aux.Stringid(12079734,1))  --"同盟怪兽给这张卡装备"
	-- 让玩家选择发动效果2（回到卡组并抽卡）
	else op=Duel.SelectOption(tp,aux.Stringid(12079734,2))+1 end  --"回到卡组并抽卡"
	e:SetLabel(op)
	if op==0 then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		-- 选择符合条件的同盟怪兽作为装备对象
		local g=Duel.SelectTarget(tp,c12079734.filter1,tp,LOCATION_GRAVE,0,1,1,nil,c)
		e:SetCategory(0)
		-- 设置操作信息为将卡送入墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	else
		-- 提示玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		-- 选择符合条件的机械族·光属性怪兽作为目标
		local g=Duel.SelectTarget(tp,c12079734.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		-- 设置操作信息为将卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		-- 设置操作信息为抽卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 处理效果发动后的操作
function c12079734.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e)
			-- 判断玩家场上是否有可用的装备区域
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 执行装备操作
			and aux.CheckUnionEquip(tc,c) and Duel.Equip(tp,tc,c,false) then
			-- 为装备卡添加同盟怪兽属性
			aux.SetUnionState(tc)
		end
	else
		-- 将目标怪兽送回卡组并判断是否成功
		if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			-- 若目标卡在卡组中则洗切卡组
			if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 让玩家抽一张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
