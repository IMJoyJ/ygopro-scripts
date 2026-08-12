--星杯竜イムドゥーク
-- 效果：
-- 衍生物以外的通常怪兽1只
-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「星杯」怪兽召唤。
-- ②：这张卡和这张卡所连接区的对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。
-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只「星杯」怪兽特殊召唤。
function c31226177.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用1到1个满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,c31226177.matfilter,1,1)
	-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「星杯」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31226177,2))  --"使用「星杯龙 伊姆杜克」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置效果目标为「星杯」卡
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
-- 连接素材过滤函数，要求是通常怪兽且不是衍生物
function c31226177.matfilter(c)
	return c:IsLinkType(TYPE_NORMAL) and not c:IsLinkType(TYPE_TOKEN)
end
-- 战斗破坏效果的发动时点处理函数，检查是否满足发动条件
function c31226177.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and c:GetLinkedGroup():IsContains(bc) end
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 战斗破坏效果的处理函数，执行破坏操作
function c31226177.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 执行破坏操作，原因来自效果
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
-- 特殊召唤效果的发动条件函数，检查卡片是否从场上送去墓地
function c31226177.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤卡片的过滤函数，检查是否为「星杯」卡且可以特殊召唤
function c31226177.spfilter2(c,e,tp)
	return c:IsSetCard(0xfd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标设定函数，检查是否有满足条件的卡可以特殊召唤
function c31226177.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的「星杯」怪兽
		and Duel.IsExistingMatchingCard(c31226177.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的处理函数，选择并特殊召唤卡片
function c31226177.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的特殊召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择满足条件的「星杯」怪兽
	local g=Duel.SelectMatchingCard(tp,c31226177.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡片特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
