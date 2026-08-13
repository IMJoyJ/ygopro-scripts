--冥骸府－メメントラン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的「莫忘」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：自己场上的怪兽被战斗·效果破坏的场合，以那之内的1只为对象才能发动。比那只怪兽等级低的1只「莫忘」怪兽从自己的手卡·墓地特殊召唤。
-- ③：自己结束阶段，以自己墓地1张「莫忘」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化本卡效果：注册4个效果——e1为场地魔法得以发动的空效果；e2对应①的对方魔陷封印；e3对应②的破坏时从手卡·墓地特召「莫忘」；e4对应③的结束阶段从墓地盖放「莫忘」魔陷。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的「莫忘」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.lecon)
	-- 设置禁止对象：对方发动的效果若属于“魔法·陷阱卡的发动”（EFFECT_TYPE_ACTIVATE），则在该条件下不能发动。
	e2:SetValue(aux.TargetBoolFunction(Effect.IsHasType,EFFECT_TYPE_ACTIVATE))
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上的怪兽被战斗·效果破坏的场合，以那之内的1只为对象才能发动。比那只怪兽等级低的1只「莫忘」怪兽从自己的手卡·墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：自己结束阶段，以自己墓地1张「莫忘」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_SSET)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 过滤条件：该怪兽是自己场上表侧表示的「莫忘」怪兽（控制者为tp、表侧表示、属于0x1a1字段）。
function s.lfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x1a1)
end
-- ①效果的发动条件：自己的「莫忘」怪兽正在进行战斗，即攻击怪兽或攻击对象中有我方「莫忘」怪兽。
function s.lecon(e)
	-- 取得本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 取得本次战斗的攻击对象怪兽（可能没有）。
	local d=Duel.GetAttackTarget()
	local tp=e:GetHandlerPlayer()
	return a and s.lfilter(a,tp) or d and s.lfilter(d,tp)
end
-- ②效果的怪兽过滤：被破坏的怪兽必须曾是我方怪兽区的非衍生物、因战斗或效果被破坏、能成为效果对象、被破坏时为表侧表示、等级≥2，且手卡/墓地存在等级低于它的「莫忘」怪兽可供特殊召唤。
function s.cfilter(c,e,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and not c:IsType(TYPE_TOKEN)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsCanBeEffectTarget(e) and c:IsFaceupEx()
		-- 被破坏怪兽的等级必须≥2，并且手卡/墓地中必须有等级低于该怪兽的「莫忘」怪兽存在，否则②不能发动。
		and c:IsLevelAbove(2) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp,c:GetLevel())
end
-- 要特殊召唤的怪兽条件：是「莫忘」怪兽，等级低于被破坏怪兽的等级，且可以亲手牌或墓地特殊召唤。
function s.filter(c,e,tp,lv)
	return c:IsSetCard(0x1a1) and c:IsLevelBelow(lv-1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 若指定对象，确认该对象是本次被破坏的怪兽之一，且曾是我方怪兽区、因战斗/效果被破坏，以验证目标合法。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and chkc:IsPreviousControler(tp)
		and chkc:IsPreviousLocation(LOCATION_MZONE) and chkc:IsReason(REASON_BATTLE+REASON_EFFECT) end
	local g=eg:Filter(s.cfilter,nil,e,tp)
	-- 发动时点检查：自己场上怪兽区有空位，且存在至少1只满足过滤条件的被破坏怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	-- 给操作者显示选择对象的提示（“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:Select(tp,1,1,nil)
	-- 将选中的1只被破坏怪兽设置为当前连锁的效果对象。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：本次效果包含从手卡/墓地特殊召唤1只怪兽；由于特召对象在处理时选择，故targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ②效果处理：取得对象怪兽，若对象仍关联且怪兽区有空格，则从手牌/墓地选择1只等级更低的「莫忘」怪兽表侧特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得连锁处理的第1个对象，即被破坏的那只怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象已与效果失去关联，或自己场上没有空余怪兽区，则本次效果不处理。
	if not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择要特殊召唤的「莫忘」怪兽的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手牌/墓地选择1只满足s.filter的「莫忘」怪兽；同时用aux.NecroValleyFilter规避“王家长眠之谷”对墓地移动的限制。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp,tc:GetLevel())
	-- 将选中的「莫忘」怪兽表侧表示特殊召唤到自己场上（不检查召唤条件、不检查苏生限制）。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果的发动条件：必须是自己回合的结束阶段才能发动。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己，从而只在己方结束阶段触发③。
	return Duel.GetTurnPlayer()==tp
end
-- s.sfilter：自己墓地的「莫忘」魔法·陷阱卡，且满足可以盖放到场上的条件。
function s.sfilter(c)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ③效果的目标处理：确认墓地存在可盖放的「莫忘」魔陷，选择其中1张作为对象，并登记“卡片离开墓地”的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc) end
	-- 若自己墓地不存在满足条件的「莫忘」魔陷，则③不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择要盖放的卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地选择1张满足条件的「莫忘」魔陷设为效果对象。
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果会使1张卡从墓地离开（用于连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③效果处理：取得对象卡，若对象仍与效果关联，则将其在自己的场上里侧盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 对象仍与效果关联时，将其在自己的魔法与陷阱区里侧盖放（Duel.SSet）。
	if tc:IsRelateToEffect(e) then Duel.SSet(tp,tc) end
end
