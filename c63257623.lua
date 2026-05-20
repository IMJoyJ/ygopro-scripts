--森羅の実張り ピース
-- 效果：
-- 这张卡召唤·特殊召唤成功时，可以把自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以从自己墓地选择1只4星以下的植物族怪兽特殊召唤。「森罗的监实者 豌豆」的这个效果1回合只能使用1次。
function c63257623.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，可以把自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63257623,0))  --"确认卡组"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c63257623.target)
	e1:SetOperation(c63257623.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 卡组的这张卡被卡的效果翻开送去墓地的场合，可以从自己墓地选择1只4星以下的植物族怪兽特殊召唤。「森罗的监实者 豌豆」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63257623,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,63257623)
	e3:SetCondition(c63257623.spcon)
	e3:SetTarget(c63257623.sptg)
	e3:SetOperation(c63257623.spop)
	c:RegisterEffect(e3)
end
-- 召唤·特殊召唤成功时效果的发动准备与可行性检测
function c63257623.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将卡组顶端的卡送去墓地（用于确认是否能翻开卡组顶端的卡）
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 召唤·特殊召唤成功时效果的处理：翻开卡组顶端的卡，是植物族则送去墓地，否则放回卡组最下方
function c63257623.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查玩家是否能将卡组顶端的卡送去墓地，不能则不处理
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认（翻开）玩家卡组最上方的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取玩家卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 使接下来的操作不触发系统自动洗牌检测
		Duel.DisableShuffleCheck()
		-- 将翻开的卡因效果且作为被翻开的状态送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 将翻开的卡移动到卡组最下方
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 检查这张卡是否原本在卡组，并且是因为被翻开而送去墓地
function c63257623.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 过滤出墓地中等级4以下、可以特殊召唤的植物族怪兽
function c63257623.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备、可行性检测及选择目标
function c63257623.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c63257623.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己墓地是否存在满足条件的植物族怪兽
		and Duel.IsExistingTarget(c63257623.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的植物族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c63257623.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理：将选中的墓地怪兽特殊召唤
function c63257623.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
