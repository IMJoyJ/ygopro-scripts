--魔救の追求者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「魔救之追求者」以外的「魔救」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只调整以外的4星以下的岩石族怪兽特殊召唤。剩下的卡用喜欢的顺序回到卡组最下面。
function c48519867.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡存在，自己场上有「魔救之追求者」以外的「魔救」怪兽存在的场合才能发动。这张卡特殊召唤。
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
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选除调整外的1只4星以下的岩石族怪兽特殊召唤。剩余用喜欢的顺序回到卡组下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48519867,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,48519868)
	e2:SetTarget(c48519867.sptg2)
	e2:SetOperation(c48519867.spop2)
	c:RegisterEffect(e2)
end
-- 筛选条件：表侧表示、属于「魔救」字段、且不是本卡（魔救之追求者），用于检查①的发动条件。
function c48519867.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x140) and not c:IsCode(48519867)
end
-- 效果①的发动条件：检查自己场上是否存在至少1只满足cfilter筛选的「魔救」怪兽。
function c48519867.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足条件的「魔救」怪兽（表侧表示、魔救字段、不是本卡）。
	return Duel.IsExistingMatchingCard(c48519867.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①发动时的合法性检查：确认自己主要怪兽区有空位，且这张手卡可以被特殊召唤。
function c48519867.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己主要怪兽区是否存在空位（chk==0为发动合法性确认阶段）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次效果处理涉及特殊召唤本卡的操作信息，供其他卡连锁时查询（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理时：先确认这张卡仍与效果关联（未离场或未失效），然后将其特殊召唤。
function c48519867.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上（不取对象，不入连锁的特殊召唤处理）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动合法性检查：自己卡组数量必须大于4，否则无法翻开5张卡。
function c48519867.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时确认自己卡组数量>4（至少有5张卡可翻开）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 筛选②可特殊召唤的候选怪兽：调整以外、4星以下、岩石族、且可以被特殊召唤。
function c48519867.spfilter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsLevelBelow(4) and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②处理：翻开卡组顶5张，若有符合条件的怪兽且场上有空位，则询问玩家是否特殊召唤；随后把剩余卡按玩家喜欢的顺序放回卡组底部。
function c48519867.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认卡组数量>4，防止处理前卡组已不足5张。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=4 then return end
	-- 将卡组最上方的5张卡公开给双方确认（翻开效果）。
	Duel.ConfirmDecktop(tp,5)
	-- 取得卡组最上方的5张卡作为一个组对象，用于后续筛选和计数。
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 判断翻开区域有卡、自己场上有特殊召唤空格、且其中有符合条件的可特殊召唤怪兽。
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(c48519867.spfilter,nil,e,tp)>0
		-- 询问玩家是否从翻开的卡中选择1只符合条件的怪兽进行特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(48519867,2)) then  --"是否特殊召唤怪兽？"
		-- 禁止本次操作后的自动洗切卡组检测，保证后续按顺序移动剩余卡到卡组底。
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要特殊召唤的卡，并进入选卡界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,c48519867.spfilter,1,1,nil,e,tp)
		-- 将玩家选择的符合条件的怪兽特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 让玩家对剩余的卡按喜欢的顺序排序，先选的排在上面，之后依次移到底部。
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 取出卡组最上方1张卡（当前最上面的剩余卡），用于循环移到底部。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将这张卡从卡组最上方移动到卡组最下面，实现“按喜欢的顺序回到卡组下面”。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
