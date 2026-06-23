--ガード・マンティス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：支付1000基本分才能发动。这张卡从手卡守备表示特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是昆虫族怪兽不能特殊召唤。
-- ②：对方回合，以自己场上1只昆虫族怪兽为对象才能发动。那只怪兽的表示形式变更。
function c53754104.initial_effect(c)
	-- ①：支付1000基本分才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53754104,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,53754104)
	e1:SetCost(c53754104.spcost)
	e1:SetTarget(c53754104.sptg)
	e1:SetOperation(c53754104.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，以自己场上1只昆虫族怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53754104,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,53754105)
	e2:SetCondition(c53754104.poscon)
	e2:SetTarget(c53754104.postg)
	e2:SetOperation(c53754104.posop)
	c:RegisterEffect(e2)
end
-- 支付1000基本分
function c53754104.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 选择特殊召唤目标
function c53754104.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的怪兽区域并满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤效果
function c53754104.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否与效果相关且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		-- 只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是昆虫族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c53754104.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 限制非昆虫族怪兽的特殊召唤
function c53754104.splimit(e,c)
	return not c:IsRace(RACE_INSECT)
end
-- 对方回合条件
function c53754104.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 选择目标怪兽的过滤器
function c53754104.pfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
		and c:IsCanChangePosition()
end
-- 设置表示形式变更效果的目标选择
function c53754104.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53754104.pfilter(chkc) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c53754104.pfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c53754104.pfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息为表示形式变更
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理表示形式变更效果
function c53754104.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
