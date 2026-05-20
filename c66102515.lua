--クリクリンク＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把自己场上1只「@火灵天星」怪兽解放才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：从额外卡组特殊召唤的电子界族怪兽在自己场上存在，自己场上的电子界族怪兽为对象的效果发动时，把这张卡解放才能发动。那个效果无效。
local s,id,o=GetID()
-- 注册卡片效果：①效果（手卡·墓地自由时点特召）和②效果（无效以场上电子界族为对象的效果）
function s.initial_effect(c)
	-- ①：自己·对方回合，把自己场上1只「@火灵天星」怪兽解放才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：从额外卡组特殊召唤的电子界族怪兽在自己场上存在，自己场上的电子界族怪兽为对象的效果发动时，把这张卡解放才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上可解放的「@火灵天星」怪兽，且解放后有空余怪兽区域
function s.rfilter(c,tp)
	-- 检查卡片是否为「@火灵天星」怪兽，且解放该卡后自己场上有可用于特殊召唤的怪兽区域，并且该卡由自己控制或在场上表侧表示
	return c:IsSetCard(0x135) and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- ①效果的发动代价：解放自己场上1只「@火灵天星」怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的「@火灵天星」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.rfilter,1,nil,tp) end
	-- 选择自己场上1只可解放的「@火灵天星」怪兽
	local g=Duel.SelectReleaseGroup(tp,s.rfilter,1,1,nil,tp)
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- ①效果的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：在连锁处理时将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的效果处理：将自身特殊召唤，并添加离场时除外的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍在原本区域、是否受王家之谷影响，并尝试将自身表侧表示特殊召唤
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤条件：从额外卡组特殊召唤的、自己场上表侧表示的电子界族怪兽
function s.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup()
		and c:IsRace(RACE_CYBERSE) and c:IsControler(tp)
end
-- 过滤条件：自己场上表侧表示的电子界族怪兽
function s.tfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
		and c:IsRace(RACE_CYBERSE) and c:IsControler(tp)
end
-- ②效果的发动条件：自己场上有额外卡组特召的电子界族怪兽存在，且对方发动了以自己场上电子界族怪兽为对象的效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查自己场上是否存在从额外卡组特殊召唤的表侧表示电子界族怪兽
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被作为效果对象的卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查效果对象中是否存在自己场上的表侧表示电子界族怪兽，且该效果的发动可以被无效
	return tg and tg:IsExists(s.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- ②效果的发动代价：将自身解放
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 将自身解放
	Duel.Release(c,REASON_COST)
end
-- ②效果的发动准备：设置无效效果的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：在连锁处理时使该效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果的效果处理：使该效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
