--魔救の探索者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上有「魔救之探索者」以外的岩石族怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选除调整外的1只4星以下的岩石族怪兽特殊召唤。剩余用喜欢的顺序回到卡组下面。
function c85914562.initial_effect(c)
	-- ①：这张卡在手卡存在，自己场上有「魔救之探索者」以外的岩石族怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85914562,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,85914562)
	e1:SetCondition(c85914562.spcon1)
	e1:SetTarget(c85914562.sptg1)
	e1:SetOperation(c85914562.spop1)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选除调整外的1只4星以下的岩石族怪兽特殊召唤。剩余用喜欢的顺序回到卡组下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85914562,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,85914563)
	e2:SetTarget(c85914562.sptg2)
	e2:SetOperation(c85914562.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「魔救之探索者」以外的岩石族怪兽
function c85914562.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ROCK) and not c:IsCode(85914562)
end
-- 效果1的发动条件函数
function c85914562.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「魔救之探索者」以外的岩石族怪兽
	return Duel.IsExistingMatchingCard(c85914562.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果1的发动准备与合法性检测函数
function c85914562.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果1的效果处理函数
function c85914562.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果2的发动准备与合法性检测函数
function c85914562.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组的卡片数量是否大于4张
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 过滤条件：除调整以外的4星以下的岩石族怪兽
function c85914562.spfilter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsLevelBelow(4) and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的效果处理函数
function c85914562.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若卡组卡片数量小于等于4张则不处理效果
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=4 then return end
	-- 确认自己卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 获取自己卡组最上方的5张卡
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 检查是否有翻开的卡、是否有可用怪兽区域以及翻开的卡中是否有满足特殊召唤条件的怪兽
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(c85914562.spfilter,nil,e,tp)>0
		-- 询问玩家是否进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(85914562,2)) then  --"是否特殊召唤怪兽？"
		-- 关闭接下来的卡组洗牌检测
		Duel.DisableShuffleCheck()
		-- 设置选择特殊召唤卡片时的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,c85914562.spfilter,1,1,nil,e,tp)
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 让玩家对卡组最上方的剩余卡片进行排序
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 获取当前卡组最上方的一张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最下方
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
