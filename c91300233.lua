--騎甲虫クルーエル・サターン
-- 效果：
-- 「骑甲虫」怪兽＋昆虫族怪兽
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1张「骑甲虫」卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
-- ③：昆虫族怪兽被表侧表示除外的场合，以除外的1只自己的「骑甲虫」怪兽为对象才能发动。那只怪兽特殊召唤。
function c91300233.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为1只「骑甲虫」怪兽和1只昆虫族怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x170),aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),true)
	-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1张「骑甲虫」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91300233,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,91300233)
	e1:SetTarget(c91300233.thtg)
	e1:SetOperation(c91300233.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己不是昆虫族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c91300233.splimit)
	c:RegisterEffect(e2)
	-- ③：昆虫族怪兽被表侧表示除外的场合，以除外的1只自己的「骑甲虫」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91300233,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,91300234)
	e3:SetCondition(c91300233.spcon)
	e3:SetTarget(c91300233.sptg)
	e3:SetOperation(c91300233.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可加入手牌的「骑甲虫」卡
function c91300233.thfilter(c)
	return c:IsSetCard(0x170) and c:IsAbleToHand()
end
-- 效果①（检索）的发动准备与合法性检测
function c91300233.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可加入手牌的「骑甲虫」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c91300233.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①（检索）的效果处理
function c91300233.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「骑甲虫」卡
	local g=Duel.SelectMatchingCard(tp,c91300233.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 限制自己不能特殊召唤昆虫族以外的怪兽
function c91300233.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT)
end
-- 过滤被表侧表示除外的昆虫族怪兽（包含在场上是昆虫族、除外后仍是昆虫族或原本是昆虫族的非衍生物怪兽）
function c91300233.ctfilter(c)
	local chk1=c:IsRace(RACE_INSECT) or c:GetPreviousRaceOnField()&RACE_INSECT~=0
	local chk2=c:IsType(TYPE_MONSTER) or c:GetPreviousTypeOnField()&TYPE_MONSTER~=0
	return not c:IsType(TYPE_TOKEN) and c:IsFaceup() and chk1 and chk2
end
-- 检查除外的卡中是否存在满足条件的表侧表示昆虫族怪兽，作为效果③的发动条件
function c91300233.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c91300233.ctfilter,1,nil)
end
-- 过滤除外状态下可特殊召唤的表侧表示「骑甲虫」怪兽
function c91300233.spfilter(c,e,tp)
	if c:IsFacedown() then return false end
	return c:IsSetCard(0x170) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③（特殊召唤除外怪兽）的发动准备、对象选择与合法性检测
function c91300233.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c91300233.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查除外区是否存在至少1只可以作为效果对象的「骑甲虫」怪兽
		and Duel.IsExistingTarget(c91300233.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外的1只「骑甲虫」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c91300233.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁处理信息，表示该效果会特殊召唤选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③（特殊召唤除外怪兽）的效果处理
function c91300233.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
