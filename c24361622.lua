--天球の聖刻印
-- 效果：
-- 龙族怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方回合1次，这张卡在额外怪兽区域存在的场合，把自己的手卡·场上1只怪兽解放才能发动。场上1张表侧表示卡回到手卡。
-- ②：这张卡被解放的场合发动。从手卡·卡组把1只龙族怪兽攻击力·守备力变成0特殊召唤。
function c24361622.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，素材为2只龙族怪兽（通过Card.IsLinkRace过滤，实际要求龙族连接怪兽）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_DRAGON),2,2)
	-- ①：对方回合1次，这张卡在额外怪兽区域存在的场合，把自己的手卡·场上1只怪兽解放才能发动。场上1张表侧表示卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24361622,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c24361622.thcon)
	e1:SetCost(c24361622.thcost)
	e1:SetTarget(c24361622.thtg)
	e1:SetOperation(c24361622.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被解放的场合发动。从手卡·卡组把1只龙族怪兽攻击力·守备力变成0特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24361622,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,24361622)
	e2:SetTarget(c24361622.sptg)
	e2:SetOperation(c24361622.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：此卡位于额外怪兽区域（区域编号>4），且当前为对方回合。
function c24361622.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断这张卡是否在额外怪兽区域（编号>4即处于对方额外怪兽区或己方额外怪兽区）且当前回合玩家不是此卡控制者。
	return e:GetHandler():GetSequence()>4 and Duel.GetTurnPlayer()~=tp
end
-- 解放代价的筛选条件：被解放的卡必须是怪兽，且场上存在除它以外可返回手牌的表侧表示卡。
function c24361622.thcfilter(c,tp)
	return c:IsType(TYPE_MONSTER)
		-- 检查场上是否存在至少1张除解放对象以外的、满足回手条件（表侧表示且可加入手卡）的卡。
		and Duel.IsExistingMatchingCard(c24361622.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 回手目标的条件：表侧表示，并且可以加入手卡（不受不能加入手卡的限制）。
function c24361622.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 支付①效果的代价：从自己的手卡·场上选择1只怪兽解放。先检查是否有合法解放对象，再提示、选择并解放。
function c24361622.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段，确认手卡·场上存在至少1只满足解放筛选条件的怪兽可作为代价。
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c24361622.thcfilter,1,REASON_COST,true,nil,tp) end
	-- 向玩家显示提示，要求选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从自己的手卡·场上选择1只满足条件的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroupEx(tp,c24361622.thcfilter,1,1,REASON_COST,true,nil,tp)
	-- 将选择的怪兽以代价（REASON_COST）解放，完成发动代价的支付。
	Duel.Release(g,REASON_COST)
end
-- ①效果的目标设定：允许发动，并登记操作信息为将场上1张表侧表示卡返回手牌（不取对象，处理时选择）。
function c24361622.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本连锁将处理‘场上表侧表示卡返回手牌’，预计数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_ONFIELD)
end
-- ①效果处理：从双方场上选择1张表侧表示且可回手的卡，返回其持有者的手牌。
function c24361622.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示提示，要求选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从双方场上选择1张满足回手条件（表侧表示且可加入手卡）的卡，不取对象，效果处理时选择。
	local g=Duel.SelectMatchingCard(tp,c24361622.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡返回持有者手牌，原因是效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- ②效果特殊召唤对象的条件：龙族怪兽，且可以被当前效果特殊召唤（满足召唤条件与苏生限制）。
function c24361622.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标设定：允许发动，并登记操作信息为从手卡·卡组特殊召唤1只龙族怪兽。
function c24361622.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本连锁将进行特殊召唤，来源区域为手卡·卡组，预计特殊召唤数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：若自己的主要怪兽区有空位，从手卡·卡组选择1只龙族怪兽特殊召唤，并将其攻击力和守备力变为0。
function c24361622.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区是否还有可用空格；若无空位则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·卡组选择1只满足条件的龙族怪兽（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c24361622.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 以表侧攻击表示分步特殊召唤选择的怪兽；若特殊召唤成功，则继续为其附加攻击力·守备力变成0的效果。
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 攻击力变成0（对应效果原文‘攻击力·守备力变成0’中的攻击力部分）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	-- 结束分步特殊召唤流程，完成整个特殊召唤处理（与SpecialSummonStep配套使用）。
	Duel.SpecialSummonComplete()
end
