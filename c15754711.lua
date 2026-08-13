--ドラゴンメイドのお見送り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「半龙女仆」怪兽为对象才能发动。和那只怪兽卡名不同的1只「半龙女仆」怪兽从手卡守备表示特殊召唤，作为对象的怪兽回到持有者手卡。这个效果特殊召唤的怪兽直到下个回合的结束时不会被战斗·效果破坏。
function c15754711.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「半龙女仆」怪兽为对象才能发动。和那只怪兽卡名不同的1只「半龙女仆」怪兽从手卡守备表示特殊召唤，作为对象的怪兽回到持有者手卡。这个效果特殊召唤的怪兽直到下个回合的结束时不会被战斗·效果破坏。
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
-- 筛选可作为对象的自己场上表侧表示且属于「半龙女仆」系列的怪兽，并确认其能返回手牌，同时手牌中存在另一只满足特殊召唤条件的「半龙女仆」怪兽。
function c15754711.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x133) and c:IsAbleToHand()
		-- 检查手牌中是否存在1只与该对象怪兽卡名不同、且可以按本效果特殊召唤的「半龙女仆」怪兽。
		and Duel.IsExistingMatchingCard(c15754711.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetCode())
end
-- 筛选手牌中属于「半龙女仆」系列、与对象怪兽卡名不同，并且可以被当前效果以表侧守备表示特殊召唤的怪兽。
function c15754711.spfilter(c,e,tp,code)
	return c:IsSetCard(0x133) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的目标选择与合法性判断：若为连锁确认目标则校验所选卡是否合法；若为发动时点则检查能否空出怪兽区域以及是否存在可取对象。
function c15754711.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c15754711.filter(chkc,e,tp) end
	-- 效果发动时点检查自己场上是否有可用的主要怪兽区域用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动时点检查自己场上是否存在至少1只满足filter条件的「半龙女仆」怪兽可以作为取对象目标。
		and Duel.IsExistingTarget(c15754711.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 选择返回手牌的对象前，向操作玩家显示“请选择要返回手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让操作玩家从自己场上选择1只满足filter条件的「半龙女仆」怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c15754711.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁确定会将对象怪兽返回持有者手牌，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：本次连锁确定会从手牌特殊召唤1只怪兽，来源为手牌。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时：若怪兽区域不足则终止；取出对象怪兽并校验其仍与效果关联且表侧表示；选择手牌中符合条件的「半龙女仆」怪兽守备表示特殊召唤，将对象返回手牌；并给特殊召唤的怪兽赋予直到下个回合结束时的战斗·效果破坏抗性。
function c15754711.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有可用主要怪兽区域，若没有则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动时选择的对象怪兽（取对象目标）。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	-- 选择要特殊召唤的怪兽前，向操作玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足spfilter条件（与对象怪兽卡名不同的「半龙女仆」怪兽）作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c15754711.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetCode())
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到操作玩家场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 将作为对象的怪兽返回其持有者手卡（处理回手效果）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 这个效果特殊召唤的怪兽直到下个回合的结束时不会被效果破坏。
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
