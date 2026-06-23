--憑依解放
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己的「灵使」怪兽不会被战斗破坏。
-- ②：自己的「凭依装着」怪兽的攻击力只在向对方怪兽攻击的伤害计算时上升800。
-- ③：这张卡在魔法与陷阱区域存在的状态，自己场上的怪兽被战斗·效果破坏的场合才能发动。原本属性和那之内的1只不同的1只守备力1500的魔法师族怪兽从卡组表侧攻击表示或里侧守备表示特殊召唤。
function c25704359.initial_effect(c)
	-- ①：自己的「灵使」怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前发动或适用。
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ②：自己的「凭依装着」怪兽的攻击力只在向对方怪兽攻击的伤害计算时上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 筛选「凭依装着」怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xbf))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡在魔法与陷阱区域存在的状态，自己场上的怪兽被战斗·效果破坏的场合才能发动。原本属性和那之内的1只不同的1只守备力1500的魔法师族怪兽从卡组表侧攻击表示或里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c25704359.atktg)
	e3:SetCondition(c25704359.atkcon)
	e3:SetValue(800)
	c:RegisterEffect(e3)
	-- 检索满足条件的魔法师族怪兽组。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,25704359)
	e4:SetCondition(c25704359.spcon)
	e4:SetTarget(c25704359.sptg)
	e4:SetOperation(c25704359.spop)
	c:RegisterEffect(e4)
end
-- 筛选「凭依装着」怪兽。
function c25704359.atktg(e,c)
	-- 该怪兽必须是攻击怪兽。
	return c:IsSetCard(0x10c0) and Duel.GetAttacker()==c
end
-- 判断是否处于伤害计算阶段。
function c25704359.atkcon(e)
	-- 当前阶段为伤害计算阶段且存在攻击对象。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()~=nil
end
-- 过滤被战斗或效果破坏的怪兽。
function c25704359.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:GetOriginalAttribute()~=0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 满足发动条件：有被破坏的怪兽且此卡处于启用状态。
function c25704359.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25704359.cfilter,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 筛选满足条件的魔法师族怪兽。
function c25704359.spfilter(c,e,tp,att)
	return c:IsRace(RACE_SPELLCASTER) and c:IsDefense(1500) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 检查是否有满足条件的怪兽可特殊召唤。
function c25704359.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查场上是否有特殊召唤空间。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		local g=eg:Filter(c25704359.cfilter,nil,tp)
		local att=ATTRIBUTE_ALL
		local tc=g:GetFirst()
		while tc do
			att=bit.band(att,tc:GetOriginalAttribute())
			tc=g:GetNext()
		end
		att=ATTRIBUTE_ALL&~att
		e:SetLabel(att)
		-- 检查卡组中是否存在满足条件的怪兽。
		return Duel.IsExistingMatchingCard(c25704359.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,att)
	end
	-- 设置操作信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作。
function c25704359.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有特殊召唤空间。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c25704359.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	local tc=g:GetFirst()
	if tc then
		-- 特殊召唤选定的怪兽并确认其为里侧表示时的处理。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
			-- 向对方确认特殊召唤的怪兽。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
