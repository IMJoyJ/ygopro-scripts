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
	-- 这个卡名的②的效果在决斗中只能使用1次。②：这张卡在墓地存在的场合，自己主要阶段以自己场上1只「疾行机人」怪兽为对象才能发动。那只怪兽的等级下降1星，这张卡变成通常怪兽（机械族·调整·风·1星·攻/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。
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
-- 过滤自己墓地中可以作为代价除外的风属性怪兽
function c58543073.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToRemoveAsCost()
end
-- ①号效果的发动代价（Cost）处理
function c58543073.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可以作为代价除外的风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58543073.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只风属性怪兽
	local g=Duel.SelectMatchingCard(tp,c58543073.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①号效果的发动准备（Target）处理
function c58543073.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在可以送回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为将该卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①号效果的效果处理（Operation）
function c58543073.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①号效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将作为对象的卡送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②号效果的发动条件判断
function c58543073.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的回合阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否为自己的主要阶段1或主要阶段2
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetTurnPlayer()==tp
end
-- 过滤自己场上表侧表示、等级大于1的「疾行机人」怪兽
function c58543073.lvfilter(c)
	return c:IsSetCard(0x2016) and c:GetLevel()>1 and c:IsFaceup()
end
-- ②号效果的发动准备（Target）处理
function c58543073.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c58543073.lvfilter(chkc) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否能将这张卡作为通常怪兽（机械族·调整·风·1星·攻/守0）特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,58543073,0x2016,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_MACHINE,ATTRIBUTE_WIND)
		-- 检查自己场上是否存在符合条件的「疾行机人」怪兽
		and Duel.IsExistingTarget(c58543073.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只符合条件的「疾行机人」怪兽作为效果对象
	Duel.SelectTarget(tp,c58543073.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②号效果的效果处理（Operation）
function c58543073.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②号效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的等级下降1星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 检查这张卡是否仍存在于墓地且自己场上有空余的怪兽区域
		if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查是否能将这张卡作为通常怪兽（机械族·调整·风·1星·攻/守0）特殊召唤
			and Duel.IsPlayerCanSpecialSummonMonster(tp,58543073,0x2016,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_MACHINE,ATTRIBUTE_WIND)~=0 then
			c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TUNER)
			-- 将这张卡在怪兽区域特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
