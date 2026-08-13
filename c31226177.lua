--星杯竜イムドゥーク
-- 效果：
-- 衍生物以外的通常怪兽1只
-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「星杯」怪兽召唤。
-- ②：这张卡和这张卡所连接区的对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。
-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只「星杯」怪兽特殊召唤。
function c31226177.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：使用1只满足matfilter（衍生物以外的通常怪兽）作为连接素材。
	aux.AddLinkProcedure(c,c31226177.matfilter,1,1)
	-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「星杯」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31226177,2))  --"使用「星杯龙 伊姆杜克」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置可享受额外召唤次数的对象为持有「星杯」字段的卡（在手牌和主要怪兽区域中）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfd))
	c:RegisterEffect(e1)
	-- ②：这张卡和这张卡所连接区的对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31226177,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(c31226177.destg)
	e2:SetOperation(c31226177.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只「星杯」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31226177,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c31226177.spcon2)
	e3:SetTarget(c31226177.sptg2)
	e3:SetOperation(c31226177.spop2)
	c:RegisterEffect(e3)
end
-- 连接素材过滤函数：作为连接素材的怪兽必须为通常怪兽（以连接素材身份判定类型）且不是衍生物。
function c31226177.matfilter(c)
	return c:IsLinkType(TYPE_NORMAL) and not c:IsLinkType(TYPE_TOKEN)
end
-- 效果②的发动条件和对象判定：若这张卡存在战斗对象且该对象位于这张卡的连接区，则满足发动条件；同时将该战斗对象视为效果对象。
function c31226177.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and c:GetLinkedGroup():IsContains(bc) end
	-- 登记操作信息：本次连锁将破坏那只战斗对象（bc），破坏数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 效果②处理：获取战斗对象，若该对象仍与本次战斗关联（未离场、对象关系有效），则将其破坏。
function c31226177.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 以效果原因将那只对方怪兽破坏。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
-- 效果③的发动条件：这张卡的上一位置为场上，即确实是从场上送去墓地。
function c31226177.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤的候选过滤：手牌中的「星杯」怪兽，并且能够被玩家tp以效果e特殊召唤（同时检查召唤条件和苏生限制）。
function c31226177.spfilter2(c,e,tp)
	return c:IsSetCard(0xfd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动时点检测：自己主要怪兽区有空格，且手牌存在至少1只符合条件的「星杯」怪兽。
function c31226177.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区域是否存在空格（若没有空格则不能发动）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足spfilter2过滤条件的「星杯」怪兽。
		and Duel.IsExistingMatchingCard(c31226177.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将进行特殊召唤，来源为手牌，预计特殊召唤1只（不取对象，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果③处理流程：确认主怪兽区有空位后，提示玩家选择手牌中的「星杯」怪兽，并在选择后将其特殊召唤到自己场上。
function c31226177.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区仍有空格，若无空位则直接终止处理（不满足特殊召唤条件）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示消息，提示内容为“请选择要特殊召唤的卡”（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张满足spfilter2过滤条件的「星杯」怪兽（必选1张），作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c31226177.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（遵守召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
