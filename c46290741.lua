--城塞クジラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把自己场上2只水属性怪兽解放才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组选1张「潜海奇袭」在自己场上盖放。
-- ③：1回合1次，只以自己场上的水属性怪兽1只为对象的魔法·陷阱·怪兽的效果由对方发动时才能发动。那个发动无效并破坏。
function c46290741.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在的场合，把自己场上2只水属性怪兽解放才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46290741,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,46290741)
	e1:SetCost(c46290741.spcost)
	e1:SetTarget(c46290741.sptg)
	e1:SetOperation(c46290741.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合才能发动。从卡组选1张「潜海奇袭」在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46290741,1))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c46290741.settg)
	e2:SetOperation(c46290741.setop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，只以自己场上的水属性怪兽1只为对象的魔法·陷阱·怪兽的效果由对方发动时才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46290741,2))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c46290741.discon)
	e3:SetTarget(c46290741.distg)
	e3:SetOperation(c46290741.disop)
	c:RegisterEffect(e3)
end
-- 筛选可解放的水属性怪兽：水属性且（为自己控制或表侧表示）。
function c46290741.rfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and (c:IsControler(tp) or c:IsFaceup())
end
-- ①效果的代价处理：从可解放候选组中选出2只水属性怪兽，并消耗相应代替解放次数后解放。
function c46290741.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家tp可解放的怪兽组，并过滤出满足rfilter条件的水属性怪兽。
	local rg=Duel.GetReleaseGroup(tp):Filter(c46290741.rfilter,nil,tp)
	-- 检查是否存在2只可解放的候选怪兽，使解放后仍有足够怪兽区域来特殊召唤这张卡。
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 向玩家显示选择要解放的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从候选组中选择2只满足条件的怪兽作为解放代价。
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 若使用了暗影敌托邦等代替解放效果，则消耗对应的额外解放次数。
	aux.UseExtraReleaseCount(g,tp)
	-- 将选中的2只怪兽解放（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- ①效果的目标判定：确认这张卡可以特殊召唤；并设置特殊召唤的操作信息。
function c46290741.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与该效果关联，则将其表侧表示特殊召唤。
function c46290741.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到持有者场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：卡名为「潜海奇袭」、属于魔法·陷阱卡且可以被盖放。
function c46290741.filter(c)
	return c:IsCode(19089195) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果发动条件：自己魔法与陷阱区域有空位，且卡组中存在符合条件的「潜海奇袭」。
function c46290741.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔法与陷阱区域是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在至少1张满足条件的「潜海奇袭」。
		and Duel.IsExistingMatchingCard(c46290741.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果处理：从卡组选择1张「潜海奇袭」盖放到自己魔法与陷阱区域。
function c46290741.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若魔法与陷阱区域没有空位，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 显示选择要盖放的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张符合条件的「潜海奇袭」。
	local g=Duel.SelectMatchingCard(tp,c46290741.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「潜海奇袭」盖放到自己的魔法与陷阱区域。
		Duel.SSet(tp,tc)
	end
end
-- 筛选条件：位于主要怪兽区域、水属性且控制者为tp的怪兽。
function c46290741.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsControler(tp)
end
-- ③效果发动条件：对方发动以自己场上1只水属性怪兽为对象的魔法·陷阱·怪兽效果，且该连锁可被无效；此卡未被战斗破坏。
function c46290741.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取对方发动的那次连锁的对象卡组。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象卡组仅有1张，且该卡为tp场上的水属性怪兽，且该连锁可以被无效。
	return tg and tg:GetCount()==1 and tg:IsExists(c46290741.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- ③效果发动判定：确认可发动；设定无效对方连锁，若其效果卡片可破坏且仍关联则同时设定破坏。
function c46290741.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方发动的效果无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏对方发动效果的那张卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ③效果处理：先无效对方连锁；若无效成功且效果卡仍关联，则将其破坏。
function c46290741.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果无效对方连锁成功，并且其效果发动卡仍与该效果有关联，则执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏对方发动效果的那张卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
