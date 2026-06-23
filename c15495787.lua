--超重武者ココロガマ－A
-- 效果：
-- 自己墓地有魔法·陷阱卡存在的场合，这张卡不能召唤·反转召唤。
-- ①：自己墓地没有魔法·陷阱卡存在，自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡在这个回合不会被战斗·效果破坏。
function c15495787.initial_effect(c)
	-- 自己墓地有魔法·陷阱卡存在的场合，这张卡不能召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c15495787.sumcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- ①：自己墓地没有魔法·陷阱卡存在，自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡在这个回合不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15495787,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_HAND)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c15495787.spcon)
	e3:SetTarget(c15495787.sptg)
	e3:SetOperation(c15495787.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断墓地是否存在魔法或陷阱卡
function c15495787.sfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断自己墓地是否存在魔法或陷阱卡
function c15495787.sumcon(e)
	-- 检查自己墓地是否存在至少1张魔法或陷阱卡
	return Duel.IsExistingMatchingCard(c15495787.sfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
-- 判断是否为自己的战斗伤害且墓地无魔法陷阱卡
function c15495787.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and not c15495787.sumcon(e)
end
-- 设置特殊召唤的处理目标和条件
function c15495787.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若自己墓地存在魔法或陷阱卡则不能发动此效果
	if Duel.IsExistingMatchingCard(c15495787.sfilter,tp,LOCATION_GRAVE,0,1,nil) then return false end
	-- 检查场上是否有足够空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤并赋予其不被破坏效果
function c15495787.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，成功则继续赋予不被破坏效果
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使特殊召唤的这张卡在战斗中不会被破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		c:RegisterEffect(e2)
	end
end
