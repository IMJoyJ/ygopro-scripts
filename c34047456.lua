--ギガンティック・サンダークロス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己和对方的除外状态的卡数量差的数量的双方的场上·墓地的怪兽为对象才能发动。那些怪兽除外。那之后，对方可以从自身卡组把1只怪兽特殊召唤。
local s,id,o=GetID()
-- 创建效果，设置卡名、分类、类型、时点、发动限制、取对象、提示时机、目标函数和处理函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断目标怪兽是否为怪兽卡且能被除外
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 处理效果目标选择，计算除外数量并选择满足条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(0x14) and s.filter(chkc) end
	-- 计算自己与对方除外区怪兽数量的差值作为除外数量
	local ct=math.abs(Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_REMOVED))
	-- 判断是否满足发动条件，即除外数量大于0且存在满足条件的目标怪兽
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.filter,tp,0x14,0x14,ct,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,0x14,0x14,ct,ct,nil)
	-- 设置操作信息，记录将要除外的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,0,0)
end
-- 过滤函数，用于判断目标怪兽是否能特殊召唤
function s.sfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果发动，将目标怪兽除外并让对方从卡组特殊召唤一只怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标怪兽组并筛选出与效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标怪兽除外并判断对方场上是否有空位
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)<1 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<1 then return end
	-- 获取对方卡组中可特殊召唤的怪兽
	local sg=Duel.GetMatchingGroup(s.sfilter,tp,0,LOCATION_DECK,nil,e,1-tp)
	-- 判断对方是否选择从卡组特殊召唤怪兽
	if #sg>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then  --"是否从卡组特殊召唤？"
		-- 向玩家提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(1-tp,1,1,nil)
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 将选择的怪兽特殊召唤到对方场上
		Duel.SpecialSummon(tg,0,1-tp,1-tp,false,false,POS_FACEUP)
	end
end
