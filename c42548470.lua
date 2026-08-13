--揺れる発条秤
-- 效果：
-- 选择自己场上表侧表示存在的2只等级不同的名字带有「发条」的怪兽发动。对方选那之内1只，另1只怪兽的等级直到结束阶段时变成和对方选的怪兽相同。对方选等级低的怪兽的场合，那之后自己可以从卡组抽1张卡。
function c42548470.initial_effect(c)
	-- 选择自己场上表侧表示存在的2只等级不同的名字带有「发条」的怪兽发动。对方选那之内1只，另1只怪兽的等级直到结束阶段时变成和对方选的怪兽相同。对方选等级低的怪兽的场合，那之后自己可以从卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42548470.target)
	e1:SetOperation(c42548470.activate)
	c:RegisterEffect(e1)
end
-- 筛选第一只对象候选：自己场上表侧表示、名字带有「发条」、等级不为0，且场上还存在另一只等级不同的表侧「发条」怪兽可作为第二只对象。
function c42548470.filter1(c,tp)
	local lv1=c:GetLevel()
	-- 返回该卡的筛选结果：需要表侧表示、属于「发条」、等级不为0，并且场上存在另一只满足filter2条件（表侧「发条」且等级不同）的怪兽。
	return c:IsFaceup() and c:IsSetCard(0x58) and lv1~=0 and Duel.IsExistingTarget(c42548470.filter2,tp,LOCATION_MZONE,0,1,c,lv1)
end
-- 筛选第二只对象候选：表侧表示、属于「发条」、等级在1以上，且等级与第一只已选怪兽不同。
function c42548470.filter2(c,lv)
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- c42548470.target：效果发动时的目标选择与合法性判定。若满足发动条件，先选择第一只表侧「发条」怪兽，再选择另一只等级不同的表侧「发条」怪兽，并将两者登记为效果对象。
function c42548470.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：自己场上是否存在至少1组符合条件的两只等级不同的表侧「发条」怪兽（其中第一只由filter1判定，且存在对应的第二只）；没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c42548470.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 弹出选择提示框，要求己方玩家从表侧表示的怪兽中选择一张卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让己方玩家选择第一只表侧「发条」怪兽作为效果对象，并自动将其登记为该连锁的对象卡。
	local g1=Duel.SelectTarget(tp,c42548470.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	-- 弹出选择提示框，要求己方玩家从表侧表示的怪兽中选择一张卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让己方玩家选择第二只表侧「发条」怪兽作为效果对象，排除已选的第一只且要求与其等级不同，并自动登记为连锁对象。
	local g2=Duel.SelectTarget(tp,c42548470.filter2,tp,LOCATION_MZONE,0,1,1,tc1,tc1:GetLevel())
end
-- 效果处理：获取两只对象怪兽；若二者仍表侧且与效果关联，则对方选择其中1只，将另1只的等级直到结束阶段变为对方所选的怪兽的等级；若对方选择了等级较低的那只，则己方可以抽1张卡。
function c42548470.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的效果对象卡组，其中包含之前选择的两只「发条」怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	local lv1=tc1:GetLevel()
	local lv2=tc2:GetLevel()
	if tc1:IsFaceup() and tc1:IsRelateToEffect(e) and tc2:IsFaceup() and tc2:IsRelateToEffect(e) then
		-- 弹出选择提示框，要求对方玩家从两只对象怪兽中选择1只（决定哪只保留等级、哪只需变更等级）。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TARGET)  --"请选择效果的对象"
		local sg=g:Select(1-tp,1,1,nil)
		if lv1==lv2 then return end
		if sg:GetFirst()==tc1 then
			-- 为未被对方选择的另一只怪兽（tc2）赋予等级变更效果：其等级直到结束阶段变为与对方所选怪兽（tc1）的当前等级相同。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e1)
			-- 若对方所选的是等级较低的tc1（lv1<lv2），且己方当前可以抽卡，则询问己方是否抽卡；同意后从卡组抽1张卡。
			if lv1<lv2 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(42548470,0)) then Duel.Draw(tp,1,REASON_EFFECT) end  --"是否抽卡？"
		else
			-- 为未被对方选择的另一只怪兽（tc1）赋予等级变更效果：其等级直到结束阶段变为与对方所选怪兽（tc2）的当前等级相同。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc1:RegisterEffect(e1)
			-- 若对方所选的是等级较低的tc2（lv2<lv1），且己方当前可以抽卡，则询问己方是否抽卡；同意后从卡组抽1张卡。
			if lv2<lv1 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(42548470,0)) then Duel.Draw(tp,1,REASON_EFFECT) end  --"是否抽卡？"
		end
	end
end
