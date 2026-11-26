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
	-- 为这张卡注册灵摆怪兽属性（灵摆召唤与灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的灵摆效果才能特殊召唤。自己对「吠陀-优婆尼沙昙」1回合只能有1次特殊召唤。
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
	-- ←0 【灵摆】 0→ ②：这张卡的灵摆刻度上升这张卡的指示物数量的数值。
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
	-- 【怪兽效果】 ①：1回合1次，对方从额外卡组把怪兽特殊召唤的场合，从自己的手卡·场上·墓地把12张卡里侧除外才能发动。变成这个回合的结束阶段。
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
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_GRAVE_SPSUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c40785230.thcon)
	e6:SetTarget(c40785230.thtg)
	e6:SetOperation(c40785230.thop)
	c:RegisterEffect(e6)
end
-- 发动条件检查，确认被破坏的卡片中包含怪兽卡
function c40785230.stcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
-- 检查灵摆区的这张卡是否能放置3个指示物并设置放置指示物的操作信息
function c40785230.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x69,3) end
	-- 设置给这张卡放置3个指示物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x69)
end
-- 效果处理，确认这张卡仍与效果关联后为其放置3个指示物
function c40785230.stop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x69,3)
	end
end
-- 数值计算函数，返回这张卡当前持有的指示物数量作为灵摆刻度增益
function c40785230.scval(e,c)
	return c:GetCounter(0x69)
end
-- 发动代价处理，检查并从灵摆区的这张卡取除12个指示物
function c40785230.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x69,12,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x69,12,REASON_COST)
end
-- 检查自己怪兽区是否有空位且此卡可无视召唤条件与苏生限制特殊召唤，并设置操作信息
function c40785230.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否至少有1个空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 设置将灵摆区的这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理，将与效果关联的这张卡表侧表示特殊召唤并完成正规召唤手续
function c40785230.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与效果关联后将其表侧表示特殊召唤到自己场上并判断是否成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)>0 then
		c:CompleteProcedure()
	end
end
-- 过滤函数，检查是否为对方从额外卡组特殊召唤的怪兽
function c40785230.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
-- 发动条件检查，确认对方从额外卡组特殊召唤了怪兽且当前尚未进入结束阶段
function c40785230.etcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断特殊召唤的怪兽中是否包含对方从额外卡组出场的怪兽且当前不是结束阶段
	return eg:IsExists(c40785230.cfilter,1,nil,tp) and Duel.GetCurrentPhase()~=PHASE_END
end
-- 发动代价处理，检查并从自己手卡·场上·墓地选择12张卡里侧除外
function c40785230.etcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·场上·墓地是否存在至少12张可里侧除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,12,nil,POS_FACEDOWN) end
	-- 提示控制者选择作为代价里侧除外的12张卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己手卡·场上·墓地选择12张可里侧除外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,12,12,nil,POS_FACEDOWN)
	-- 将选中的12张卡作为发动代价里侧表示除外
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 效果处理，跳过当前回合玩家剩余各阶段并禁止本回合进入战斗阶段
function c40785230.etop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 跳过当前回合玩家的抽卡阶段
	Duel.SkipPhase(turnp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
	-- 跳过当前回合玩家的准备阶段
	Duel.SkipPhase(turnp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
	-- 跳过当前回合玩家的主要阶段1
	Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	-- 跳过当前回合玩家的战斗阶段及其结束步骤
	Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
	-- 跳过当前回合玩家的主要阶段2
	Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	-- 变成这个回合的结束阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为当前回合玩家注册本回合不能进入战斗阶段的限制效果
	Duel.RegisterEffect(e1,turnp)
end
-- 发动条件检查，确认当前为自己的回合
function c40785230.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 设置将场上的这张卡返回手卡的操作信息
function c40785230.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将这张卡返回手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 过滤函数，检查是否为表侧存在且可特殊召唤的「吠陀」怪兽
function c40785230.spfilter(c,e,tp)
	return c:IsSetCard(0x19a) and c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理，将这张卡返回手卡并洗切手卡，之后可从手卡·卡组·墓地·除外状态特殊召唤1只「吠陀」怪兽
function c40785230.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将与效果关联的这张卡送回手卡并确认已进入手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND) then
		-- 洗切自己的手卡
		Duel.ShuffleHand(tp)
		-- 获取自己怪兽区域的可用空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取自己手卡·卡组·墓地·除外状态中（受王家长眠之谷过滤）可特殊召唤的「吠陀」怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c40785230.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
		-- 在有空位且存在可特殊召唤的「吠陀」怪兽时，询问控制者是否特殊召唤
		if ft>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(40785230,3)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续特殊召唤与前面的回手卡视为不同时处理
			Duel.BreakEffect()
			-- 提示控制者选择要特殊召唤的「吠陀」怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的「吠陀」怪兽表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
