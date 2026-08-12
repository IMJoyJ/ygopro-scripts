--占い魔女 スィーちゃん
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡的特殊召唤成功的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽直到下次的自己回合的准备阶段除外。
function c5298175.initial_effect(c)
	-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5298175,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1,5298175)
	e1:SetCost(c5298175.spcost)
	e1:SetTarget(c5298175.sptg)
	e1:SetOperation(c5298175.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡的特殊召唤成功的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽直到下次的自己回合的准备阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5298175,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,5298176)
	e2:SetCondition(c5298175.rmcon)
	e2:SetTarget(c5298175.rmtg)
	e2:SetOperation(c5298175.rmop)
	c:RegisterEffect(e2)
end
-- 检查是否满足特殊召唤的费用条件（确认此卡未被公开）
function c5298175.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 设置特殊召唤的目标和条件（判断是否有足够的怪兽区域并能特殊召唤）
function c5298175.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作
function c5298175.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以正面表示形式特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断此卡是否从手牌被特殊召唤成功
function c5298175.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 筛选场上的表侧表示且能被除外的怪兽
function c5298175.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 设置除外效果的目标和条件（选择一个场上的表侧表示怪兽）
function c5298175.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c5298175.rmfilter(chkc) and chkc~=c end
	-- 判断场上是否存在符合条件的除外目标
	if chk==0 then return Duel.IsExistingTarget(c5298175.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一个符合条件的场上的表侧表示怪兽作为除外对象
	local g=Duel.SelectTarget(tp,c5298175.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置操作信息，表示将要进行除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外操作并注册返回效果
function c5298175.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽是否仍然有效并将其除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0
		and tc:IsLocation(LOCATION_REMOVED) then
		-- 创建一个持续到下次准备阶段的除外效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(5298175,2))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c5298175.retcon)
		e1:SetOperation(c5298175.retop)
		-- 判断当前回合玩家是否为该卡的持有者
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			-- 设置该效果在下次准备阶段触发时的回合数
			e1:SetValue(Duel.GetTurnCount())
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e1:SetValue(0)
		end
		-- 将该效果注册到全局环境
		Duel.RegisterEffect(e1,tp)
		tc:CreateEffectRelation(e1)
	end
end
-- 判断是否满足返回场上的条件（回合玩家和回合数）
function c5298175.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为该卡的持有者或是否已到达指定回合
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
	return e:GetLabelObject():IsRelateToEffect(e)
end
-- 执行将怪兽返回场上的操作
function c5298175.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽以原位置返回场上
	Duel.ReturnToField(tc)
end
