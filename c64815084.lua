--進化の分岐点
-- 效果：
-- 选择自己场上1只爬虫类族怪兽发动。选择的怪兽破坏，从卡组把1只名字带有「进化虫」的怪兽里侧守备表示特殊召唤。
function c64815084.initial_effect(c)
	-- 选择自己场上1只爬虫类族怪兽发动。选择的怪兽破坏，从卡组把1只名字带有「进化虫」的怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c64815084.target)
	e1:SetOperation(c64815084.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的爬虫类族怪兽
function c64815084.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
end
-- 过滤条件：卡组中可以里侧守备表示特殊召唤的「进化虫」怪兽
function c64815084.spfilter(c,e,tp)
	return c:IsSetCard(0x304e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动时的目标选择与合法性检测
function c64815084.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c64815084.filter(chkc) end
	-- 检查自己场上是否存在可作为对象的表侧表示爬虫类族怪兽
	if chk==0 then return Duel.IsExistingTarget(c64815084.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查卡组中是否存在可特殊召唤的「进化虫」怪兽
		and Duel.IsExistingMatchingCard(c64815084.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的爬虫类族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c64815084.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c64815084.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍表侧表示存在且该卡效果适用，则将其破坏
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的「进化虫」怪兽
		local g=Duel.SelectMatchingCard(tp,c64815084.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 将选择的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
