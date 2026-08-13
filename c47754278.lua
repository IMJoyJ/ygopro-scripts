--ヘル・ドラゴン
-- 效果：
-- ①：这张卡攻击的回合的结束阶段发动。这张卡破坏。
-- ②：场上的这张卡被破坏送去墓地时，把自己场上1只怪兽解放才能发动。这张卡从墓地特殊召唤。
function c47754278.initial_effect(c)
	-- ①：这张卡攻击的回合的结束阶段发动。这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47754278,0))  --"破坏"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c47754278.descon)
	e1:SetTarget(c47754278.destg)
	e1:SetOperation(c47754278.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被破坏送去墓地时，把自己场上1只怪兽解放才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47754278,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c47754278.spcon)
	e2:SetCost(c47754278.spcost)
	e2:SetTarget(c47754278.sptg)
	e2:SetOperation(c47754278.spop)
	c:RegisterEffect(e2)
end
-- 判断条件：本回合这张卡进行过攻击宣言（攻击过）。
function c47754278.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackAnnouncedCount()~=0
end
-- 目标判定函数：效果发动时无需选择对象，直接设置将这张卡破坏的操作信息。
function c47754278.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果将以效果原因破坏这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理函数：以效果原因破坏这张卡。
function c47754278.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏这张卡。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 特殊召唤的诱发条件：这张卡因被破坏而送去墓地，且被破坏前位于场上。
function c47754278.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 代价函数：从自己场上解放1只怪兽作为发动代价。
function c47754278.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否满足解放代价：自己场上有至少1只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只可解放的怪兽作为代价。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选择的怪兽解放（作为发动代价）。
	Duel.Release(g,REASON_COST)
end
-- 目标判定函数：确认特殊召唤的合法性（发动时允许无空位，并检查这张卡能否被特殊召唤），并设置特殊召唤的操作信息。
function c47754278.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区（此处为宽松判定，允许发动时无空位，效果处理时再确认），且这张卡能被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将对这张卡进行特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：若这张卡仍与该效果关联（尚未离开墓地等），将其特殊召唤到自己场上。
function c47754278.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
