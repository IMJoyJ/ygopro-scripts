--破械童子アルハ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张卡为对象才能发动。那张卡破坏，这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
-- ②：场上的这张卡被战斗或者「破械童子 阿罗汉」以外的卡的效果破坏的场合才能发动。从手卡·卡组把「破械童子 阿罗汉」以外的1只「破械」怪兽特殊召唤。
function c26236560.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在的场合，以自己场上1张卡为对象才能发动。那张卡破坏，这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26236560,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,26236560)
	e1:SetTarget(c26236560.destg)
	e1:SetOperation(c26236560.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗或者「破械童子 阿罗汉」以外的卡的效果破坏的场合才能发动。从手卡·卡组把「破械童子 阿罗汉」以外的1只「破械」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26236560,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,26236561)
	e2:SetCondition(c26236560.spcon)
	e2:SetTarget(c26236560.sptg)
	e2:SetOperation(c26236560.spop)
	c:RegisterEffect(e2)
end
-- 选择破坏对象的过滤条件：该对象被破坏后，自己场上仍存在可用的怪兽区空格（以确保这张卡能特殊召唤）。
function c26236560.desfilter(c,tp)
	-- 计算若目标c离场后自己场上剩余可用怪兽区数量，并判断是否大于0（若没有空格则不能选为破坏对象）。
	return Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动目标判定：当指定对象时，验证对象为自己场上的卡且满足破坏后有空位的过滤条件；发动时检查这张手卡能否特殊召唤，以及自己场上是否存在可选对象。
function c26236560.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c26236560.desfilter(chkc,tp) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 同时检查自己场上是否存在满足条件的己方卡片可作为效果对象（取对象效果的合法对象检索）。
		and Duel.IsExistingTarget(c26236560.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1张满足条件的卡作为效果对象（取对象），并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c26236560.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置连锁操作信息：本次效果将破坏1张对象卡（用于触发相关卡片互动判定）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁操作信息：本次效果将特殊召唤这张卡自身（这张卡从手卡特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：先取对象，若对象仍与效果关联且被成功破坏，且这张卡仍在手卡/与效果关联，则将此卡特殊召唤；随后给自己场上施加“不是恶魔族怪兽不能特殊召唤”的自肃效果，持续到回合结束。
function c26236560.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中记录的第一个效果对象（被选为破坏目标的卡）。
	local tc=Duel.GetFirstTarget()
	-- 判定：目标卡仍与效果关联，且破坏成功（实际被破坏数量不为0），且这张卡自身仍与效果关联（没有离开手卡等）。三者满足才继续特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 将这张手卡里的怪兽以表侧表示特殊召唤到自己的怪兽区（无视召唤条件/苏生限制，因为是效果特殊召唤）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。②：场上的这张卡被战斗或者「破械童子 阿罗汉」以外的卡的效果破坏的场合才能发动。从手卡·卡组把「破械童子 阿罗汉」以外的1只「破械」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c26236560.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“非恶魔族怪兽不能特殊召唤”的永续效果注册到当前玩家身上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的过滤条件：只有种族不是恶魔族的怪兽才被禁止特殊召唤（即非恶魔族不能特召）。
function c26236560.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- ②效果的发动条件：这张卡在场上被战斗破坏，或被除了「破械童子 阿罗汉」以外的卡的效果破坏，且破坏前位于场上。注意：被自己卡名（26236560）的效果破坏时不满足条件。
function c26236560.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(26236560))) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索/特殊召唤的过滤条件：卡名属于「破械」字段，不是「破械童子 阿罗汉」自身，且能被当前效果特殊召唤。
function c26236560.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(26236560) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标条件：发动时要求自己有可用怪兽区，且手卡·卡组存在符合条件的「破械」怪兽；通过后登记从手卡·卡组特殊召唤1只的操作信息。
function c26236560.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时先检查自己场上是否有可用的怪兽区域，如果没有则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手卡·卡组中是否存在满足条件的「破械」怪兽（至少1张）。
		and Duel.IsExistingMatchingCard(c26236560.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：本次效果将从手卡·卡组特殊召唤1只怪兽（对象在效果处理时选择，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：若场上仍有空格，则展示选择提示，让玩家从手卡·卡组选1只满足条件的「破械」怪兽，以表侧表示特殊召唤到自己的怪兽区。
function c26236560.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有可用怪兽区，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组中选择1张满足条件的「破械」怪兽（此时才实际选择要特殊召唤的卡）。
	local g=Duel.SelectMatchingCard(tp,c26236560.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
