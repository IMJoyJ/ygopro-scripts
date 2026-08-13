--ガベージコレクター
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以这张卡以外的自己场上1只电子界族怪兽为对象才能发动。那只怪兽回到持有者手卡，和回到手卡的怪兽相同等级而卡名不同的1只电子界族怪兽从卡组特殊召唤。
function c11801343.initial_effect(c)
	-- 对应效果原文：‘这个卡名的效果1回合只能使用1次。①：以这张卡以外的自己场上1只电子界族怪兽为对象才能发动。那只怪兽回到持有者手卡，和回到手卡的怪兽相同等级而卡名不同的1只电子界族怪兽从卡组特殊召唤。’（本段为创建并注册该效果）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11801343,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,11801343)
	e1:SetTarget(c11801343.target)
	e1:SetOperation(c11801343.operation)
	c:RegisterEffect(e1)
end
-- 定义取对象候选怪兽的过滤函数：要求对象为表侧表示、电子界族、可返回手牌、返回后自己场上仍有怪兽区空位、原类型为怪兽且不是衍生物，并且卡组中存在可特殊召唤的符合条件怪兽。
function c11801343.thfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
		-- 追加条件：选择的怪兽返回手牌后自己场上仍有空余怪兽区，且其原类型为怪兽、不是衍生物。
		and Duel.GetMZoneCount(tp,c)>0 and c:GetOriginalType()&TYPE_MONSTER>0 and not c:IsType(TYPE_TOKEN)
		-- 检查卡组中是否存在满足spfilter条件的电子界族怪兽，作为能否发动/选对象的依据之一。
		and Duel.IsExistingMatchingCard(c11801343.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 定义卡组特殊召唤候选的过滤函数：必须为电子界族、等级与返回手牌的那只怪兽相同、卡名不同，且能够被特殊召唤。
function c11801343.spfilter(c,e,tp,tc)
	return c:IsRace(RACE_CYBERSE) and c:IsLevel(tc:GetLevel())
		and not c:IsCode(tc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的target处理：选择取对象怪兽、给出提示，并设置回手牌和特殊召唤的操作信息。
function c11801343.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c11801343.thfilter(chkc,e,tp) and chkc~=c end
	-- 发动时合法性检查：自己场上是否存在1只满足thfilter条件且不是本卡的电子界族怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c11801343.thfilter,tp,LOCATION_MZONE,0,1,c,e,tp) end
	-- 弹出“请选择要返回手牌的卡”的选择提示（HINTMSG_RTOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己场上选择1只满足条件的电子界族怪兽（不能选自身），并将它登记为效果对象。
	local g=Duel.SelectTarget(tp,c11801343.thfilter,tp,LOCATION_MZONE,0,1,1,c,e,tp)
	-- 设置操作信息：将选择的对象送入手牌（回手牌效果），数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：预定从卡组特殊召唤1只怪兽（具体目标处理时确定，所以targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理时的operation：取得对象，若对象仍与连锁相关则送回手牌，成功后从卡组选择符合条件的电子界族怪兽特殊召唤。
function c11801343.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡（即要返回手牌的怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与当前连锁有关、通过效果成功返回手牌且该卡现在位于手牌，才继续处理。
	if tc:IsRelateToChain() and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND)
		-- 确认返回手牌后自己场上有空余的怪兽区可用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出“请选择要特殊召唤的卡”的选择提示（HINTMSG_SPSUMMON）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足spfilter条件（电子界族、等级相同、卡名不同、可特殊召唤）的怪兽。
		local g=Duel.SelectMatchingCard(tp,c11801343.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
		if g:GetCount()~=0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己的怪兽区。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
