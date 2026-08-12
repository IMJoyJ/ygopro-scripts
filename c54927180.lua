--福悲喜
-- 效果：
-- ①：双方玩家把卡组洗切，卡组最上面的卡翻开并把那些卡的攻击力确认（攻击力?的怪兽或者魔法·陷阱卡的场合那个攻击力当作0使用）。攻击力较高方的卡加入那个玩家的手卡，攻击力较低方的卡送去墓地。攻击力相同的场合，那些卡回到卡组最下面。
function c54927180.initial_effect(c)
	-- ①：双方玩家把卡组洗切，卡组最上面的卡翻开并把那些卡的攻击力确认（攻击力?的怪兽或者魔法·陷阱卡的场合那个攻击力当作0使用）。攻击力较高方的卡加入那个玩家的手卡，攻击力较低方的卡送去墓地。攻击力相同的场合，那些卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c54927180.target)
	e1:SetOperation(c54927180.activate)
	c:RegisterEffect(e1)
end
-- 检查双方卡组是否都存在至少1张可以送去墓地的卡（作为效果发动的可行性检测）
function c54927180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组是否存在至少1张可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,nil)
		-- 检查对方卡组是否存在至少1张可以送去墓地的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_DECK,1,nil) end
end
-- 效果处理时，如果任意一方卡组中没有可以送去墓地的卡，则不进行处理
function c54927180.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果己方卡组中没有可以送去墓地的卡
	if not Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,nil)
		-- 或者对方卡组中没有可以送去墓地的卡，则结束效果处理
		or not Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_DECK,1,nil) then return end
	-- 洗切己方卡组
	Duel.ShuffleDeck(tp)
	-- 洗切对方卡组
	Duel.ShuffleDeck(1-tp)
	-- 确认己方卡组最上方的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 确认对方卡组最上方的一张卡
	Duel.ConfirmDecktop(1-tp,1)
	-- 获取己方卡组最上方的一张卡
	local tc1=Duel.GetDecktopGroup(tp,1):GetFirst()
	-- 获取对方卡组最上方的一张卡
	local tc2=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	if not tc1 or not tc2 then return end
	local atk1,atk2=0,0
	if not tc1:IsType(TYPE_SPELL+TYPE_TRAP) and tc1:GetTextAttack()>=0 then
		atk1=tc1:GetTextAttack()
	end
	if not tc2:IsType(TYPE_SPELL+TYPE_TRAP) and tc2:GetTextAttack()>=0 then
		atk2=tc2:GetTextAttack()
	end
	if atk1>atk2 then
		if not tc1:IsAbleToHand() then return end
		-- 使接下来的操作不触发系统自动洗卡检测（防止加入手卡时自动洗卡组）
		Duel.DisableShuffleCheck()
		-- 如果成功将己方卡组最上方的卡加入手卡
		if Duel.SendtoHand(tc1,nil,REASON_EFFECT)~=0 then
			-- 洗切己方手卡
			Duel.ShuffleHand(tp)
			-- 使接下来的操作不触发系统自动洗卡检测（防止送去墓地时自动洗卡组）
			Duel.DisableShuffleCheck()
			-- 将对方卡组最上方的卡送去墓地
			Duel.SendtoGrave(tc2,REASON_EFFECT)
		end
	elseif atk1<atk2 then
		if not tc2:IsAbleToHand() then return end
		-- 使接下来的操作不触发系统自动洗卡检测（防止加入手卡时自动洗卡组）
		Duel.DisableShuffleCheck()
		-- 如果成功将对方卡组最上方的卡加入手卡
		if Duel.SendtoHand(tc2,nil,REASON_EFFECT)~=0 then
			-- 洗切对方手卡
			Duel.ShuffleHand(1-tp)
			-- 使接下来的操作不触发系统自动洗卡检测（防止送去墓地时自动洗卡组）
			Duel.DisableShuffleCheck()
			-- 将己方卡组最上方的卡送去墓地
			Duel.SendtoGrave(tc1,REASON_EFFECT)
		end
	else
		-- 将己方卡组最上方的卡移动到卡组最下面
		Duel.MoveSequence(tc1,SEQ_DECKBOTTOM)
		-- 将对方卡组最上方的卡移动到卡组最下面
		Duel.MoveSequence(tc2,SEQ_DECKBOTTOM)
	end
end
