--ヴェーダ＝ウパニシャッド
-- 效果：
-- ←0 【灵摆】 0→
-- ①：自己或对方的怪兽被破坏的场合发动（同一连锁上最多1次）。给这张卡放置3个指示物。
-- ②：这张卡的灵摆刻度上升这张卡的指示物数量的数值。
-- ③：把这张卡12个指示物取除才能发动。这张卡特殊召唤。
-- 【怪兽效果】
-- 这张卡不能通常召唤，用这张卡的灵摆效果才能特殊召唤。自己对「吠陀-优婆尼沙昙」1回合只能有1次特殊召唤。
-- ①：1回合1次，对方从额外卡组把怪兽特殊召唤的场合，从自己的手卡·场上·墓地把12张卡里侧除外才能发动。变成这个回合的结束阶段。
-- ②：自己准备阶段发动。这张卡回到手卡。那之后，可以把自己的手卡·卡组·墓地·除外状态的1只「吠陀」怪兽特殊召唤。
function c40785230.initial_effect(c)
	c:SetSPSummonOnce(40785230)
	c:EnableCounterPermit(0x69,LOCATION_PZONE)
	-- 为灵摆怪兽添加灵摆属性与灵摆召唤规则
	aux.EnablePendulumAttribute(c)
	c:EnableReviveLimit()
	-- 【怪兽效果】这张卡不能通常召唤，用这张卡的灵摆效果才能特殊召唤。自己对「吠陀-优婆尼沙昙」1回合只能有1次特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：自己或对方的怪兽被破坏的场合发动（同一连锁上最多1次）。给这张卡放置3个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c40785230.stcon)
	e1:SetTarget(c40785230.sttg)
	e1:SetOperation(c40785230.stop)
	c:RegisterEffect(e1)
	-- ②：这张卡的灵摆刻度上升这张卡的指示物数量的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_LSCALE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetValue(c40785230.scval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e3)
	-- ③：把这张卡12个指示物取除才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(40785230,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCost(c40785230.spcost)
	e4:SetTarget(c40785230.sptg)
	e4:SetOperation(c40785230.spop)
	c:RegisterEffect(e4)
	-- ①：1回合1次，对方从额外卡组把怪兽特殊召唤的场合，从自己的手卡·场上·墓地把12张卡里侧除外才能发动。变成这个回合的结束阶段。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(40785230,1))  --"变成这个回合的结束阶段"
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1)
	e5:SetCondition(c40785230.etcon)
	e5:SetCost(c40785230.etcost)
	e5:SetOperation(c40785230.etop)
	c:RegisterEffect(e5)
	-- ②：自己准备阶段发动。这张卡回到手卡。那之后，可以把自己的手卡·卡组·墓地·除外状态的1只「吠陀」怪兽特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(40785230,2))  --"这张卡回到手卡"
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_GRAVE_SPSUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c40785230.thcon)
	e6:SetTarget(c40785230.thtg)
	e6:SetOperation(c40785230.thop)
	c:RegisterEffect(e6)
end
-- 判断是否有怪兽被破坏
function c40785230.stcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
-- 放置指示物效果的目标与操作信息设置
function c40785230.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x69,3) end
	-- 设置操作信息：放置3个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x69)
end
-- 放置指示物效果的执行
function c40785230.stop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x69,3)
	end
end
-- 灵摆刻度上升对应数值的求值函数
function c40785230.scval(e,c)
	return c:GetCounter(0x69)
end
-- 特召自身效果的发动成本：从自身去除12个指示物
function c40785230.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x69,12,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x69,12,REASON_COST)
end
-- 特召自身效果的目标与操作信息设置
function c40785230.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 设置操作信息：特殊召唤，数量为1，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特召自身效果的执行
function c40785230.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否能特召成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)>0 then
		c:CompleteProcedure()
	end
end
-- 过滤条件：是否是从额外卡组特殊召唤的对方怪兽
function c40785230.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
-- 结束回合效果的发动条件判定
function c40785230.etcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方是否有怪兽从额外卡组特召成功且当前不为结束阶段
	return eg:IsExists(c40785230.cfilter,1,nil,tp) and Duel.GetCurrentPhase()~=PHASE_END
end
-- 结束回合效果的发动成本：手卡、场上、墓地将12张卡里侧除外
function c40785230.etcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡、场上、墓地是否共有至少12张可以里侧除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,12,nil,POS_FACEDOWN) end
	-- 发送“请选择要除外的卡”提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择12张要除外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,12,12,nil,POS_FACEDOWN)
	-- 将选中的卡里侧表示除外
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 结束回合效果的执行
function c40785230.etop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 跳过抽卡阶段
	Duel.SkipPhase(turnp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
	-- 跳过准备阶段
	Duel.SkipPhase(turnp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
	-- 跳过主要阶段1
	Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	-- 跳过战斗阶段
	Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
	-- 跳过主要阶段2
	Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	-- ①：变成这个回合的结束阶段。与②：回到手卡那之后将「吠陀」怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册玩家效果：当前回合内对方不能进行战斗阶段
	Duel.RegisterEffect(e1,turnp)
end
-- 回到手卡效果的发动条件判定
function c40785230.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否是自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 回到手卡效果的目标与操作信息设置
function c40785230.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：回到手卡，数量为1，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 过滤条件：是否是符合特召条件的「吠陀」怪兽
function c40785230.spfilter(c,e,tp)
	return c:IsSetCard(0x19a) and c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 回到手卡及特召效果的执行
function c40785230.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身回到手卡是否成功
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND) then
		-- 将自身返回手卡后洗牌
		Duel.ShuffleHand(tp)
		-- 获取自己场上怪兽区域的空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取手卡、卡组、墓地、除外状态下的所有「吠陀」怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c40785230.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
		-- 如果有怪兽区空位以及存在可特召的「吠陀」怪兽，且玩家选择特殊召唤
		if ft>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(40785230,3)) then  --"是否特殊召唤？"
			-- 中断效果处理（使之后的效果处理与回手牌不同时进行）
			Duel.BreakEffect()
			-- 发送“请选择要特殊召唤的卡”提示信息
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的「吠陀」怪兽特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
