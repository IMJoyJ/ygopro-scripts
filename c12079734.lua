--デルタトライ
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，从下面效果选择1个发动。
-- ●选择自己墓地存在的1只可以装备的同盟怪兽给这张卡装备。
-- ●选择自己场上表侧表示存在的1只机械族·光属性怪兽回到卡组，从自己卡组抽1张卡。
function c12079734.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，从下面效果选择1个发动。●选择自己墓地存在的1只可以装备的同盟怪兽给这张卡装备。●选择自己场上表侧表示存在的1只机械族·光属性怪兽回到卡组，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12079734,0))  --"选择效果"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动条件，要求本卡与对方怪兽战斗并把它破坏时才可发动。
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c12079734.target)
	e1:SetOperation(c12079734.operation)
	c:RegisterEffect(e1)
end
c12079734.has_text_type=TYPE_UNION
-- 定义选择墓地同盟怪兽的筛选函数：要求对象为同盟怪兽、能够装备到本卡且满足同盟装备条件。
function c12079734.filter1(c,ec)
	-- 筛选条件具体判定：对象是同盟怪兽、可以装备到本卡、且同盟装备合法。
	return c:IsType(TYPE_UNION) and c:CheckUnionTarget(ec) and aux.CheckUnionEquip(c,ec)
end
-- 定义选择场上机械族·光属性怪兽的筛选函数：要求表侧表示、机械族、光属性且能够返回卡组。
function c12079734.filter2(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
-- 效果目标处理函数：在发动时检查对象选择是否合法，并根据之前选择的选项决定对象应该是墓地同盟怪兽还是场上机械族·光属性怪兽。
function c12079734.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		if e:GetLabel()==0 then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12079734.filter1(chkc,c)
		else return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12079734.filter2(chkc) end
	end
	-- 判定己方魔陷区是否存在空位，以确保能够将同盟怪兽作为装备卡装备。
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查墓地是否存在至少1张可作为同盟装备给本卡的同盟怪兽，且可被选为对象。
		and Duel.IsExistingTarget(c12079734.filter1,tp,LOCATION_GRAVE,0,1,nil,c)
	-- 检查场上是否存在至少1张符合条件的机械族·光属性怪兽且自己能够抽1张卡，作为第二个选项的可行条件。
	local b2=Duel.IsExistingTarget(c12079734.filter2,tp,LOCATION_MZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个选项都可行时，弹出选择窗口让玩家选择要发动的效果（装备同盟怪兽或回卡组抽卡）。
		op=Duel.SelectOption(tp,aux.Stringid(12079734,1),aux.Stringid(12079734,2))  --"同盟怪兽给这张卡装备/回到卡组并抽卡"
	elseif b1 then
		-- 仅第一个选项可行时，弹出唯一选项并选择（装备同盟怪兽）。
		op=Duel.SelectOption(tp,aux.Stringid(12079734,1))  --"同盟怪兽给这张卡装备"
	-- 仅第二个选项可行时，弹出唯一选项并选择，通过加1将选项标识设为1（回卡组抽卡）。
	else op=Duel.SelectOption(tp,aux.Stringid(12079734,2))+1 end  --"回到卡组并抽卡"
	e:SetLabel(op)
	if op==0 then
		-- 发出选择提示，提示玩家选择要装备的同盟怪兽（用于后续 SelectTarget 的 UI 显示）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 让玩家从自己墓地选择1张满足 filter1 的同盟怪兽，并设定为当前效果的对象。
		local g=Duel.SelectTarget(tp,c12079734.filter1,tp,LOCATION_GRAVE,0,1,1,nil,c)
		e:SetCategory(0)
		-- 设置效果处理信息：本次处理包含“从墓地离开”类别，数量为1，用于回溯相关效果。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	else
		-- 发出选择提示，提示玩家选择要返回卡组的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从自己场上选择1张满足 filter2 的表侧表示机械族·光属性怪兽，并设定为当前效果的对象。
		local g=Duel.SelectTarget(tp,c12079734.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		-- 设置效果处理信息：本次处理包含“返回卡组”类别，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		-- 设置效果处理信息：本次处理包含“抽卡”类别，由 tp 抽1张。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 效果处理函数：根据发动时选择的选项执行对应处理（装备同盟怪兽或回卡组并抽卡）。
function c12079734.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前效果的对象卡（因为只选择1张，所以取首个目标）。
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e)
			-- 处理时再次确认己方魔陷区有空位，保证装备可能成功。
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 处理时再次确认同盟怪兽仍可装备给本卡，并执行装备操作（不改变表示形式）。成功装备后进入后续。
			and aux.CheckUnionEquip(tc,c) and Duel.Equip(tp,tc,c,false) then
			-- 将成功装备的同盟怪兽标记为同盟状态，使其作为装备卡时拥有同盟规则效果。
			aux.SetUnionState(tc)
		end
	else
		-- 检查对象仍与效果关联，将其返回持有者卡组（洗牌方式），并确认其现在位于卡组或额外卡组，若成功则继续抽卡。
		if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			-- 若返回后对象位于卡组中，则洗切己方卡组。
			if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
			-- 中断当前效果链的处理，使回卡组和抽卡成为不同时点，避免时点冲突。
			Duel.BreakEffect()
			-- 己方玩家因为效果抽1张牌。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
