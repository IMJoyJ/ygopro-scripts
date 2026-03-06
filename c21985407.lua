--聖夜の降臨
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，可以从以下效果选择1个发动。
-- ●以自己场上1只龙族·光属性·7星怪兽为对象才能发动。那只怪兽回到持有者手卡。
-- ●从手卡把1只龙族·光属性·7星怪兽特殊召唤。
function c21985407.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e1)
	-- 效果原文内容：●以自己场上1只龙族·光属性·7星怪兽为对象才能发动。那只怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21985407,0))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,21985407)
	e2:SetCondition(c21985407.condition)
	e2:SetTarget(c21985407.thtg)
	e2:SetOperation(c21985407.thop)
	c:RegisterEffect(e2)
	-- 效果原文内容：●从手卡把1只龙族·光属性·7星怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21985407,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,21985407)
	e3:SetCondition(c21985407.condition)
	e3:SetTarget(c21985407.sptg)
	e3:SetOperation(c21985407.spop)
	c:RegisterEffect(e3)
end
-- 规则层面作用：判断当前是否处于主要阶段1或主要阶段2
function c21985407.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 规则层面作用：定义用于检索的怪兽过滤条件，包括龙族、光属性、7星且能回到手牌
function c21985407.thfilter(c)
	return c:IsFaceup() and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 规则层面作用：设置效果的目标选择逻辑，确保选择的是自己场上的符合条件的怪兽
function c21985407.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21985407.thfilter(chkc) end
	-- 规则层面作用：检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c21985407.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 规则层面作用：向玩家发送提示信息，提示选择要返回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 规则层面作用：选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c21985407.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 规则层面作用：设置效果处理信息，指定将目标怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 规则层面作用：定义效果处理函数，执行将目标怪兽送回手牌的操作
function c21985407.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标怪兽以效果原因送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 规则层面作用：定义用于特殊召唤的怪兽过滤条件，包括龙族、光属性、7星且能特殊召唤
function c21985407.spfilter(c,e,tp)
	return c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置特殊召唤效果的目标选择逻辑，检查手牌中是否存在符合条件的怪兽
function c21985407.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c21985407.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面作用：设置效果处理信息，指定将从手牌特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面作用：定义效果处理函数，执行从手牌特殊召唤怪兽的操作
function c21985407.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查玩家场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：向玩家发送提示信息，提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从手牌中选择满足条件的怪兽用于特殊召唤
	local g=Duel.SelectMatchingCard(tp,c21985407.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 规则层面作用：以指定方式将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
