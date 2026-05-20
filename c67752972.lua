--エレキュウキ
-- 效果：
-- 「电气」调整＋调整以外的雷族怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡可以直接攻击。
-- ②：这张卡直接攻击给与对方战斗伤害时才能发动。自己墓地的「电气」调整1只和调整以外的自己场上的表侧表示的雷族怪兽1只回到卡组，从额外卡组把「电气穷奇」以外的1只「电气」同调怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册，包括同调召唤手续、直接攻击效果和给与战斗伤害时发动特殊召唤的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续：「电气」调整＋调整以外的雷族怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xe),aux.NonTuner(Card.IsRace,RACE_THUNDER),1)
	-- ①：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：这张卡直接攻击给与对方战斗伤害时才能发动。自己墓地的「电气」调整1只和调整以外的自己场上的表侧表示的雷族怪兽1只回到卡组，从额外卡组把「电气穷奇」以外的1只「电气」同调怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 定义效果②的发动条件函数。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认受到伤害的是对方玩家，且攻击时没有攻击对象（即直接攻击）。
	return ep==1-tp and Duel.GetAttackTarget()==nil
end
-- 定义场上非调整雷族怪兽的过滤函数，需满足能回到卡组且墓地有可配合的「电气」调整。
function s.nfilter(c,e,tp,op)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER) and not c:IsType(TYPE_TUNER) and c:IsAbleToDeck()
		-- 检查自己墓地是否存在能与该场上怪兽配合回到卡组的「电气」调整。
		and Duel.IsExistingMatchingCard(s.tfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c,op)
end
-- 定义墓地「电气」调整的过滤函数，需满足能回到卡组且额外卡组有可特殊召唤的「电气」同调怪兽。
function s.tfilter(c,e,tp,c1,op)
	return c:IsSetCard(0xe) and c:IsType(TYPE_TUNER) and c:IsAbleToDeck()
		-- 检查额外卡组是否存在可特殊召唤的「电气」同调怪兽（若op为true则跳过额外卡组可用格子检查）。
		and (op or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,Group.FromCards(c,c1)))
end
-- 定义额外卡组特殊召唤怪兽的过滤函数，需为「电气穷奇」以外的「电气」同调怪兽，且能特殊召唤并有可用格子。
function s.spfilter(c,e,tp,g,chk)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0xe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 排除同名卡「电气穷奇」，并计算在将选定的2张卡送回卡组后，额外卡组怪兽特殊召唤所需的可用格子。
		and not c:IsCode(id) and (chk or Duel.GetLocationCountFromEx(tp,tp,g,c)>0)
end
-- 定义效果②的发动目标选择与操作信息设置函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动可行性：场上是否存在满足条件的非调整雷族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.nfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,false) end
	-- 设置操作信息：将场上和墓地的共2张卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_MZONE+LOCATION_GRAVE)
	-- 设置操作信息：有1张卡会离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义效果②的效果处理函数，执行回到卡组和特殊召唤的操作。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查在不考虑格子变化的情况下，额外卡组是否存在可特殊召唤的怪兽。
	local opchk=not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil,true)
	-- 提示玩家选择要回到卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己场上1只表侧表示的非调整雷族怪兽。
	local g1=Duel.SelectMatchingCard(tp,s.nfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,opchk)
	if #g1<0 then return end
	-- 提示玩家选择要回到卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己墓地1只「电气」调整。
	local g2=Duel.SelectMatchingCard(tp,s.tfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,g1:GetFirst(),opchk)
	g1:Merge(g2)
	-- 选中选定的两张卡并显示选择动画。
	Duel.HintSelection(g1)
	-- 将选定的2张卡送回卡组并洗牌，若成功回到卡组的数量不足2张则结束处理。
	if Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)<2
		or not g1:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的「电气」同调怪兽。
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if #sg>0 then
		-- 将选中的「电气」同调怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
