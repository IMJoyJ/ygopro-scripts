--PSYフレーム・アクセラレーター
-- 效果：
-- ①：1回合1次，支付500基本分，以自己场上1只「PSY骨架」怪兽为对象才能发动。那只怪兽直到下次的自己准备阶段除外。
-- ②：1回合1次，这张卡以外的自己场上的表侧表示的「PSY骨架」卡因战斗以外从场上离开的场合才能发动。从手卡把1只「PSY骨架」怪兽特殊召唤。
function c51053997.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，支付500基本分，以自己场上1只「PSY骨架」怪兽为对象才能发动。那只怪兽直到下次的自己准备阶段除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51053997,2))  --"选择1只怪兽除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCost(c51053997.cost)
	e3:SetTarget(c51053997.target)
	e3:SetOperation(c51053997.operation)
	c:RegisterEffect(e3)
	-- ②：1回合1次，这张卡以外的自己场上的表侧表示的「PSY骨架」卡因战斗以外从场上离开的场合才能发动。从手卡把1只「PSY骨架」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(51053997,3))  --"手卡怪兽特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c51053997.spcon)
	e4:SetTarget(c51053997.sptg)
	e4:SetOperation(c51053997.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断是否为可除外的PSY骨架怪兽
function c51053997.rmfilter(c)
	return c:IsSetCard(0xc1) and c:IsAbleToRemove()
end
-- 支付500基本分的效果处理
function c51053997.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 选择目标怪兽的效果处理
function c51053997.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c51053997.rmfilter(chkc) end
	-- 检查场上是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c51053997.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,c51053997.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，指定将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果发动后的处理函数
function c51053997.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local ct=1
		-- 判断是否为当前玩家的准备阶段以决定除外次数
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then ct=2 end
		-- 创建一个在准备阶段触发的效果，用于将除外的怪兽返回场上
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(51053997,4))  --"除外的怪兽回到场上"
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(c51053997.retcon)
		e1:SetOperation(c51053997.retop)
		-- 判断是否为当前玩家的准备阶段
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			-- 设置效果的值为当前回合数
			e1:SetValue(Duel.GetTurnCount())
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e1:SetValue(0)
		end
		-- 将效果注册到玩家环境中
		Duel.RegisterEffect(e1,tp)
		tc:RegisterFlagEffect(51053998,RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,ct)
	end
end
-- 判断准备阶段效果是否满足触发条件
function c51053997.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为目标玩家或当前回合数是否等于设定值
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
	return e:GetLabelObject():GetFlagEffect(51053998)~=0
end
-- 将除外的怪兽返回场上的处理函数
function c51053997.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将指定的卡以REASON_TEMPORARY原因返回场上
	Duel.ReturnToField(tc)
end
-- 过滤函数，用于判断离开场上的卡是否为PSY骨架卡且满足条件
function c51053997.cfilter(c,tp)
	return c:IsPreviousSetCard(0xc1) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- 特殊召唤效果的发动条件判断
function c51053997.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c51053997.cfilter,1,e:GetHandler(),tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 过滤函数，用于判断手卡中是否存在可特殊召唤的PSY骨架怪兽
function c51053997.spfilter(c,e,tp)
	return c:IsSetCard(0xc1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标信息
function c51053997.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡中是否存在满足条件的PSY骨架怪兽
		and Duel.IsExistingMatchingCard(c51053997.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理特殊召唤效果的函数
function c51053997.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的手卡怪兽
	local g=Duel.SelectMatchingCard(tp,c51053997.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
