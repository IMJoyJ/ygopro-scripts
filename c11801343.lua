--ガベージコレクター
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以这张卡以外的自己场上1只电子界族怪兽为对象才能发动。那只怪兽回到持有者手卡，和回到手卡的怪兽相同等级而卡名不同的1只电子界族怪兽从卡组特殊召唤。
function c11801343.initial_effect(c)
	-- ①：以这张卡以外的自己场上1只电子界族怪兽为对象才能发动。那只怪兽回到持有者手卡，和回到手卡的怪兽相同等级而卡名不同的1只电子界族怪兽从卡组特殊召唤。
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
-- 过滤函数，用于判断目标怪兽是否可以被送入手牌
function c11801343.thfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
		-- 确保目标怪兽所在区域有空位且不是衍生物
		and Duel.GetMZoneCount(tp,c)>0 and c:GetOriginalType()&TYPE_MONSTER>0 and not c:IsType(TYPE_TOKEN)
		-- 检查卡组中是否存在满足条件的怪兽进行特殊召唤
		and Duel.IsExistingMatchingCard(c11801343.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 过滤函数，用于判断卡组中是否有符合条件的怪兽可以特殊召唤
function c11801343.spfilter(c,e,tp,tc)
	return c:IsRace(RACE_CYBERSE) and c:IsLevel(tc:GetLevel())
		and not c:IsCode(tc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的处理函数，用于设置效果的目标和操作信息
function c11801343.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c11801343.thfilter(chkc,e,tp) and chkc~=c end
	-- 检查是否满足发动条件，即场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c11801343.thfilter,tp,LOCATION_MZONE,0,1,c,e,tp) end
	-- 向玩家提示选择要送入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	-- 选择符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c11801343.thfilter,tp,LOCATION_MZONE,0,1,1,c,e,tp)
	-- 设置效果操作信息，表示将怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果操作信息，表示将怪兽从卡组特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动后的处理函数，用于执行效果的后续操作
function c11801343.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍然在连锁中且成功送入手牌
	if tc:IsRelateToChain() and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND)
		-- 确保玩家场上存在空位用于特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家提示选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 从卡组中选择符合条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,c11801343.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
		if g:GetCount()~=0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
