--ヘル・ドラゴン
-- 效果：
-- ①：这张卡攻击的回合的结束阶段发动。这张卡破坏。
-- ②：场上的这张卡被破坏送去墓地时，把自己场上1只怪兽解放才能发动。这张卡从墓地特殊召唤。
function c47754278.initial_effect(c)
	-- 效果原文内容：①：这张卡攻击的回合的结束阶段发动。这张卡破坏。
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
	-- 效果原文内容：②：场上的这张卡被破坏送去墓地时，把自己场上1只怪兽解放才能发动。这张卡从墓地特殊召唤。
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
-- 规则层面作用：判断此卡是否在攻击回合中 announced 过攻击
function c47754278.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackAnnouncedCount()~=0
end
-- 规则层面作用：设置连锁操作信息为破坏效果
function c47754278.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置当前处理的连锁的操作信息为破坏此卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 规则层面作用：执行此卡的破坏效果
function c47754278.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：将此卡以效果原因破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 规则层面作用：判断此卡是否因破坏而送去墓地且之前在场上
function c47754278.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 规则层面作用：检查玩家是否能解放1只怪兽作为cost，并选择1只怪兽进行解放
function c47754278.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检测是否满足解放1只怪兽的条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 规则层面作用：从玩家场上选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 规则层面作用：将选中的怪兽以代價原因进行解放
	Duel.Release(g,REASON_COST)
end
-- 规则层面作用：判断此卡是否可以特殊召唤，检查是否有足够的场地空间和召唤条件
function c47754278.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检测场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面作用：设置当前处理的连锁的操作信息为特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面作用：执行此卡的特殊召唤效果
function c47754278.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 规则层面作用：将此卡以0方式、正面表示特殊召唤到玩家场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
