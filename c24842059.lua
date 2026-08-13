--リングリボー
-- 效果：
-- 4星以下的电子界族怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把陷阱卡发动时，把这张卡解放才能发动。那个效果无效并除外。
-- ②：这张卡在墓地存在的场合，把从额外卡组特殊召唤的自己场上1只「@火灵天星」怪兽解放才能发动。这张卡特殊召唤。这个效果在对方回合也能发动。
function c24842059.initial_effect(c)
	-- 为这张卡添加连接召唤手续，素材为1只满足c24842059.mfilter的怪兽，即4星以下的电子界族怪兽1只。
	aux.AddLinkProcedure(c,c24842059.mfilter,1,1)
	c:EnableReviveLimit()
	-- 4星以下的电子界族怪兽1只，这个卡名的①②的效果1回合各能使用1次。①：对方把陷阱卡发动时，把这张卡解放才能发动。那个效果无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24842059,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,24842059)
	e1:SetCondition(c24842059.discon)
	e1:SetCost(c24842059.discost)
	e1:SetTarget(c24842059.distg)
	e1:SetOperation(c24842059.disop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把从额外卡组特殊召唤的自己场上1只「@火灵天星」怪兽解放才能发动。这张卡特殊召唤。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24842059,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,24842060)
	e2:SetCost(c24842059.spcost)
	e2:SetTarget(c24842059.sptg)
	e2:SetOperation(c24842059.spop)
	c:RegisterEffect(e2)
end
-- 连接素材的过滤条件：怪兽必须为4星以下且种族为电子界族，即只能用4星以下的电子界族怪兽作为连接素材。
function c24842059.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_CYBERSE)
end
-- ①效果的发动条件判定：对方发动陷阱卡（发动者为对方、卡片为陷阱卡且是陷阱卡片的发动），且该连锁效果可以被无效时，条件成立。
function c24842059.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否满足“对方发动陷阱卡且该效果可被无效”：对方是发动者、发动的是陷阱卡且是卡片发动、该连锁效果能被无效。
	return ep~=tp and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainDisablable(ev)
end
-- ①效果的发动代价处理：先检查这张卡自身是否可以解放，若可以则把这张卡解放作为代价。
function c24842059.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以解放这张卡自身作为发动代价，将其解放。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ①效果发动时的目标处理：确认能够无效并除外对方发动的陷阱卡效果；将连锁中的该效果设为无效对象，若其发动卡仍与效果关联则同时设为除外对象；并根据该陷阱卡发动时所在位置动态调整效果分类（墓地发动则追加墓地相关操作分类）。
function c24842059.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认对方发动的该效果能够被“无效并除外”，且满足相关除外操作条件，才可发动。
	if chk==0 then return aux.nbcon(tp,re) end
	-- 将处于当前连锁的对方发动效果设为“无效”操作的对象，数量为1，用于后续无效处理及触发相关联动。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 将处于当前连锁的对方发动效果对应的卡设为“除外”操作的对象，数量为1，用于后续除外处理及触发相关联动。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
	if re:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(e:GetCategory()|CATEGORY_GRAVE_ACTION)
	else
		e:SetCategory(e:GetCategory()&~CATEGORY_GRAVE_ACTION)
	end
end
-- ①效果的实际处理：先无效对方发动的陷阱卡效果；若该陷阱卡仍与那个效果关联，则将其表侧表示除外。
function c24842059.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定对方连锁中的效果是否被成功无效，且该效果的发动卡仍与效果关联（仍可被除外）；两者同时满足时继续执行除外操作。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的那张陷阱卡以表侧表示除外（理由为效果）。
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的解放素材过滤条件：必须是「@火灵天星」怪兽、从额外卡组特殊召唤到过自己场上，并且解放后自己场上仍有主要怪兽区空位可供这张卡特殊召唤。
function c24842059.cfilter(c,tp)
	-- 判断某怪兽是否可作②效果的解放素材：属于「@火灵天星」系列、是从额外卡组特殊召唤的怪兽，且解放后自己有可用怪兽区域。
	return c:IsSetCard(0x135) and c:IsSummonLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的发动代价：从自己场上选择1只满足条件的「@火灵天星」怪兽解放；先确认存在可解放素材，再选择并解放。
function c24842059.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认自己场上存在至少1只满足cfilter条件且可解放的「@火灵天星」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c24842059.cfilter,1,nil,tp) end
	-- 选择自己场上1只满足cfilter条件的「@火灵天星」怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c24842059.cfilter,1,1,nil,tp)
	-- 将选择的那只「@火灵天星」怪兽作为代价解放。
	Duel.Release(g,REASON_COST)
end
-- ②效果的目标处理：检查墓地中的这张卡能否以通常特殊召唤手续被特殊召唤；可以则把这张卡设定为特殊召唤对象。
function c24842059.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将这张卡本身标记为特殊召唤操作的对象，数量为1，用于后续特殊召唤及触发相关效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的实际处理：若这张卡仍在墓地且与该效果关联，则将其以表侧表示特殊召唤到自己场上。
function c24842059.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上（不跳过召唤条件与苏生限制的检查）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
