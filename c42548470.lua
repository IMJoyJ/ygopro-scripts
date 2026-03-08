--揺れる発条秤
-- 效果：
-- 选择自己场上表侧表示存在的2只等级不同的名字带有「发条」的怪兽发动。对方选那之内1只，另1只怪兽的等级直到结束阶段时变成和对方选的怪兽相同。对方选等级低的怪兽的场合，那之后自己可以从卡组抽1张卡。
function c42548470.initial_effect(c)
	-- 创建效果，设置为发动时点，选择对象，抽卡类别
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42548470.target)
	e1:SetOperation(c42548470.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：场上表侧表示的「发条」怪兽，且存在满足filter2条件的怪兽
function c42548470.filter1(c,tp)
	local lv1=c:GetLevel()
	-- 满足条件：表侧表示、名字带有「发条」、等级不为0、存在满足filter2条件的怪兽
	return c:IsFaceup() and c:IsSetCard(0x58) and lv1~=0 and Duel.IsExistingTarget(c42548470.filter2,tp,LOCATION_MZONE,0,1,c,lv1)
end
-- 筛选条件：场上表侧表示的「发条」怪兽，等级大于等于1，且等级与lv不同
function c42548470.filter2(c,lv)
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- 效果处理：选择满足filter1条件的怪兽，再选择满足filter2条件的怪兽
function c42548470.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否满足发动条件：场上存在满足filter1条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c42548470.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足filter1条件的怪兽
	local g1=Duel.SelectTarget(tp,c42548470.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足filter2条件的怪兽
	local g2=Duel.SelectTarget(tp,c42548470.filter2,tp,LOCATION_MZONE,0,1,1,tc1,tc1:GetLevel())
end
-- 效果发动处理：获取选择的怪兽，判断是否满足条件，选择对方选择的怪兽，改变另一只怪兽等级，若等级低的被选中则抽卡
function c42548470.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	local lv1=tc1:GetLevel()
	local lv2=tc2:GetLevel()
	if tc1:IsFaceup() and tc1:IsRelateToEffect(e) and tc2:IsFaceup() and tc2:IsRelateToEffect(e) then
		-- 提示对方选择效果的对象
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TARGET)  --"请选择效果的对象"
		local sg=g:Select(1-tp,1,1,nil)
		if lv1==lv2 then return end
		if sg:GetFirst()==tc1 then
			-- 创建等级改变效果，使tc2等级变为lv1，直到结束阶段重置
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e1)
			-- 若lv1小于lv2且可以抽卡，则询问是否抽卡
			if lv1<lv2 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(42548470,0)) then Duel.Draw(tp,1,REASON_EFFECT) end  --"是否抽卡？"
		else
			-- 创建等级改变效果，使tc1等级变为lv2，直到结束阶段重置
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc1:RegisterEffect(e1)
			-- 若lv2小于lv1且可以抽卡，则询问是否抽卡
			if lv2<lv1 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(42548470,0)) then Duel.Draw(tp,1,REASON_EFFECT) end  --"是否抽卡？"
		end
	end
end
