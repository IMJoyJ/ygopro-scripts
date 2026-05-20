--ドドドドワーフ－GG
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只「刷拉拉」怪兽或「我我我」怪兽特殊召唤。
-- ②：这张卡在墓地存在，自己场上有「怒怒怒矮人-隆隆隆手套」以外的，「隆隆隆」怪兽或「怒怒怒」怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c59724555.initial_effect(c)
	-- ①：自己主要阶段才能发动。从手卡把1只「刷拉拉」怪兽或「我我我」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59724555,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,59724555)
	e1:SetTarget(c59724555.sptg1)
	e1:SetOperation(c59724555.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「怒怒怒矮人-隆隆隆手套」以外的，「隆隆隆」怪兽或「怒怒怒」怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59724555,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,59724556)
	e2:SetCondition(c59724555.spcon2)
	e2:SetTarget(c59724555.sptg2)
	e2:SetOperation(c59724555.spop2)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以特殊召唤的「刷拉拉」或「我我我」怪兽
function c59724555.spfilter(c,e,tp)
	return c:IsSetCard(0x8f,0x54) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件与效果目标检查函数
function c59724555.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c59724555.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的处理函数，从手卡特殊召唤1只「刷拉拉」或「我我我」怪兽
function c59724555.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c59724555.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示存在的「怒怒怒矮人-隆隆隆手套」以外的「隆隆隆」或「怒怒怒」怪兽
function c59724555.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x59,0x82) and not c:IsCode(59724555)
end
-- 效果②的发动条件检查函数
function c59724555.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c59724555.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动条件与效果目标检查函数
function c59724555.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的处理函数，将自身特殊召唤，并添加离场时除外的效果
function c59724555.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，并尝试将自身以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
