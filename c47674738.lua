--魔救の奇跡－レオナイト
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张「魔救」卡加入手卡。剩下的卡用喜欢的顺序回到卡组最下面。
-- ②：对方回合，自己墓地有炎属性怪兽存在的场合，以自己墓地1只岩石族怪兽为对象才能发动。那只怪兽特殊召唤。
function c47674738.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整1只＋调整以外的怪兽1只以上，且必须满足苏生限制。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张「魔救」卡加入手卡。剩下的卡用喜欢的顺序回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47674738,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,47674738)
	e1:SetTarget(c47674738.thtg)
	e1:SetOperation(c47674738.thop)
	c:RegisterEffect(e1)
	-- ②：对方回合，自己墓地有炎属性怪兽存在的场合，以自己墓地1只岩石族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47674738,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,47674739)
	e2:SetCondition(c47674738.spcon)
	e2:SetTarget(c47674738.sptg)
	e2:SetOperation(c47674738.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定函数：仅在己方卡组数量大于4时才允许发动，确保能翻开5张卡。
function c47674738.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 非连锁处理时的检查：若己方卡组不足5张则不能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 翻开卡中可加入手卡的过滤条件：必须具有「魔救」字段，并且能够加入手卡。
function c47674738.thfilter(c)
	return c:IsSetCard(0x140) and c:IsAbleToHand()
end
-- ①效果处理：翻开卡组顶5张，若其中有「魔救」卡则由玩家选择1张加入手卡，剩余卡按玩家选择的顺序放回卡组最下面。
function c47674738.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认卡组数量，若不足5张则直接终止处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=4 then return end
	-- 向己方玩家确认卡组最上方5张卡。
	Duel.ConfirmDecktop(tp,5)
	-- 获取卡组最上方的5张卡作为一个卡组对象，用于后续筛选和操作。
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 若翻开卡中存在可加入手卡的「魔救」卡，则询问玩家是否选择其中1张加入手卡；否则跳过加入手卡部分。
	if ct>0 and g:FilterCount(c47674738.thfilter,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(47674738,2)) then  --"是否选卡加入手卡？"
		-- 禁用接下来将卡片加入手卡后的自动洗切卡组检测，因为剩余卡要放回卡组底部，无需洗切。
		Duel.DisableShuffleCheck()
		-- 显示选择提示，让玩家在符合条件的卡片中选择1张（提示文本为“请选择要加入手牌的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:FilterSelect(tp,c47674738.thfilter,1,1,nil)
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认被加入手卡的卡，使对方得知该卡片信息。
		Duel.ConfirmCards(1-tp,sg)
		-- 手动洗切己方手卡，以重置手卡顺序并取消洗卡检测状态。
		Duel.ShuffleHand(tp)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 对剩余的翻开卡按玩家指定的顺序排回卡组最上方（先选的在上），以便下一步依次放回底部。
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 每次从卡组最上方取1张卡，准备将其移动到卡组底部。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最下面，从而实现按先前顺序将所有剩余卡放回卡组底部。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- ②效果的发动条件函数：仅当当前回合是对方回合，且己方墓地存在炎属性怪兽时，该效果才允许发动。
function c47674738.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件判定：当前回合玩家是对方（Duel.GetTurnPlayer()==1-tp）且己方墓地存在至少1只炎属性怪兽。
	return Duel.GetTurnPlayer()==1-tp and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_FIRE)
end
-- 特殊召唤对象过滤条件：必须是岩石族怪兽，且能够被此次效果特殊召唤。
function c47674738.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标选择与操作信息设定：选择己方墓地1只岩石族怪兽作为对象，并登记特殊召唤操作信息。
function c47674738.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47674738.spfilter(chkc,e,tp) end
	-- 发动合法性检查：己方主要怪兽区有空位，且墓地存在1只可被特殊召唤的岩石族怪兽作为对象。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c47674738.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示特殊召唤对象选择提示（“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从己方墓地选择1只符合条件的岩石族怪兽作为效果对象，并同时登记为连锁对象。
	local g=Duel.SelectTarget(tp,c47674738.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本连锁的操作信息，宣告将进行1只怪兽的特殊召唤，供相关卡牌效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的实际处理：取得对象怪兽，若仍与效果相关则将其表侧表示特殊召唤到己方场上。
function c47674738.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁中记录的对象卡，即玩家选择的那只墓地岩石族怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上（不视为同调召唤，不检查苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
