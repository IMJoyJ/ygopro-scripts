--魔救の分析者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：只有对方场上才有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只调整以外的4星以下的岩石族怪兽特殊召唤。剩下的卡用喜欢的顺序回到卡组最下面。
function c11302671.initial_effect(c)
	-- 效果原文内容：①：只有对方场上才有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
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
	-- 效果原文内容：②：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只调整以外的4星以下的岩石族怪兽特殊召唤。剩下的卡用喜欢的顺序回到卡组最下面。
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
-- 规则层面作用：设置效果1的条件函数
function c11302671.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断自己场上没有怪兽且对方场上存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 规则层面作用：设置效果1的目标函数
function c11302671.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面作用：设置效果处理时的操作信息，表明将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面作用：设置效果1的处理函数
function c11302671.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面作用：将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 规则层面作用：设置效果2的目标函数
function c11302671.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查卡组是否至少有5张牌
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 规则层面作用：定义筛选可特殊召唤怪兽的过滤函数
function c11302671.spfilter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsLevelBelow(4) and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置效果2的处理函数
function c11302671.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：如果卡组少于5张则不执行效果
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=4 then return end
	-- 规则层面作用：确认自己卡组最上方的5张牌
	Duel.ConfirmDecktop(tp,5)
	-- 规则层面作用：获取卡组最上方的5张牌组成一个组
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 规则层面作用：判断是否有满足条件的怪兽可特殊召唤且场上还有空位
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(c11302671.spfilter,nil,e,tp)>0
		-- 规则层面作用：询问玩家是否要特殊召唤怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(11302671,2)) then  --"是否特殊召唤怪兽？"
		-- 规则层面作用：禁止后续操作自动洗切卡组
		Duel.DisableShuffleCheck()
		-- 规则层面作用：提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:FilterSelect(tp,c11302671.spfilter,1,1,nil,e,tp)
		-- 规则层面作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 规则层面作用：对剩余的牌按玩家意愿排序放回卡组底部
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 规则层面作用：获取卡组最上方的一张牌
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 规则层面作用：将该牌移动到卡组最底部
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
