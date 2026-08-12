--風水魔神－ゲート・ガーディアン
-- 效果：
-- 「风魔神-修迦」＋「水魔神-斯迦」
-- 把自己场上的上记的卡除外的场合才能特殊召唤。这个卡名的①的效果1回合可以使用最多2次。
-- ①：对方把场上的魔法·陷阱卡的效果发动时才能发动（同一连锁上最多1次）。那个效果无效。
-- ②：特殊召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。自己的除外状态的1只「风魔神-修迦」或「水魔神-斯迦」特殊召唤。
function c61398234.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为卡号为62340868（风魔神-修迦）和98434877（水魔神-斯迦）的怪兽
	aux.AddFusionProcCode2(c,62340868,98434877,true,true)
	-- 添加接触融合召唤手续：将自己场上表侧表示的上述融合素材作为代价除外
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己场上的上记的卡除外的场合才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：对方把场上的魔法·陷阱卡的效果发动时才能发动（同一连锁上最多1次）。那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61398234,1))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(2,61398234)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c61398234.discon)
	e1:SetTarget(c61398234.distg)
	e1:SetOperation(c61398234.disop)
	c:RegisterEffect(e1)
	-- ②：特殊召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。自己的除外状态的1只「风魔神-修迦」或「水魔神-斯迦」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61398234,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c61398234.spcon)
	e2:SetTarget(c61398234.sptg)
	e2:SetOperation(c61398234.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：对方在场上发动魔法·陷阱卡的效果，且该效果可以被无效
function c61398234.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and ((re:GetActivateLocation()&LOCATION_ONFIELD)>0 or re:IsHasType(EFFECT_TYPE_ACTIVATE))
		-- 检查该连锁的效果是否可以被无效
		and Duel.IsChainDisablable(ev)
end
-- 效果①的发动准备：限制同一连锁只能发动1次，并设置无效效果的操作信息
function c61398234.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(61398234)==0 end
	c:RegisterFlagEffect(61398234,RESET_CHAIN,0,1)
	-- 设置操作信息，表示该效果的处理为使该发动效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果①的效果处理：使该连锁的效果无效
function c61398234.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使指定连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 效果②的发动条件：特殊召唤的表侧表示的这张卡因对方从自己场上离开
function c61398234.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 过滤函数：检索除外状态的、表侧表示的「风魔神-修迦」或「水魔神-斯迦」且能特殊召唤的怪兽
function c61398234.spfilter(c,e,tp)
	return c:IsCode(62340868,98434877) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查自己怪兽区域是否有空位，以及是否存在可特殊召唤的除外怪兽
function c61398234.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的除外状态中是否存在至少1只满足特殊召唤条件的「风魔神-修迦」或「水魔神-斯迦」
		and Duel.IsExistingMatchingCard(c61398234.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息，表示该效果的处理为从除外状态特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 效果②的效果处理：让玩家选择除外状态的1只「风魔神-修迦」或「水魔神-斯迦」特殊召唤到场上
function c61398234.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，如果自己场上没有可用的怪兽区域空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并让玩家选择1只除外状态的、满足条件的「风魔神-修迦」或「水魔神-斯迦」
	local g=Duel.SelectMatchingCard(tp,c61398234.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
