--変異体ミュートリア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「秘异三变」卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把这张卡解放，从手卡·卡组把1张「秘异三变」卡除外才能发动。除外的卡种类的1只以下怪兽从手卡·卡组特殊召唤，自己失去那只怪兽的原本攻击力数值的基本分。
-- ●怪兽：「秘异三变猛兽」
-- ●魔法：「秘异三变秘法家」
-- ●陷阱：「秘异三变武装者」
function c26561172.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上有「秘异三变」卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,26561172)
	e1:SetCondition(c26561172.sscon)
	e1:SetTarget(c26561172.sstg)
	e1:SetOperation(c26561172.ssop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，从手卡·卡组把1张「秘异三变」卡除外才能发动。除外的卡种类的1只以下怪兽从手卡·卡组特殊召唤，自己失去那只怪兽的原本攻击力数值的基本分。●怪兽：「秘异三变猛兽」●魔法：「秘异三变秘法家」●陷阱：「秘异三变武装者」
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,26561173)
	e2:SetCost(c26561172.spcost)
	e2:SetTarget(c26561172.sptg)
	e2:SetOperation(c26561172.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：卡为表侧表示且属于「秘异三变」系列。
function c26561172.ssfilter(c)
	return c:IsSetCard(0x157) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上有表侧表示的「秘异三变」卡存在。
function c26561172.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1张表侧表示的「秘异三变」卡。
	return Duel.IsExistingMatchingCard(c26561172.ssfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①发动时点的合法性检查：自己主要怪兽区有空位，且这张卡可以被特殊召唤。
function c26561172.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：这次效果将把这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理：若这张卡仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c26561172.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤到自己场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：目标卡必须是指定卡号的「秘异三变」怪兽，且可以被效果特殊召唤。
function c26561172.spcostexcheckfilter(c,e,tp,code)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCode(code)
end
-- 根据所选代价卡的原始种类，检查对应种类的「秘异三变」怪兽是否在手卡·卡组中存在可特殊召唤的目标（不包括代价卡本身）。
function c26561172.spcostexcheck(c,e,tp)
	local result=false
	if c:GetOriginalType()&TYPE_MONSTER~=0 then
		-- 若作为代价的卡是怪兽，则检查手卡·卡组中是否存在「秘异三变猛兽」并可特殊召唤（排除该代价卡）。
		result=result or Duel.IsExistingMatchingCard(c26561172.spcostexcheckfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,34695290)
	end
	if c:GetOriginalType()&TYPE_SPELL~=0 then
		-- 若作为代价的卡是魔法，则检查手卡·卡组中是否存在「秘异三变秘法家」并可特殊召唤（排除该代价卡）。
		result=result or Duel.IsExistingMatchingCard(c26561172.spcostexcheckfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,61089209)
	end
	if c:GetOriginalType()&TYPE_TRAP~=0 then
		-- 若作为代价的卡是陷阱，则检查手卡·卡组中是否存在「秘异三变武装者」并可特殊召唤（排除该代价卡）。
		result=result or Duel.IsExistingMatchingCard(c26561172.spcostexcheckfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,7574904)
	end
	return result
end
-- 代价卡过滤：属于「秘异三变」系列、可作为代价除外，并且通过spcostexcheck确保能对应除外种类找到可特殊召唤的目标。
function c26561172.spcostfilter(c,e,tp)
	return c:IsSetCard(0x157) and c:IsAbleToRemoveAsCost() and c26561172.spcostexcheck(c,e,tp)
end
-- 效果②的代价：解放此卡，并从手卡·卡组选择1张「秘异三变」卡除外；将所选卡的原始种类存入效果标签，供后续处理使用。
function c26561172.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(100)
		-- 检查手卡·卡组中是否存在1张可作为代价且满足后续特殊召唤条件的「秘异三变」卡。
		return Duel.IsExistingMatchingCard(c26561172.spcostfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
			-- 同时确认此卡可以解放，且解放后自己场上仍有可用的怪兽区域。
			and e:GetHandler():IsReleasable() and Duel.GetMZoneCount(tp,e:GetHandler())>0
	end
	-- 解放此卡作为代价。
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 提示玩家选择要除外的卡（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从手卡·卡组中选出1张「秘异三变」卡作为代价。
	local cost=Duel.SelectMatchingCard(tp,c26561172.spcostfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	e:SetLabel(cost:GetOriginalType())
	-- 将选中的卡表侧除外，作为代价。
	Duel.Remove(cost,POS_FACEUP,REASON_COST)
end
-- 效果②发动合法性检查：通过效果标签确认代价检查已通过，然后登记特殊召唤操作信息。
function c26561172.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return true
	end
	-- 登记操作信息：将从手卡·卡组特殊召唤1只怪兽（怪兽在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤目标过滤：根据除外卡的原始种类筛选对应卡名的「秘异三变」怪兽，且该怪兽可以被效果特殊召唤。
function c26561172.spopfilter(c,e,tp,typ)
	return (((typ&TYPE_MONSTER)>0 and c:IsCode(34695290))
		or ((typ&TYPE_SPELL)>0 and c:IsCode(61089209))
		or ((typ&TYPE_TRAP)>0 and c:IsCode(7574904)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②处理：根据记录的除外种类，从手卡·卡组选1只对应怪兽特殊召唤；特殊召唤成功时，自己失去其原本攻击力数值的基本分。
function c26561172.spop(e,tp,eg,ep,ev,re,r,rp)
	local typ=e:GetLabel()
	-- 如果自己场上没有空余的怪兽区域，则不继续处理。
	if Duel.GetMZoneCount(tp)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1只符合条件的「秘异三变」怪兽。
	local tc=Duel.SelectMatchingCard(tp,c26561172.spopfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,typ):GetFirst()
	if not tc then return end
	local atk=tc:GetBaseAttack()
	-- 将选择的怪兽表侧表示特殊召唤到自己场上；若成功则继续处理LP损失。
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 自己的基本分减去该怪兽的原本攻击力数值。
		Duel.SetLP(tp,Duel.GetLP(tp)-atk)
	end
end
