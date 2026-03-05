--H・C サウザンド・ブレード
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，从手卡丢弃1张「英豪」卡才能发动。从卡组把1只「英豪」怪兽特殊召唤，这张卡变成守备表示。这个效果的发动后，直到回合结束时自己不是「英豪」怪兽不能特殊召唤。
-- ②：这张卡在墓地存在，战斗·效果让自己受到伤害时才能发动。这张卡攻击表示特殊召唤。
function c1833916.initial_effect(c)
	-- ①：1回合1次，从手卡丢弃1张「英豪」卡才能发动。从卡组把1只「英豪」怪兽特殊召唤，这张卡变成守备表示。这个效果的发动后，直到回合结束时自己不是「英豪」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1833916,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c1833916.spcon)
	e1:SetCost(c1833916.spcost)
	e1:SetTarget(c1833916.sptg)
	e1:SetOperation(c1833916.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，战斗·效果让自己受到伤害时才能发动。这张卡攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1833916,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,1833916)
	e2:SetCondition(c1833916.spcon2)
	e2:SetTarget(c1833916.sptg2)
	e2:SetOperation(c1833916.spop2)
	c:RegisterEffect(e2)
end
-- 效果发动时，自身必须处于攻击表示
function c1833916.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 过滤函数，用于判断手卡中是否存在可丢弃的「英豪」卡
function c1833916.cfilter(c)
	return c:IsSetCard(0x6f) and c:IsDiscardable()
end
-- 效果发动时，检查手卡是否存在至少1张「英豪」卡并将其丢弃
function c1833916.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在至少1张「英豪」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1833916.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡丢弃1张「英豪」卡作为效果代价
	Duel.DiscardHand(tp,c1833916.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于判断卡组中是否存在可特殊召唤的「英豪」怪兽
function c1833916.filter(c,e,tp)
	return c:IsSetCard(0x6f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时，检查卡组是否存在至少1只「英豪」怪兽
function c1833916.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在至少1只「英豪」怪兽
		and Duel.IsExistingMatchingCard(c1833916.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将要从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理，从卡组选择1只「英豪」怪兽特殊召唤，并将自身变为守备表示
function c1833916.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只「英豪」怪兽
		local g=Duel.SelectMatchingCard(tp,c1833916.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			if c:IsRelateToEffect(e) then
				-- 将自身变为守备表示
				Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
			end
		end
	end
	-- ①：1回合1次，从手卡丢弃1张「英豪」卡才能发动。从卡组把1只「英豪」怪兽特殊召唤，这张卡变成守备表示。这个效果的发动后，直到回合结束时自己不是「英豪」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c1833916.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果，使非「英豪」怪兽不能特殊召唤
function c1833916.splimit(e,c)
	return not c:IsSetCard(0x6f)
end
-- 效果发动时，确认伤害是由自己造成的
function c1833916.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 效果发动时，检查自己是否可以攻击表示特殊召唤
function c1833916.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置效果处理信息，表示将要特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理，将自身攻击表示特殊召唤
function c1833916.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身攻击表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
