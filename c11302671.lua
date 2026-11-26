--魔救の分析者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：只有对方场上才有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只调整以外的4星以下的岩石族怪兽特殊召唤。剩下的卡用喜欢的顺序回到卡组最下面。
function c11302671.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：只有对方场上才有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11302671,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,11302671)
	e1:SetCondition(c11302671.spcon1)
	e1:SetTarget(c11302671.sptg1)
	e1:SetOperation(c11302671.spop1)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选除调整外的1只4星以下的岩石族怪兽特殊召唤。剩余用喜欢的顺序回到卡组下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11302671,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11302672)
	e2:SetTarget(c11302671.sptg2)
	e2:SetOperation(c11302671.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的Condition函数：检查是否自己怪兽区没有怪兽且对方怪兽区存在怪兽
function c11302671.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方怪兽区卡片数为0且对方怪兽区卡片数大于0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 效果①的Target函数：检查己方怪兽区有空位且手卡中的这张卡可被特殊召唤
function c11302671.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方主要怪兽区至少有1个可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的Operation函数：确认这张卡仍与效果关联后将其从手卡表侧特殊召唤到己方场上
function c11302671.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到己方场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的Target函数：检测己方卡组剩余卡片数量是否至少有5张
function c11302671.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方卡组中至少有5张卡（数量大于4）
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 过滤函数：筛选非调整、4星以下、岩石族且可以被效果特殊召唤的怪兽
function c11302671.spfilter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsLevelBelow(4) and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Operation函数：翻开己方卡组最上方5张卡，由玩家选择是否从中特殊召唤1只非调整的4星以下岩石族怪兽
function c11302671.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若效果处理时己方卡组数量不足5张则中止处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=4 then return end
	-- 翻开并确认己方卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 获取己方卡组最上方这5张卡组成的卡片组
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 检查己方怪兽区有空位且翻开的卡中存在可特殊召唤的符合条件怪兽
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(c11302671.spfilter,nil,e,tp)>0
		-- 询问己方玩家是否要从翻开的卡中特殊召唤怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(11302671,2)) then  --"是否特殊召唤怪兽？"
		-- 禁用紧接着的特殊召唤操作后的自动洗切卡组检测，以保持翻开卡的顺序
		Duel.DisableShuffleCheck()
		-- 向己方玩家发送选择要特殊召唤的卡片提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,c11302671.spfilter,1,1,nil,e,tp)
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 让己方玩家对剩余的ct张卡组顶端卡片按喜欢的顺序排列
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 获取当前位于己方卡组最上方的1张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到己方卡组最下面，循环执行从而按顺序放回卡组底端
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
