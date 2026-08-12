--魔救の奇跡－ラプタイト
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只岩石族怪兽守备表示特殊召唤。剩下的卡用喜欢的顺序回到卡组最下面。
-- ②：对方回合，自己墓地有风属性怪兽存在的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
function c73079836.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只岩石族怪兽守备表示特殊召唤。剩下的卡用喜欢的顺序回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73079836,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,73079836)
	e1:SetTarget(c73079836.sptg)
	e1:SetOperation(c73079836.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，自己墓地有风属性怪兽存在的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73079836,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,73079837)
	e2:SetCondition(c73079836.rmcon)
	e2:SetTarget(c73079836.rmtg)
	e2:SetOperation(c73079836.rmop)
	c:RegisterEffect(e2)
end
-- 效果①的Target（发动准备）函数：检查卡组数量是否大于4张
function c73079836.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己卡组上方的卡片数量是否大于4张
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 过滤条件：岩石族且可以特殊召唤的怪兽
function c73079836.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的Operation（效果处理）函数前半部分：翻开卡组上方5张卡，并选择其中1只岩石族怪兽特殊召唤
function c73079836.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己卡组数量小于等于4张，则不处理效果
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=4 then return end
	-- 确认（翻开）自己卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 获取自己卡组最上方的5张卡
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 检查翻开的卡片数量大于0、自己场上有怪兽区域空位，且翻开的卡中存在满足特殊召唤条件的岩石族怪兽
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(c73079836.spfilter,nil,e,tp)>0
		-- 询问玩家是否要特殊召唤怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(73079836,2)) then  --"是否特殊召唤怪兽？"
		-- 禁用接下来的洗卡检测（防止因卡片离开卡组而自动洗牌）
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,c73079836.spfilter,1,1,nil,e,tp)
		-- 将选择的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 让玩家对卡组最上方的剩余卡片进行排序
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 获取卡组最上方的一张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最下面
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 效果②的Condition（发动条件）函数
function c73079836.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是对方回合，且自己墓地存在风属性怪兽
	return Duel.GetTurnPlayer()==1-tp and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_WIND)
end
-- 效果②的Target（选择对象）函数
function c73079836.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 在发动时，检查对方墓地是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息：除外该目标卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果②的Operation（效果处理）函数
function c73079836.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
