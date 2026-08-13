--六花のしらひめ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是植物族怪兽不能特殊召唤。
-- ②：自己场上有「六花」怪兽存在，对方把怪兽的效果发动时，让手卡·墓地的这张卡回到卡组，把自己场上1只植物族怪兽解放才能发动。那个发动的效果无效。
function c132308.initial_effect(c)
	-- ①：自己主要阶段才能发动。这张卡从手卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是植物族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,132308)
	e1:SetTarget(c132308.sptg)
	e1:SetOperation(c132308.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「六花」怪兽存在，对方把怪兽的效果发动时，让手卡·墓地的这张卡回到卡组，把自己场上1只植物族怪兽解放才能发动。那个发动的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,132309)
	e2:SetCondition(c132308.discon)
	e2:SetCost(c132308.discost)
	e2:SetTarget(c132308.distg)
	e2:SetOperation(c132308.disop)
	c:RegisterEffect(e2)
end
-- ①效果发动时的目标判定：仅在自己主要阶段，检查自己场上是否有怪兽区空格且这张卡能否被特殊召唤，满足才可发动。
function c132308.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格，作为从手卡特殊召唤的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本效果处理时将进行特殊召唤，对象为这张卡，数量1，供连锁中的其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：将此卡从手卡攻击表示特殊召唤；若成功，则在其在场期间赋予自肃效果——其控制者不能特殊召唤植物族以外的怪兽。
function c132308.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍与本次效果关联，若关联则将其表侧攻击表示特殊召唤；只有特殊召唤成功才继续添加自肃效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- ①中自肃部分：只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是植物族怪兽不能特殊召唤。②：自己场上有「六花」怪兽存在，对方把怪兽的效果发动时，让手卡·墓地的这张卡回到卡组，把自己场上1只植物族怪兽解放才能发动。那个发动的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c132308.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 自肃效果的过滤函数：当被特殊召唤的怪兽不是植物族时返回true，即禁止特殊召唤非植物族怪兽。
function c132308.splimit(e,c)
	return not c:IsRace(RACE_PLANT)
end
-- 过滤函数：判断场上是否存在表侧表示且卡名带有「六花」字段的怪兽。
function c132308.filter(c)
	return c:IsSetCard(0x141) and c:IsFaceup()
end
-- ②效果发动条件：对方发动怪兽效果且该效果能被无效，并且自己场上有表侧表示的「六花」怪兽。
function c132308.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁来源为对方（rp~=tp），且被连锁的效果是可以被无效的怪兽效果。
	return rp~=tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER)
		-- 检查自己场上是否存在至少1张表侧表示且属于「六花」字段的怪兽。
		and Duel.IsExistingMatchingCard(c132308.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 解放筛选函数：可选择自己场上的植物族怪兽，或受特定效果影响、可被自己用作解放的对方场上表侧表示怪兽。
function c132308.costfilter(c,tp)
	return (c:IsControler(tp) or c:IsFaceup())
		and (c:IsRace(RACE_PLANT) or c:IsHasEffect(76869711,tp) and c:IsControler(1-tp))
end
-- ②效果的代价处理：展示并让这张卡回到卡组洗切，然后从自己场上选择1只满足条件的植物族怪兽解放。
function c132308.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性：这张卡是否可以作为代价回到卡组，以及自己场上是否存在至少1只可解放的满足条件的植物族怪兽。
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() and Duel.CheckReleaseGroup(tp,c132308.costfilter,1,nil,tp) end
	-- 向对方玩家确认这张卡，使对方知道其作为代价返回卡组。
	Duel.ConfirmCards(1-tp,e:GetHandler())
	-- 将这张卡从手卡或墓地作为代价送回持有者卡组并洗牌。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
	-- 显示选择提示框，提示当前玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从自己场上选择1只满足costfilter条件的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c132308.costfilter,1,1,nil,tp)
	-- 将选中怪兽解放，完成代价支付。
	Duel.Release(g,REASON_COST)
end
-- ②效果的目标判定：无需指定对象；直接设置操作信息为无效效果，发动时无条件通过。
function c132308.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果将无效对象为eg（当前连锁中发动的怪兽效果），数量1，供其他效果参考。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果处理：直接无效对方发动的那个怪兽效果。
function c132308.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 令连锁编号ev对应的效果无效。
	Duel.NegateEffect(ev)
end
