--変異体ミュートリア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「秘异三变」卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把这张卡解放，从手卡·卡组把1张「秘异三变」卡除外才能发动。除外的卡种类的1只以下怪兽从手卡·卡组特殊召唤，自己失去那只怪兽的原本攻击力数值的基本分。
-- ●怪兽：「秘异三变猛兽」
-- ●魔法：「秘异三变秘法家」
-- ●陷阱：「秘异三变武装者」
function c26561172.initial_effect(c)
	-- ①：自己场上有「秘异三变」卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,26561172)
	e1:SetCondition(c26561172.sscon)
	e1:SetTarget(c26561172.sstg)
	e1:SetOperation(c26561172.ssop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，从手卡·卡组把1张「秘异三变」卡除外才能发动。除外的卡种类的1只以下怪兽从手卡·卡组特殊召唤，自己失去那只怪兽的原本攻击力数值的基本分。
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
-- 过滤函数，用于检查场上是否存在「秘异三变」卡（正面表示）
function c26561172.ssfilter(c)
	return c:IsSetCard(0x157) and c:IsFaceup()
end
-- 效果条件函数，判断自己场上有「秘异三变」卡存在
function c26561172.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以自己来看场上是否存在至少1张「秘异三变」卡
	return Duel.IsExistingMatchingCard(c26561172.ssfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置特殊召唤的处理目标
function c26561172.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示将特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将卡片特殊召唤到场上
function c26561172.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片以正面表示的方式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于检查是否可以特殊召唤指定编号的卡
function c26561172.spcostexcheckfilter(c,e,tp,code)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCode(code)
end
-- 检查所选卡的种类是否满足特殊召唤条件
function c26561172.spcostexcheck(c,e,tp)
	local result=false
	if c:GetOriginalType()&TYPE_MONSTER~=0 then
		-- 检查是否存在可以特殊召唤的「秘异三变猛兽」
		result=result or Duel.IsExistingMatchingCard(c26561172.spcostexcheckfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,34695290)
	end
	if c:GetOriginalType()&TYPE_SPELL~=0 then
		-- 检查是否存在可以特殊召唤的「秘异三变秘法家」
		result=result or Duel.IsExistingMatchingCard(c26561172.spcostexcheckfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,61089209)
	end
	if c:GetOriginalType()&TYPE_TRAP~=0 then
		-- 检查是否存在可以特殊召唤的「秘异三变武装者」
		result=result or Duel.IsExistingMatchingCard(c26561172.spcostexcheckfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,7574904)
	end
	return result
end
-- 过滤函数，用于检查是否可以作为代价除外的「秘异三变」卡
function c26561172.spcostfilter(c,e,tp)
	return c:IsSetCard(0x157) and c:IsAbleToRemoveAsCost() and c26561172.spcostexcheck(c,e,tp)
end
-- 效果处理函数，发动效果时的处理流程
function c26561172.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(100)
		-- 检查自己手牌或卡组中是否存在可以作为代价除外的「秘异三变」卡
		return Duel.IsExistingMatchingCard(c26561172.spcostfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
			-- 检查自身是否可以被解放且自己场上是否有可用怪兽区域
			and e:GetHandler():IsReleasable() and Duel.GetMZoneCount(tp,e:GetHandler())>0
	end
	-- 将自身解放作为效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张可以除外的「秘异三变」卡
	local cost=Duel.SelectMatchingCard(tp,c26561172.spcostfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	e:SetLabel(cost:GetOriginalType())
	-- 将所选卡以正面表示的方式除外
	Duel.Remove(cost,POS_FACEUP,REASON_COST)
end
-- 设置特殊召唤的处理目标
function c26561172.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return true
	end
	-- 设置效果处理信息，表示将特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于检查是否可以特殊召唤指定类型的「秘异三变」卡
function c26561172.spopfilter(c,e,tp,typ)
	return (((typ&TYPE_MONSTER)>0 and c:IsCode(34695290))
		or ((typ&TYPE_SPELL)>0 and c:IsCode(61089209))
		or ((typ&TYPE_TRAP)>0 and c:IsCode(7574904)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数，发动效果时的处理流程
function c26561172.spop(e,tp,eg,ep,ev,re,r,rp)
	local typ=e:GetLabel()
	-- 检查自己场上是否有可用的怪兽区域
	if Duel.GetMZoneCount(tp)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一张可以特殊召唤的「秘异三变」卡
	local tc=Duel.SelectMatchingCard(tp,c26561172.spopfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,typ):GetFirst()
	if not tc then return end
	local atk=tc:GetBaseAttack()
	-- 将所选卡以正面表示的方式特殊召唤到场上
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 将玩家的基本分减去所特殊召唤怪兽的攻击力
		Duel.SetLP(tp,Duel.GetLP(tp)-atk)
	end
end
