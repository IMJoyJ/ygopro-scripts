--ズバババンチョー－GC
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上有「刷拉拉番长-我我我外套」以外的，「刷拉拉」怪兽或「我我我」怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：以自己墓地1只「隆隆隆」怪兽或「怒怒怒」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
function c23720856.initial_effect(c)
	-- ①：这张卡在手卡存在，自己场上有「刷拉拉番长-我我我外套」以外的，「刷拉拉」怪兽或「我我我」怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23720856,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,23720856)
	e1:SetCondition(c23720856.spcon1)
	e1:SetTarget(c23720856.sptg1)
	e1:SetOperation(c23720856.spop1)
	c:RegisterEffect(e1)
	-- ②：以自己墓地1只「隆隆隆」怪兽或「怒怒怒」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23720856,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,23720857)
	e2:SetTarget(c23720856.sptg2)
	e2:SetOperation(c23720856.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「刷拉拉」或「我我我」怪兽（不包括自身）
function c23720856.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8f,0x54) and not c:IsCode(23720856)
end
-- 效果条件函数，判断自己场上是否存在满足cfilter条件的怪兽
function c23720856.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足cfilter条件的卡
	return Duel.IsExistingMatchingCard(c23720856.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的处理函数，判断是否满足特殊召唤条件
function c23720856.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断自己场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果发动后将要处理的特殊召唤对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数，将自身特殊召唤到场上
function c23720856.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以特殊召唤方式送入场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断墓地中的怪兽是否为「隆隆隆」或「怒怒怒」怪兽
function c23720856.spfilter(c,e,tp)
	return c:IsSetCard(0x59,0x82) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，判断是否满足特殊召唤墓地怪兽的条件
function c23720856.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23720856.spfilter(chkc,e,tp) end
	-- 判断自己场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在至少1张满足spfilter条件的卡
		and Duel.IsExistingTarget(c23720856.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择一张满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c23720856.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果发动后将要处理的特殊召唤对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，将选中的墓地怪兽特殊召唤到场上，并设置回合结束时不能从额外卡组特殊召唤非超量怪兽的效果
function c23720856.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以特殊召唤方式送入场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建一个回合结束时重置的场地方效果，禁止玩家从额外卡组特殊召唤非超量怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c23720856.splimit)
	-- 将创建的效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 效果限制函数，判断目标怪兽是否为非超量怪兽且位于额外卡组
function c23720856.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
