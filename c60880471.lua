--六花精ヘレボラス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「六花」怪兽存在，自己场上的怪兽为对象的怪兽的效果由对方发动时，把手卡·场上的这张卡解放才能发动。那个效果无效。
-- ②：这张卡在墓地存在的场合，把自己场上1只植物族怪兽解放才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c60880471.initial_effect(c)
	-- ①：自己场上有「六花」怪兽存在，自己场上的怪兽为对象的怪兽的效果由对方发动时，把手卡·场上的这张卡解放才能发动。那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60880471,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCountLimit(1,60880471)
	e1:SetCondition(c60880471.discon)
	e1:SetCost(c60880471.discost)
	e1:SetTarget(c60880471.distg)
	e1:SetOperation(c60880471.disop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把自己场上1只植物族怪兽解放才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60880471,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,60880472)
	e2:SetCost(c60880471.spcost)
	e2:SetTarget(c60880471.sptg)
	e2:SetOperation(c60880471.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示且属于「六花」系列（SetCard 0x141）。
function c60880471.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x141)
end
-- 过滤函数：判断卡片是否位于怪兽区且为我方控制，用于确认连锁对象中存在我方场上的怪兽。
function c60880471.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- ①效果的发动条件：必须是由对方发动的取对象怪兽效果，且该效果以我方场上的怪兽为对象；这张卡不能处于战斗破坏确定状态；自己场上须有表侧「六花」怪兽；该连锁效果必须可以被无效。
function c60880471.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not re:IsActiveType(TYPE_MONSTER) then return false end
	-- 获取当前连锁的效果所取的对象卡集合。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查自己场上是否存在至少1只表侧表示且属于「六花」系列的怪兽。
	if not Duel.IsExistingMatchingCard(c60880471.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 确认连锁的对象卡集合中存在我方场上怪兽，且该连锁效果可被无效。
	return tg and tg:IsExists(c60880471.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- ①效果的代价：将手牌或场上的这张卡解放才能发动（此处检查这张卡是否可解放并执行解放）。
function c60880471.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ①效果的发动目标设定：效果不需要选择对象，处理时无效对方发动的效果，并登记操作信息。
function c60880471.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记该效果将无效那个发动效果（CATEGORY_DISABLE），目标为正在连锁的效果卡。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ①效果的处理：使符合条件的那个连锁效果无效。
function c60880471.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效编号为ev的连锁效果。
	Duel.NegateEffect(ev)
end
-- ②效果解放的过滤函数：选择自己场上可解放的植物族怪兽，要求解放后自己仍有可用怪兽区（额外处理某些效果允许的对方怪兽）。
function c60880471.spfilter(c,tp)
	-- 解放该怪兽后自己场上仍存在可用的怪兽区，且该卡为自己场上的卡（或满足条件的表侧卡）。
	return (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
		and (c:IsRace(RACE_PLANT) or c:IsHasEffect(76869711,tp) and c:IsControler(1-tp))
end
-- ②效果的代价：解放自己场上1只符合条件的植物族怪兽才能发动，这里选择并解放。
function c60880471.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足spfilter的可解放的植物族怪兽作为代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c60880471.spfilter,1,nil,tp) end
	-- 选择自己场上1只满足spfilter的植物族怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c60880471.spfilter,1,1,nil,tp)
	-- 将选择的植物族怪兽解放作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- ②效果的发动目标：检查墓地中的这张卡能否以表侧守备表示特殊召唤，并登记特殊召唤操作信息。
function c60880471.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 登记该效果将特殊召唤墓地中的这张卡（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，将其守备表示特殊召唤；成功后，给它附加“离场时除外”的永续效果。
function c60880471.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤，成功时进入后续处理。
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
		end
	end
end
