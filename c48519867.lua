--魔救の追求者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「魔救之追求者」以外的「魔救」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只调整以外的4星以下的岩石族怪兽特殊召唤。剩下的卡用喜欢的顺序回到卡组最下面。
function c48519867.initial_effect(c)
	-- ①：自己场上有「魔救之追求者」以外的「魔救」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
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
	-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只调整以外的4星以下的岩石族怪兽特殊召唤。剩下的卡用喜欢的顺序回到卡组最下面。
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
-- 检查场上是否存在「魔救」族且不是魔救之追求者的怪兽
function c48519867.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x140) and not c:IsCode(48519867)
end
-- 效果①的发动条件判断
function c48519867.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「魔救」族且不是魔救之追求者的怪兽
	return Duel.IsExistingMatchingCard(c48519867.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动时点处理
function c48519867.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理过程
function c48519867.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动时点处理
function c48519867.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组是否至少有5张牌
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 筛选符合条件的可特殊召唤怪兽的过滤函数
function c48519867.spfilter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsLevelBelow(4) and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的处理过程
function c48519867.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若卡组少于5张则不执行效果
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=4 then return end
	-- 翻开自己卡组最上方的5张牌
	Duel.ConfirmDecktop(tp,5)
	-- 获取翻开的5张牌组成的牌组
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 判断是否有满足条件的怪兽可特殊召唤且场上存在空位
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(c48519867.spfilter,nil,e,tp)>0
		-- 询问玩家是否要特殊召唤怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(48519867,2)) then  --"是否特殊召唤怪兽？"
		-- 禁止后续操作进行洗切卡组检测
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,c48519867.spfilter,1,1,nil,e,tp)
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 对剩余的牌按玩家意愿排序放回卡组底部
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 获取需要移动的牌
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该牌移至卡组最下方
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
