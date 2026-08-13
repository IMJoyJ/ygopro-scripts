--SRデュプリゲート
-- 效果：
-- 这个卡名的②的效果在决斗中只能使用1次。
-- ①：从自己墓地把1只风属性怪兽除外，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
-- ②：这张卡在墓地存在的场合，自己主要阶段以自己场上1只「疾行机人」怪兽为对象才能发动。那只怪兽的等级下降1星，这张卡变成通常怪兽（机械族·调整·风·1星·攻/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。
function c58543073.initial_effect(c)
	-- ①：从自己墓地把1只风属性怪兽除外，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58543073,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c58543073.cost)
	e1:SetTarget(c58543073.target)
	e1:SetOperation(c58543073.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，自己主要阶段以自己场上1只「疾行机人」怪兽为对象才能发动。那只怪兽的等级下降1星，这张卡变成通常怪兽（机械族·调整·风·1星·攻/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个卡名的②的效果在决斗中只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58543073,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,58543073+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(c58543073.spcon)
	e2:SetTarget(c58543073.sptg)
	e2:SetOperation(c58543073.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选风属性且可以作为代价除外的怪兽。
function c58543073.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价：从自己墓地把1只风属性怪兽除外。
function c58543073.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只风属性且可以除外的怪兽（能否支付代价的判定）。
	if chk==0 then return Duel.IsExistingMatchingCard(c58543073.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示「请选择要除外的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让自己玩家从自己墓地选择1只风属性且可以除外的怪兽。
	local g=Duel.SelectMatchingCard(tp,c58543073.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的风属性怪兽以正面表示除外，作为效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的取对象处理：以对方场上1张可以回到手卡的卡为对象。
function c58543073.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在至少1张可以回到手卡且能成为效果对象的卡（能否发动的判定）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示「请选择要返回手牌的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让自己玩家选择对方场上1张可以回到手卡的卡，并将其设置为效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息：分类为回到手牌，处理对象为选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的处理：将作为对象的卡回到持有者手卡。
function c58543073.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡在墓地存在，且为自己的主要阶段。
function c58543073.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前的阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判定当前为自己的主要阶段1或主要阶段2。
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetTurnPlayer()==tp
end
-- 过滤函数：筛选「疾行机人」系列、等级大于1的正面表示怪兽。
function c58543073.lvfilter(c)
	return c:IsSetCard(0x2016) and c:GetLevel()>1 and c:IsFaceup()
end
-- ②效果的取对象处理：确认怪兽区域有空格、可以把这张卡当作陷阱怪兽特殊召唤，并以自己场上1只满足条件的「疾行机人」怪兽为对象。
function c58543073.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c58543073.lvfilter(chkc) end
	-- 检查自己怪兽区域是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否可以把这张卡当作通常怪兽（机械族·调整·风·1星·攻/守0）特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,58543073,0x2016,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_MACHINE,ATTRIBUTE_WIND)
		-- 检查自己场上是否存在至少1只满足条件的「疾行机人」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c58543073.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示「请选择效果的对象」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让自己玩家选择自己场上1只满足条件的「疾行机人」怪兽，并将其设置为效果的对象。
	Duel.SelectTarget(tp,c58543073.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁的操作信息：分类为特殊召唤，处理对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：使对象怪兽的等级下降1星，再把这张卡变成通常怪兽在怪兽区域特殊召唤。
function c58543073.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡（那只「疾行机人」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 检查这张卡是否还在墓地与效果关联，以及自己怪兽区域是否还有可用的空格。
		if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 再次检查自己是否可以把这张卡当作通常怪兽（机械族·调整·风·1星·攻/守0）特殊召唤。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,58543073,0x2016,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_MACHINE,ATTRIBUTE_WIND) then
			c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TUNER)
			-- 把这张卡变成通常怪兽（不当作陷阱卡使用），以正面表示在怪兽区域特殊召唤。
			Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
