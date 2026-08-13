--アディショナル・ミラー・レベル7
-- 效果：
-- ①：自己场上有7星怪兽特殊召唤的场合，从手卡·卡组把2张「附加镜·等级7」送去墓地，以那1只怪兽为对象才能发动。那2只同名怪兽从卡组特殊召唤。那之后，自己受到这个效果特殊召唤的怪兽的原本攻击力合计数值的伤害。这张卡的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
function c23812568.initial_effect(c)
	-- 全局启用额外卡组召唤次数限制计数器，用于记录双方玩家从额外卡组召唤怪兽的次数，以实现“这张卡的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤”的限制。
	aux.EnableExtraDeckSummonCountLimit()
	-- ①：自己场上有7星怪兽特殊召唤的场合，从手卡·卡组把2张「附加镜·等级7」送去墓地，以那1只怪兽为对象才能发动。那2只同名怪兽从卡组特殊召唤。那之后，自己受到这个效果特殊召唤的怪兽的原本攻击力合计数值的伤害。这张卡的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c23812568.condition)
	e1:SetCost(c23812568.cost)
	e1:SetTarget(c23812568.target)
	e1:SetOperation(c23812568.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：该怪兽为表侧表示、等级7且由自己控制，用于判定特殊召唤成功的7星怪兽是否符合发动条件。
function c23812568.filter1(c,tp)
	return c:IsFaceup() and c:IsLevel(7) and c:IsControler(tp)
end
-- 过滤条件：该7星怪兽能成为效果对象，且自己的卡组中存在至少2张与该怪兽卡名相同的卡可供特殊召唤，确保后续能特殊召唤同名卡。
function c23812568.filter2(c,e,tp)
	return c:IsCanBeEffectTarget(e)
		-- 确认卡组中存在至少2张与该7星怪兽同名的卡且满足特殊召唤条件，从而该怪兽可以成为效果对象。
		and Duel.IsExistingMatchingCard(c23812568.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp,c:GetCode())
end
-- 过滤条件：选择卡组中卡名与指定code相同且可以被特殊召唤的卡，用于后续从卡组特殊召唤2张同名怪兽。
function c23812568.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件：当特殊召唤成功的怪兽集合中存在至少1只自己控制的表侧表示等级7怪兽时，本效果可以发动。
function c23812568.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23812568.filter1,1,nil,tp)
end
-- 过滤条件：选择卡名是「附加镜·等级7」且可以作为代价送去墓地的卡，用于支付从手卡·卡组送墓2张同名卡的代价。
function c23812568.cfilter(c,tp)
	return c:IsCode(23812568) and c:IsAbleToGraveAsCost()
end
-- 代价处理：从自己的手卡·卡组中选择2张「附加镜·等级7」送去墓地作为发动代价。
function c23812568.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡·卡组中是否存在至少2张可作为代价的「附加镜·等级7」，决定能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c23812568.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,2,e:GetHandler()) end
	-- 向玩家显示“请选择要送去墓地的卡”的提示，要求其选择2张同名卡作为代价。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的手卡·卡组中选择2张「附加镜·等级7」作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c23812568.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,2,2,e:GetHandler())
	-- 将选中的2张卡送去墓地，原因是作为发动代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设定效果对象：从特殊召唤成功的7星怪兽中选出既能成为对象、卡组又有同名可特召卡的1只，并设置从卡组特殊召唤2张同名卡的操作信息；同时确认自己场上有2个空位且不受青眼精灵龙限制。
function c23812568.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(c23812568.filter1,nil,tp):Filter(c23812568.filter2,nil,e,tp)
	if chkc then return mg:IsContains(chkc) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and #mg>0 end
	local g=mg
	if #mg>1 then
		-- 向玩家显示“请选择效果的对象”的提示，要求其选择1只符合条件的7星怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=mg:Select(tp,1,1,nil)
	end
	-- 将选择的怪兽设置为当前效果的对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息：本效果将从卡组特殊召唤2张怪兽，供其他卡效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：若此卡是作为魔法卡发动，先为发动玩家附加“额外卡组特殊召唤次数限制”相关效果；然后检查场上空位并取得对象，从手卡·卡组选择2张同名卡特殊召唤；成功后计算它们的原本攻击力合计并给予自己伤害。
function c23812568.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c23812568.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将“额外卡组怪兽特殊召唤禁止”的限制效果注册给发动玩家，持续到回合结束。
		Duel.RegisterEffect(e1,tp)
		-- 这张卡的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetOperation(c23812568.checkop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册额外卡组特殊召唤成功时的事件监听效果，用于实时减少对应玩家的额外卡组召唤剩余次数。
		Duel.RegisterEffect(e2,tp)
		-- 那2只同名怪兽从卡组特殊召唤。那之后，自己受到这个效果特殊召唤的怪兽的原本攻击力合计数值的伤害。这张卡的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(92345028)
		e3:SetTargetRange(1,0)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册标记效果（code 92345028）给发动玩家，作为“此卡已发动过该限制/计数”的标识，持续到回合结束。
		Duel.RegisterEffect(e3,tp)
	end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时确认自己主要怪兽区域的空位至少2个，否则无法进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 取得效果指定的对象怪兽（之前选择的7星怪兽）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择2张与对象怪兽同名的卡（且能够被特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c23812568.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,2,2,nil,e,tp,tc:GetCode())
	if #g~=2 then return end
	-- 将选中的2张卡以表侧攻击/守备表示特殊召唤到己方场上；若特殊召唤成功（返回>0）则继续执行伤害。
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 计算实际因本效果特殊召唤成功的怪兽的原本攻击力合计值。
		local atk=Duel.GetOperatedGroup():GetSum(Card.GetBaseAttack)
		if atk==0 then return end
		-- 中断当前效果处理，使伤害部分作为独立处理进行，避免错失时点或连锁点。
		Duel.BreakEffect()
		-- 给予发动玩家（自己）与攻击力合计等值的伤害，原因是效果伤害（REASON_EFFECT）。
		Duel.Damage(tp,atk,REASON_EFFECT)
	end
end
-- 额外卡组特殊召唤限制条件：若尝试特殊召唤的卡来自额外卡组，且该召唤者的额外卡组召唤剩余次数已为0，则禁止特殊召唤。
function c23812568.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 判断召唤的卡是否来自额外卡组，且该召唤者的额外卡组召唤次数剩余≤0；满足则不能特殊召唤。
	return c:IsLocation(LOCATION_EXTRA) and aux.ExtraDeckSummonCountLimit[sump]<=0
end
-- 过滤条件：怪兽由指定玩家特殊召唤成功，且其特殊召唤前的所在位置是额外卡组。
function c23812568.ckfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 事件处理函数：每次额外卡组怪兽特殊召唤成功时，依据召唤者是己方或对方，减少对应的额外卡组召唤剩余次数。
function c23812568.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c23812568.ckfilter,1,nil,tp) then
		-- 减少己方（tp）的额外卡组召唤剩余次数1。
		aux.ExtraDeckSummonCountLimit[tp]=aux.ExtraDeckSummonCountLimit[tp]-1
	end
	if eg:IsExists(c23812568.ckfilter,1,nil,1-tp) then
		-- 减少对方（1-tp）的额外卡组召唤剩余次数1。
		aux.ExtraDeckSummonCountLimit[1-tp]=aux.ExtraDeckSummonCountLimit[1-tp]-1
	end
end
