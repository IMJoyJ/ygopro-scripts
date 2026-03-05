--ドラゴンメイドのお見送り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「半龙女仆」怪兽为对象才能发动。和那只怪兽卡名不同的1只「半龙女仆」怪兽从手卡守备表示特殊召唤，作为对象的怪兽回到持有者手卡。这个效果特殊召唤的怪兽直到下个回合的结束时不会被战斗·效果破坏。
function c15754711.initial_effect(c)
	-- 效果发动条件：这张卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,15754711+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c15754711.target)
	e1:SetOperation(c15754711.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择自己场上表侧表示的「半龙女仆」怪兽，且该怪兽可以回到手卡，并且自己手卡存在与该怪兽卡名不同的「半龙女仆」怪兽。
function c15754711.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x133) and c:IsAbleToHand()
		-- 检查手卡是否存在与目标怪兽卡名不同的「半龙女仆」怪兽。
		and Duel.IsExistingMatchingCard(c15754711.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetCode())
end
-- 特殊召唤过滤函数：选择手卡中「半龙女仆」怪兽，且该怪兽卡名与目标怪兽不同，可以特殊召唤。
function c15754711.spfilter(c,e,tp,code)
	return c:IsSetCard(0x133) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时点处理：判断是否满足发动条件，即自己场上存在符合条件的「半龙女仆」怪兽。
function c15754711.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c15754711.filter(chkc,e,tp) end
	-- 判断自己场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己场上是否存在符合条件的「半龙女仆」怪兽。
		and Duel.IsExistingTarget(c15754711.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示选择要返回手牌的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标怪兽。
	local g=Duel.SelectTarget(tp,c15754711.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果操作信息：将目标怪兽返回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果操作信息：特殊召唤1只手卡中的「半龙女仆」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：判断是否满足处理条件，包括是否有空位、目标怪兽是否有效、是否能特殊召唤。
function c15754711.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	-- 提示选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择满足条件的「半龙女仆」怪兽。
	local g=Duel.SelectMatchingCard(tp,c15754711.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetCode())
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 将目标怪兽送回手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 效果作用：特殊召唤的怪兽直到下个回合结束时不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		g:GetFirst():RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		g:GetFirst():RegisterEffect(e2)
	end
end
