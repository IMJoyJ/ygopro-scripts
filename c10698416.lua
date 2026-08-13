--クローラー・ランヴィエ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡反转的场合，以自己墓地最多2只「机怪虫」怪兽为对象才能发动。那些怪兽加入手卡。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·郎飞结虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
function c10698416.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡反转的场合，以自己墓地最多2只「机怪虫」怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10698416,0))  --"墓地回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,10698416)
	e1:SetTarget(c10698416.target)
	e1:SetOperation(c10698416.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·郎飞结虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10698416,1))  --"2只怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,10698417)
	e2:SetCondition(c10698416.spcon)
	e2:SetTarget(c10698416.sptg)
	e2:SetOperation(c10698416.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果的对象筛选条件：墓地里满足是「机怪虫」怪兽、且能加入手卡的怪兽卡。
function c10698416.filter(c)
	return c:IsSetCard(0x104) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动目标处理：选择自己墓地1~2只符合条件的「机怪虫」怪兽作为对象，并设置回手牌的操作信息。
function c10698416.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10698416.filter(chkc) end
	-- 检查是否存在至少1只符合条件的「机怪虫」怪兽可以作为对象，以此判断效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(c10698416.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，让玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1~2只符合条件的「机怪虫」怪兽，并将它们登记为效果的对象。
	local g=Duel.SelectTarget(tp,c10698416.filter,tp,LOCATION_GRAVE,0,1,2,nil)
	-- 向系统登记本次连锁的处理内容：将对象怪兽加入持有者的手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理时执行的操作：将效果对象中仍关联的怪兽加入手卡。
function c10698416.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁记录的对象卡，并过滤掉已经无法被该效果处理的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将过滤后剩余的怪兽卡加入其持有者的手卡（原因记为效果）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡在离场前是表侧表示且由自己控制，因对方发动的效果而从场上离开。
function c10698416.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 定义②效果从卡组特殊召唤的候选卡条件：是「机怪虫」怪兽、卡名不是「机怪虫·郎飞结虫」、且可以里侧守备表示特殊召唤。
function c10698416.filter1(c,e,tp)
	return c:IsSetCard(0x104) and not c:IsCode(10698416) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ②效果的发动目标判定：确认没有“禁止同时特殊召唤2只以上怪兽”的效果影响、自己场上至少有2个空位，并且卡组存在至少2种不同卡名的符合条件的「机怪虫」怪兽。
function c10698416.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 检查自己主要怪兽区是否有至少2个空位，用于特殊召唤2只怪兽。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 从卡组中获取所有符合条件的「机怪虫」怪兽（排除「机怪虫·郎飞结虫」且可里侧守备特召的怪兽）。
		local g=Duel.GetMatchingGroup(c10698416.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 向系统登记本次连锁的处理内容：从卡组特殊召唤2只怪兽（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果处理时执行的实际操作：若场地等条件仍允许，从符合条件的卡组怪兽中选择2张卡名不同的卡，以里侧守备表示特殊召唤。
function c10698416.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次确认自己场上至少有2个空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 效果处理时再次从卡组获取所有符合条件的「机怪虫」怪兽。
	local g=Duel.GetMatchingGroup(c10698416.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 弹出选择提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从候选卡组中选择2张卡名互不相同的「机怪虫」怪兽（确保同名卡最多1张）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 将选择的2只怪兽以里侧守备表示特殊召唤到自己场上（效果特殊召唤）。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家确认特殊召唤的怪兽，让对方查看这些里侧守备表示的怪兽。
		Duel.ConfirmCards(1-tp,sg)
	end
end
