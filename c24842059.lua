--リングリボー
-- 效果：
-- 4星以下的电子界族怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把陷阱卡发动时，把这张卡解放才能发动。那个效果无效并除外。
-- ②：这张卡在墓地存在的场合，把从额外卡组特殊召唤的自己场上1只「@火灵天星」怪兽解放才能发动。这张卡特殊召唤。这个效果在对方回合也能发动。
function c24842059.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用1张等级4以下且为电子界族的怪兽作为连接素材
	aux.AddLinkProcedure(c,c24842059.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：对方把陷阱卡发动时，把这张卡解放才能发动。那个效果无效并除外。
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
-- 过滤函数，用于筛选等级4以下且为电子界族的怪兽
function c24842059.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_CYBERSE)
end
-- 效果发动时的条件判断函数，判断是否满足无效并除外陷阱卡的条件
function c24842059.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家不为效果发动玩家，且发动的效果为陷阱卡的发动，且该效果为发动类型，且该连锁可以被无效
	return ep~=tp and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainDisablable(ev)
end
-- 效果发动时的解放费用支付函数，支付自身作为解放代价
function c24842059.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从场上解放作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置无效并除外陷阱卡效果的处理信息
function c24842059.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足无效并除外陷阱卡的条件
	if chk==0 then return aux.nbcon(tp,re) end
	-- 设置使效果无效的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置将陷阱卡除外的处理信息
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
	if re:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(e:GetCategory()|CATEGORY_GRAVE_ACTION)
	else
		e:SetCategory(e:GetCategory()&~CATEGORY_GRAVE_ACTION)
	end
end
-- 无效并除外陷阱卡效果的实际处理函数
function c24842059.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使效果无效且陷阱卡可以被除外
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将陷阱卡除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选从额外卡组特殊召唤的自己场上的「@火灵天星」怪兽
function c24842059.cfilter(c,tp)
	-- 该怪兽为「@火灵天星」卡组，且从额外卡组特殊召唤，且自己场上存在可用怪兽区
	return c:IsSetCard(0x135) and c:IsSummonLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤效果的解放费用支付函数，选择并解放符合条件的怪兽
function c24842059.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽可作为解放对象
	if chk==0 then return Duel.CheckReleaseGroup(tp,c24842059.cfilter,1,nil,tp) end
	-- 选择满足条件的怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c24842059.cfilter,1,1,nil,tp)
	-- 将选中的怪兽解放作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 设置特殊召唤效果的处理信息
function c24842059.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将卡片特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的实际处理函数
function c24842059.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
