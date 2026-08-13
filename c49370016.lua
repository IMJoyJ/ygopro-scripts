--P.U.N.K.JAMエクストリーム・セッション
-- 效果：
-- 这个卡名的②的效果1回合可以使用最多2次。
-- ①：1回合1次，从自己墓地把1张「朋克」卡除外才能发动。从手卡把1只「朋克」怪兽特殊召唤。
-- ②：自己场上的念动力族怪兽为让效果发动而支付基本分的场合才能发动。自己抽1张。
function c49370016.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从自己墓地把1张「朋克」卡除外才能发动。从手卡把1只「朋克」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c49370016.spcost)
	e2:SetTarget(c49370016.sptg)
	e2:SetOperation(c49370016.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合可以使用最多2次。②：自己场上的念动力族怪兽为让效果发动而支付基本分的场合才能发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PAY_LPCOST)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(2,49370016)
	e3:SetCondition(c49370016.drcon)
	e3:SetTarget(c49370016.drtg)
	e3:SetOperation(c49370016.drop)
	c:RegisterEffect(e3)
end
-- costfilter：作为①效果代价的筛选器，要求卡是「朋克」卡且可作为代价除外。
function c49370016.costfilter(c)
	return c:IsSetCard(0x171) and c:IsAbleToRemoveAsCost()
end
-- spcost：①效果的COST处理，从自己墓地选择1张符合costfilter的「朋克」卡，将其表侧表示除外作为发动代价。
function c49370016.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时（合法性检查）：确认自己墓地中存在至少1张可作为代价除外的「朋克」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c49370016.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，要求玩家选择要除外的卡（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张「朋克」卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c49370016.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡以表侧表示除外，作为效果的发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- spfilter：①效果可特殊召唤的怪兽筛选器，要求是「朋克」怪兽且能被效果特殊召唤。
function c49370016.spfilter(c,e,tp)
	return c:IsSetCard(0x171) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- sptg：①效果的发动目标阶段，检查自己场上是否有空位、手卡是否存在可特殊召唤的「朋克」怪兽。
function c49370016.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时：确认自己主要怪兽区域有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认手卡中存在至少1只可特殊召唤的「朋克」怪兽。
		and Duel.IsExistingMatchingCard(c49370016.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将把手卡的「朋克」怪兽特殊召唤（CATEGORY_SPECIAL_SUMMON），数量1，位置为手卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- spop：①效果处理时，选择手卡1只「朋克」怪兽表侧攻击表示特殊召唤到自己场上。
function c49370016.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查：若自己怪兽区域没有空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的怪兽（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足spfilter的「朋克」怪兽。
	local g=Duel.SelectMatchingCard(tp,c49370016.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的怪兽表侧攻击表示特殊召唤到自己的怪兽区域。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- drcon：②效果的发动条件，检测本次支付基本分的事件是否由自己场上的念动力族怪兽为发动效果而支付。
function c49370016.drcon(e,tp,eg,ep,ev,re,r,rp)
	if not (tp==ep and re and re:IsActivated() and re:GetActivateLocation()==LOCATION_MZONE) then return false end
	local rc=re:GetHandler()
	return rc:IsRelateToEffect(re) and rc:IsRace(RACE_PSYCHO)
		or not rc:IsRelateToEffect(re) and rc:GetPreviousRaceOnField()&RACE_PSYCHO~=0
end
-- drtg：②效果的发动目标阶段，确认自己可以抽卡，并设置抽卡数量和对象玩家。
function c49370016.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时：确认自己可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置本次抽卡的对象玩家为自己（tp）。
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本效果进行抽卡（CATEGORY_DRAW），数量1，抽卡玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- drop：②效果处理时，执行抽卡操作。
function c49370016.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设置的对象玩家p和抽卡数量d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p抽取d张卡，抽卡原因记为效果（REASON_EFFECT）。
	Duel.Draw(p,d,REASON_EFFECT)
end
