--被検体ミュートリアST－46
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「秘异三变」魔法·陷阱卡加入手卡。
-- ②：把这张卡解放，把1张手卡或者自己场上的表侧表示的卡除外才能发动。除外的卡种类的1只以下怪兽从手卡·卡组特殊召唤。
-- ●怪兽：「秘异三变猛兽」
-- ●魔法：「秘异三变秘法家」
-- ●陷阱：「秘异三变武装者」
function c8200556.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「秘异三变」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8200556,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,8200556)
	e1:SetTarget(c8200556.thtg)
	e1:SetOperation(c8200556.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把这张卡解放，把1张手卡或者自己场上的表侧表示的卡除外才能发动。除外的卡种类的1只以下怪兽从手卡·卡组特殊召唤。●怪兽：「秘异三变猛兽」●魔法：「秘异三变秘法家」●陷阱：「秘异三变武装者」
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8200556,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,8200557)
	e3:SetCost(c8200556.spcost)
	e3:SetTarget(c8200556.sptg)
	e3:SetOperation(c8200556.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「秘异三变」魔法·陷阱卡且能加入手卡的过滤函数
function c8200556.thfilter(c)
	return c:IsSetCard(0x157) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动准备与合法性检测（Target）
function c8200556.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查卡组中是否存在至少1张满足条件的「秘异三变」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c8200556.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理（Operation）
function c8200556.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「秘异三变」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c8200556.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤手卡或卡组中可以特殊召唤的特定卡号怪兽的过滤函数
function c8200556.spcostexcheckfilter(c,e,tp,code)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCode(code)
end
-- 根据除外卡的原始卡片种类，检查手卡或卡组中是否存在可特殊召唤的对应「秘异三变」怪兽
function c8200556.spcostexcheck(c,e,tp)
	local result=false
	if c:GetOriginalType()&TYPE_MONSTER~=0 then
		-- 若除外的是怪兽，检查手卡·卡组是否存在可特殊召唤的「秘异三变猛兽」
		result=result or Duel.IsExistingMatchingCard(c8200556.spcostexcheckfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,34695290)
	end
	if c:GetOriginalType()&TYPE_SPELL~=0 then
		-- 若除外的是魔法，检查手卡·卡组是否存在可特殊召唤的「秘异三变秘法家」
		result=result or Duel.IsExistingMatchingCard(c8200556.spcostexcheckfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,61089209)
	end
	if c:GetOriginalType()&TYPE_TRAP~=0 then
		-- 若除外的是陷阱，检查手卡·卡组是否存在可特殊召唤的「秘异三变武装者」
		result=result or Duel.IsExistingMatchingCard(c8200556.spcostexcheckfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,7574904)
	end
	return result
end
-- 过滤作为cost除外的卡的过滤函数（需满足可除外、手卡或场上表侧、除外后有对应怪兽可特召、且能腾出怪兽区域）
function c8200556.spcostfilter(c,e,tp,tc)
	local tg=Group.FromCards(c,tc)
	return c:IsAbleToRemoveAsCost() and c8200556.spcostexcheck(c,e,tp)
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		-- 检查在解放自身并除外cost卡后，自己场上是否有可用于特殊召唤的怪兽区域
		and Duel.GetMZoneCount(tp,tg)>0
end
-- ②效果的发动代价（Cost）处理函数
function c8200556.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(100)
		-- 检查手卡或自己场上表侧表示是否存在至少1张可作为Cost除外的卡
		return Duel.IsExistingMatchingCard(c8200556.spcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),e,tp,e:GetHandler())
			and e:GetHandler():IsReleasable()
	end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1张手卡或自己场上表侧表示的卡作为除外代价
	local cost=Duel.SelectMatchingCard(tp,c8200556.spcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler(),e,tp,e:GetHandler()):GetFirst()
	e:SetLabel(cost:GetOriginalType())
	-- 将选择的卡表侧表示除外作为发动的代价
	Duel.Remove(cost,POS_FACEUP,REASON_COST)
end
-- ②效果的发动准备与合法性检测（Target）
function c8200556.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return true
	end
	-- 设置连锁处理的操作信息，表示该效果会特殊召唤卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤满足除外卡片种类且可特殊召唤的「秘异三变」怪兽的过滤函数
function c8200556.spopfilter(c,e,tp,typ)
	return (((typ&TYPE_MONSTER)>0 and c:IsCode(34695290))
		or ((typ&TYPE_SPELL)>0 and c:IsCode(61089209))
		or ((typ&TYPE_TRAP)>0 and c:IsCode(7574904)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的实际处理（Operation）
function c8200556.spop(e,tp,eg,ep,ev,re,r,rp)
	local typ=e:GetLabel()
	-- 检查自己场上是否有可用的怪兽区域，若无则直接结束处理
	if Duel.GetMZoneCount(tp)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组选择1只对应除外卡片种类的「秘异三变」怪兽
	local tc=Duel.SelectMatchingCard(tp,c8200556.spopfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,typ)
	if tc then
		-- 将选择的怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
