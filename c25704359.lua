--憑依解放
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己的「灵使」怪兽不会被战斗破坏。
-- ②：自己的「凭依装着」怪兽的攻击力只在向对方怪兽攻击的伤害计算时上升800。
-- ③：这张卡在魔法与陷阱区域存在的状态，自己场上的怪兽被战斗·效果破坏的场合才能发动。原本属性和那之内的1只不同的1只守备力1500的魔法师族怪兽从卡组表侧攻击表示或里侧守备表示特殊召唤。
function c25704359.initial_effect(c)
	-- 这张卡的发动（可在伤害步骤发动）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制只能在伤害步骤且尚未进行伤害计算时发动
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ①：自己的「灵使」怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 筛选自己场上持有「灵使」字段的怪兽作为此效果的适用对象
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xbf))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：自己的「凭依装着」怪兽的攻击力只在向对方怪兽攻击的伤害计算时上升800。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c25704359.atktg)
	e3:SetCondition(c25704359.atkcon)
	e3:SetValue(800)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡在魔法与陷阱区域存在的状态，自己场上的怪兽被战斗·效果破坏的场合才能发动。原本属性和那之内的1只不同的1只守备力1500的魔法师族怪兽从卡组表侧攻击表示或里侧守备表示特殊召唤。
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
-- 判断效果适用对象：这张卡持有「凭依装着」字段，并且是正在攻击的怪兽
function c25704359.atktg(e,c)
	-- 该怪兽满足「凭依装着」字段且为攻击怪兽
	return c:IsSetCard(0x10c0) and Duel.GetAttacker()==c
end
-- 判断效果适用条件：处于伤害计算阶段且存在攻击对象（即正在向对方怪兽攻击）
function c25704359.atkcon(e)
	-- 当前阶段为伤害计算且攻击目标不为空（即攻击对象是怪兽而非直接攻击）
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()~=nil
end
-- 筛选本次被破坏的怪兽：破坏原因是战斗或效果，原本属性不为0，破坏前在主要怪兽区且控制者是自己
function c25704359.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:GetOriginalAttribute()~=0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 满足条件的被破坏怪兽存在，且这张卡在场上效果有效时才能发动（对应③的发动条件）
function c25704359.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25704359.cfilter,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 筛选卡组中符合条件的魔法师族怪兽：种族为魔法师、守备力1500、属性为指定属性（与被破坏怪兽原本属性不同），且可以被特殊召唤为表侧攻击或里侧守备表示
function c25704359.spfilter(c,e,tp,att)
	return c:IsRace(RACE_SPELLCASTER) and c:IsDefense(1500) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- ③效果发动时的目标处理：确认自己主要怪兽区有空位；计算被破坏怪兽的原本属性的公共集合的反集（即与被破坏怪兽属性都不同的属性）并保存；检查卡组是否存在符合条件的怪兽。满足则设置特殊召唤的操作信息
function c25704359.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若自己场上没有可用的主要怪兽区空格，则无法发动
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
		-- 检查卡组中是否存在满足条件的魔法师族怪兽
		return Duel.IsExistingMatchingCard(c25704359.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,att)
	end
	-- 向系统登记特殊召唤的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：若仍有空格，提示玩家选择卡组中符合条件的怪兽，将其特殊召唤为表侧攻击表示或里侧守备表示；若特殊召唤成功且为里侧守备表示，则向对方确认那张卡
function c25704359.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若没有可用的主要怪兽区空格，则终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张符合条件的魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,c25704359.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	local tc=g:GetFirst()
	if tc then
		-- 特殊召唤成功且该卡以里侧守备表示在场时，进行后续处理
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
			-- 向对方玩家确认以里侧守备表示特殊召唤的这张卡
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
