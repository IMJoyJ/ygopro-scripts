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
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选除调整外的1只4星以下的岩石族怪兽特殊召唤。剩余用喜欢的顺序回到卡组下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11302671,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11302672)
	e2:SetTarget(c11302671.sptg2)
	e2:SetOperation(c11302671.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数：确认自己场上没有怪兽，且对方场上有怪兽存在时才允许发动。
function c11302671.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己场上怪兽数量是否为0且对方场上怪兽数量是否大于0，返回该条件是否成立。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 效果①发动时的合法性检查：自己场上有可用怪兽区域，且这张卡能够被特殊召唤。
function c11302671.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的怪兽区域（空格）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，向系统声明本效果将把这张卡特殊召唤，以便连锁判定时识别该效果类别。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理：若此卡仍与发动效果关联，则将其特殊召唤到自己场上。
function c11302671.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②发动条件判定：自己卡组至少要有5张卡（数量大于4）才能发动。
function c11302671.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否多于4张（即至少5张）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 筛选条件：调整以外、4星以下、岩石族怪兽，且可以被特殊召唤。
function c11302671.spfilter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsLevelBelow(4) and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动处理：展示并获取卡组上方5张卡；若存在符合条件的怪兽且玩家选择特殊召唤，则从中选1只符合条件的怪兽特殊召唤，并计算剩余卡片数量。
function c11302671.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若卡组数量不足5张（≤4），则无法进行翻开处理，直接结束本次效果处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=4 then return end
	-- 向当前玩家确认（展示）卡组最上方的5张卡。
	Duel.ConfirmDecktop(tp,5)
	-- 获取卡组最上方的5张卡作为一个卡组对象g，用于后续筛选和计数。
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 判断翻开卡组中是否存在满足特殊召唤条件的怪兽，且自己场上有可用的怪兽区域。
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(c11302671.spfilter,nil,e,tp)>0
		-- 弹窗询问玩家是否选择特殊召唤怪兽；玩家确认后才执行后续选择与召唤操作。
		and Duel.SelectYesNo(tp,aux.Stringid(11302671,2)) then  --"是否特殊召唤怪兽？"
		-- 禁用接下来的自动洗牌检测，保证剩余卡牌能按玩家指定的顺序放回卡组底部而不触发洗牌。
		Duel.DisableShuffleCheck()
		-- 发送卡牌选择提示，引导玩家从翻开卡中选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,c11302671.spfilter,1,1,nil,e,tp)
		-- 将玩家选择的那只怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 让玩家对剩余的卡片按喜欢的顺序排序，决定它们放回卡组底部的顺序。
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 按排序结果取得当前卡组最上方的一张卡（即本次要移动到卡组底部的那张卡）。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最下方；循环执行后，剩余卡片按玩家指定的顺序全部置于卡组底部。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
