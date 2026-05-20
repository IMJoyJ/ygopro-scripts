--ティアラメンツ・ルルカロス
-- 效果：
-- 「珠泪哀歌族·水仙女人鱼」＋「珠泪哀歌族」怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡以外的自己的水族怪兽不会被战斗破坏。
-- ②：包含把怪兽特殊召唤效果的效果由对方发动时才能发动。那个发动无效并破坏。那之后，从手卡以及自己场上的表侧表示的卡之中选1张「珠泪哀歌族」卡送去墓地。
-- ③：融合召唤的这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤。
function c84330567.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：以1只「珠泪哀歌族·水仙女人鱼」和1只「珠泪哀歌族」怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,92731385,aux.FilterBoolFunction(Card.IsFusionSetCard,0x181),1,true,true)
	-- ①：这张卡以外的自己的水族怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c84330567.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：包含把怪兽特殊召唤效果的效果由对方发动时才能发动。那个发动无效并破坏。那之后，从手卡以及自己场上的表侧表示的卡之中选1张「珠泪哀歌族」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84330567,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,84330567)
	e2:SetCondition(c84330567.discon)
	e2:SetTarget(c84330567.distg)
	e2:SetOperation(c84330567.disop)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84330567,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,84330568)
	e3:SetCondition(c84330567.spcon)
	e3:SetTarget(c84330567.sptg)
	e3:SetOperation(c84330567.spop)
	c:RegisterEffect(e3)
end
-- 过滤自身以外的己方场上的水族怪兽，作为不会被战斗破坏效果的目标
function c84330567.indtg(e,c)
	return c:IsRace(RACE_AQUA) and c~=e:GetHandler()
end
-- 检查无效效果的发动条件：对方发动了包含特殊召唤效果的效果，且此卡未被战斗破坏
function c84330567.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 若此卡已被战斗破坏，或者该连锁的发动无法被无效，则不满足发动条件
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and ep~=tp
end
-- 过滤手卡或自己场上表侧表示的、可以送去墓地的「珠泪哀歌族」卡
function c84330567.tgfilter(c)
	return c:IsSetCard(0x181) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGrave()
end
-- 检查效果发动的可行性，并设置无效、破坏以及送去墓地的操作信息
function c84330567.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或自己场上表侧表示的卡中是否存在至少1张可以送去墓地的「珠泪哀歌族」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c84330567.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该发动效果的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 设置操作信息：从手卡或场上将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end
-- 执行无效并破坏的操作，之后让玩家选择手卡或场上表侧表示的1张「珠泪哀歌族」卡送去墓地
function c84330567.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡存在于对应连锁中，则将其破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 给玩家发送提示信息，要求选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家选择手卡或场上表侧表示的1张「珠泪哀歌族」卡
		local g=Duel.SelectMatchingCard(tp,c84330567.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		if #g>0 then
			-- 中断当前效果处理，使后续的送去墓地处理与前面的无效破坏不视为同时进行
			Duel.BreakEffect()
			-- 将选中的卡因效果送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 检查特殊召唤效果的发动条件：融合召唤的此卡因效果从怪兽区域送去墓地
function c84330567.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检查特殊召唤效果的可行性，并设置特殊召唤的操作信息
function c84330567.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作，将此卡在自己场上特殊召唤
function c84330567.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
