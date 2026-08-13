--ズバババンチョー－GC
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上有「刷拉拉番长-我我我外套」以外的，「刷拉拉」怪兽或「我我我」怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：以自己墓地1只「隆隆隆」怪兽或「怒怒怒」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
function c23720856.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在，自己场上有「刷拉拉番长-我我我外套」以外的，「刷拉拉」怪兽或「我我我」怪兽存在的场合才能发动。这张卡特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：以自己墓地1只「隆隆隆」怪兽或「怒怒怒」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
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
-- 该过滤器用于判定场上是否存在符合条件的「刷拉拉」或「我我我」怪兽：表侧表示、属于这两个字段之一、且卡名不是「刷拉拉番长-我我我外套」自身。
function c23720856.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8f,0x54) and not c:IsCode(23720856)
end
-- ①效果的发动条件：检查自己场上是否存在至少1只满足cfilter条件的表侧表示「刷拉拉」或「我我我」怪兽（且不是本卡）。
function c23720856.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 返回“自己场上是否存在至少1只满足cfilter条件的表侧表示「刷拉拉」或「我我我」怪兽”的判定结果，作为发动①的许可条件。
	return Duel.IsExistingMatchingCard(c23720856.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动目标合法性检查：自己主要怪兽区有空闲空格，且这张卡在手牌可以被特殊召唤。
function c23720856.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在①效果发动合法性检查（chk==0）时，首先确认自己主要怪兽区存在可用的怪兽格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 在①效果发动时向系统登记操作信息：本次处理将进行特殊召唤，目标为这张卡，处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果保持关联（即效果发动后仍合法存在于手牌），则将其特殊召唤。
function c23720856.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上（按常规检查召唤条件及苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的墓地对象过滤：对象必须是「隆隆隆」或「怒怒怒」字段的怪兽，且能够被特殊召唤。
function c23720856.spfilter(c,e,tp)
	return c:IsSetCard(0x59,0x82) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标合法性检查：自己主要怪兽区有空位，且墓地存在至少1只满足spfilter的「隆隆隆」或「怒怒怒」怪兽可作为对象；若提供了对象候选chkc，则验证其是否位于自己墓地、由自己控制且满足spfilter条件。
function c23720856.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23720856.spfilter(chkc,e,tp) end
	-- 在②效果发动合法性检查（chk==0）时，首先确认自己主要怪兽区存在可用的怪兽格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地存在至少1只满足spfilter、可作为效果对象的「隆隆隆」或「怒怒怒」怪兽，满足②的取对象要求。
		and Duel.IsExistingTarget(c23720856.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向己方玩家弹出选择提示，提示信息为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 由己方玩家从自己墓地选择1只满足spfilter的怪兽作为效果对象，并将其登记为本次连锁的对象卡。
	local g=Duel.SelectTarget(tp,c23720856.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 在②效果发动时向系统登记操作信息：本次处理将把所选对象怪兽特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将对象怪兽特殊召唤到己方场上；然后给自己附加自肃效果——直到回合结束时，不能从额外卡组特殊召唤非超量怪兽。
function c23720856.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择并登记的墓地怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上（按常规检查召唤条件及苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c23720856.splimit)
	-- 将刚生成的附加自肃效果（不能从额外卡组特殊召唤非超量怪兽）注册给己方玩家，使其从即起到回合结束持续适用。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制的判定函数：若被检查的卡不是超量怪兽且位于额外卡组，则禁止该特殊召唤行为。
function c23720856.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
