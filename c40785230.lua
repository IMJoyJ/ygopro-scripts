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
	-- 为灵摆怪兽添加灵摆属性，使其能够进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的灵摆效果才能特殊召唤。
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
-- 检查被破坏的卡片中是否存在怪兽
function c40785230.stcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
-- 检查此卡是否能放置3个指示物，并设置操作信息用于提示玩家将要进行的操作
function c40785230.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x69,3) end
	-- 设置操作信息，表明将要放置3个指示物（类型为0x69）
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x69)
end
-- 若此卡仍在场上，则为其放置3个指示物
function c40785230.stop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x69,3)
	end
end
-- 返回此卡当前拥有的指示物数量，用于更新灵摆刻度
function c40785230.scval(e,c)
	return c:GetCounter(0x69)
end
-- 检查是否能移除12个指示物作为成本，并执行移除操作
function c40785230.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x69,12,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x69,12,REASON_COST)
end
-- 检查是否有空位可特殊召唤此卡，并确认其能否被特殊召唤
function c40785230.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家主怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 设置操作信息，表明将特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 若此卡仍有效且成功特殊召唤，则完成召唤程序
function c40785230.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍然有效并成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)>0 then
		c:CompleteProcedure()
	end
end
-- 过滤条件：召唤来源为额外卡组且由对手召唤
function c40785230.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
-- 检查是否存在符合条件的额外卡组特殊召唤事件，并确保当前不是结束阶段
function c40785230.etcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否存在符合条件的额外卡组特殊召唤事件，并且当前阶段不是结束阶段
	return eg:IsExists(c40785230.cfilter,1,nil,tp) and Duel.GetCurrentPhase()~=PHASE_END
end
-- 检查是否存在足够数量的卡可用于里侧除外作为成本，并让用户选择具体要除外的卡
function c40785230.etcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在至少12张卡可以在手牌、场上或墓地中被里侧除外
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,12,nil,POS_FACEDOWN) end
	-- 提示用户选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让用户选择12张卡进行里侧除外
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,12,12,nil,POS_FACEDOWN)
	-- 以里侧表示形式除外所选的卡作为成本
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 跳过当前回合玩家的所有主要阶段和战斗阶段，直到回合结束，并注册一个防止进入战斗阶段的效果
function c40785230.etop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合的玩家
	local turnp=Duel.GetTurnPlayer()
	-- 跳过当前回合玩家的抽卡阶段直至回合结束
	Duel.SkipPhase(turnp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
	-- 跳过当前回合玩家的准备阶段直至回合结束
	Duel.SkipPhase(turnp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
	-- 跳过当前回合玩家的第一主要阶段直至回合结束
	Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	-- 跳过当前回合玩家的战斗阶段直至回合结束（包括结束步骤）
	Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
	-- 跳过当前回合玩家的第二主要阶段直至回合结束
	Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	-- 注册一个全局效果，使得当前回合玩家无法进入战斗阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册上述防止进入战斗阶段的效果至当前回合玩家
	Duel.RegisterEffect(e1,turnp)
end
-- 检查当前是否是该卡控制者的回合
function c40785230.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合是否属于该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 设置操作信息，表明将把手卡送回持有者手中
function c40785230.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明将把手卡送回持有者手中
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 过滤条件：属于吠陀系列、正面表示、可以特殊召唤
function c40785230.spfilter(c,e,tp)
	return c:IsSetCard(0x19a) and c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 将此卡送入手牌；若有空位且存在可特殊召唤的吠陀怪兽，在询问后将其特殊召唤
function c40785230.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍然有效并成功送入手牌且位于手牌区域
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND) then
		-- 手动洗切控制者的手牌
		Duel.ShuffleHand(tp)
		-- 获取控制者主怪兽区域的可用空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检索控制者手牌、卡组、墓地、除外区中满足条件的吠陀怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c40785230.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
		-- 如果有空位、存在符合条件的怪兽，并且用户选择特殊召唤
		if ft>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(40785230,3)) then  --"是否特殊召唤？"
			-- 中断当前效果处理流程，使后续处理视为新的时点
			Duel.BreakEffect()
			-- 提示用户选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 以表侧攻击表示形式特殊召唤选定的怪兽
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
