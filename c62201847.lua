--被検体ミュートリアM－05
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「被检体 秘异三变体M-05」以外的1只「秘异三变」怪兽加入手卡。
-- ②：把这张卡解放，把1张手卡或者自己场上的表侧表示的卡除外才能发动。除外的卡种类的1只以下怪兽从手卡·卡组特殊召唤。
-- ●怪兽：「秘异三变猛兽」
-- ●魔法：「秘异三变秘法家」
-- ●陷阱：「秘异三变武装者」
function c62201847.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「被检体 秘异三变体M-05」以外的1只「秘异三变」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62201847,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,62201847)
	e1:SetTarget(c62201847.thtg)
	e1:SetOperation(c62201847.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把这张卡解放，把1张手卡或者自己场上的表侧表示的卡除外才能发动。除外的卡种类的1只以下怪兽从手卡·卡组特殊召唤。●怪兽：「秘异三变猛兽」●魔法：「秘异三变秘法家」●陷阱：「秘异三变武装者」
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(62201847,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,62201848)
	e3:SetCost(c62201847.spcost)
	e3:SetTarget(c62201847.sptg)
	e3:SetOperation(c62201847.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中除「被检体 秘异三变体M-05」以外的「秘异三变」怪兽的过滤函数
function c62201847.thfilter(c)
	return c:IsSetCard(0x157) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(62201847)
end
-- 效果①（检索）的发动准备与目标确认函数
function c62201847.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「秘异三变」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c62201847.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①（检索）的效果处理函数
function c62201847.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「秘异三变」怪兽
	local g=Duel.SelectMatchingCard(tp,c62201847.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检查卡组或手卡中是否存在可以特殊召唤的指定卡号怪兽的过滤函数
function c62201847.spcostexcheckfilter(c,e,tp,code)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCode(code)
end
-- 根据作为Cost除外的卡的原始卡片种类，检查手卡或卡组中是否存在对应可特殊召唤的「秘异三变」怪兽
function c62201847.spcostexcheck(c,e,tp)
	local result=false
	if c:GetOriginalType()&TYPE_MONSTER~=0 then
		-- 若除外的卡原本是怪兽，则检查手卡·卡组是否存在「秘异三变猛兽」
		result=result or Duel.IsExistingMatchingCard(c62201847.spcostexcheckfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,34695290)
	end
	if c:GetOriginalType()&TYPE_SPELL~=0 then
		-- 若除外的卡原本是魔法卡，则检查手卡·卡组是否存在「秘异三变秘法家」
		result=result or Duel.IsExistingMatchingCard(c62201847.spcostexcheckfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,61089209)
	end
	if c:GetOriginalType()&TYPE_TRAP~=0 then
		-- 若除外的卡原本是陷阱卡，则检查手卡·卡组是否存在「秘异三变武装者」
		result=result or Duel.IsExistingMatchingCard(c62201847.spcostexcheckfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,7574904)
	end
	return result
end
-- 过滤作为Cost除外的卡片的过滤函数（需满足可除外、有对应可特召怪兽、且能腾出怪兽区域）
function c62201847.spcostfilter(c,e,tp,tc)
	local tg=Group.FromCards(c,tc)
	return c:IsAbleToRemoveAsCost() and c62201847.spcostexcheck(c,e,tp)
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		-- 检查在解放自身并除外1张卡后，是否仍有可用的怪兽区域用于特殊召唤
		and Duel.GetMZoneCount(tp,tg)>0
end
-- 效果②（特殊召唤）的发动代价（Cost）处理函数
function c62201847.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(100)
		-- 检查手卡或场上是否存在满足除外Cost条件的卡片
		return Duel.IsExistingMatchingCard(c62201847.spcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),e,tp,e:GetHandler())
			and e:GetHandler():IsReleasable()
	end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1张手卡或自己场上表侧表示的卡作为除外代价
	local cost=Duel.SelectMatchingCard(tp,c62201847.spcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler(),e,tp,e:GetHandler()):GetFirst()
	e:SetLabel(cost:GetOriginalType())
	-- 将选中的卡表侧表示除外作为发动的代价
	Duel.Remove(cost,POS_FACEUP,REASON_COST)
end
-- 效果②（特殊召唤）的发动准备与目标确认函数
function c62201847.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return true
	end
	-- 设置连锁处理中的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 根据除外卡的种类，过滤手卡或卡组中对应「秘异三变」怪兽的过滤函数
function c62201847.spopfilter(c,e,tp,typ)
	return (((typ&TYPE_MONSTER)>0 and c:IsCode(34695290))
		or ((typ&TYPE_SPELL)>0 and c:IsCode(61089209))
		or ((typ&TYPE_TRAP)>0 and c:IsCode(7574904)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（特殊召唤）的效果处理函数
function c62201847.spop(e,tp,eg,ep,ev,re,r,rp)
	local typ=e:GetLabel()
	-- 检查当前玩家场上是否有可用的怪兽区域，若无则结束处理
	if Duel.GetMZoneCount(tp)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的「秘异三变」怪兽
	local tc=Duel.SelectMatchingCard(tp,c62201847.spopfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,typ)
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
