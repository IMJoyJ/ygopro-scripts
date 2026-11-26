--魔救の追求者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「魔救之追求者」以外的「魔救」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只调整以外的4星以下的岩石族怪兽特殊召唤。剩下的卡用喜欢的顺序回到卡组最下面。
function c48519867.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。 ①：这张卡在手卡存在，自己场上有「魔救之追求者」以外的「魔救」怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48519867,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,48519867)
	e1:SetCondition(c48519867.spcon1)
	e1:SetTarget(c48519867.sptg1)
	e1:SetOperation(c48519867.spop1)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选除调整外的1只4星以下的岩石族怪兽特殊召唤。剩余用喜欢的顺序回到卡组下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48519867,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,48519868)
	e2:SetTarget(c48519867.sptg2)
	e2:SetOperation(c48519867.spop2)
	c:RegisterEffect(e2)
end
-- 筛选条件：检查卡片是否为「魔救之追求者」以外的表侧表示「魔救」怪兽
function c48519867.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x140) and not c:IsCode(48519867)
end
-- ①效果的发动条件检查：确认己方场上存在「魔救之追求者」以外的表侧「魔救」怪兽
function c48519867.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方怪兽区是否存在其他表侧表示的「魔救」怪兽
	return Duel.IsExistingMatchingCard(c48519867.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动检测：确认己方怪兽区有空位且手卡中的这张卡可以被特殊召唤
function c48519867.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查（前半）：确认己方主要怪兽区存在可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记连锁的特殊召唤操作信息，预计将手卡的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理流程：确认手卡的这张卡仍与效果有联系后，将其以表侧表示特殊召唤到己方场上
function c48519867.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到己方场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动检测：确认己方卡组剩余卡片数量不少于5张
function c48519867.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方卡组至少有5张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 筛选条件：检查卡片是否为调整以外、4星以下、岩石族且可特殊召唤的怪兽
function c48519867.spfilter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsLevelBelow(4) and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的处理前半部分：翻开己方卡组最上方5张卡，若有满足条件的4星以下非调整岩石族怪兽且有空位，则询问并特殊召唤其中1只
function c48519867.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认己方卡组至少有5张卡，不足5张则终止处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=4 then return end
	-- 从己方卡组最上方翻开5张卡并向双方公开确认
	Duel.ConfirmDecktop(tp,5)
	-- 获取己方卡组最上方被翻开的5张卡片组
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 检查己方怪兽区是否有空位且翻开的卡中存在可特殊召唤的4星以下非调整岩石族怪兽
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(c48519867.spfilter,nil,e,tp)>0
		-- 询问己方是否要从翻开的卡中特殊召唤怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(48519867,2)) then  --"是否特殊召唤怪兽？"
		-- 禁用下一次操作后的卡组洗切检测，以免在特殊召唤后自动洗卡
		Duel.DisableShuffleCheck()
		-- 向己方提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,c48519867.spfilter,1,1,nil,e,tp)
		-- 将所选岩石族怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 让己方对卡组最上方剩余的翻开的卡进行排序
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 获取排序后位于卡组最顶端的1张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 依次将该卡移动到卡组最下面，使剩余卡按所选顺序回到卡组底
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
