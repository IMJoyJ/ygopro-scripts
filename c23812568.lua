--アディショナル・ミラー・レベル7
-- 效果：
-- ①：自己场上有7星怪兽特殊召唤的场合，从手卡·卡组把2张「附加镜·等级7」送去墓地，以那1只怪兽为对象才能发动。那2只同名怪兽从卡组特殊召唤。那之后，自己受到这个效果特殊召唤的怪兽的原本攻击力合计数值的伤害。这张卡的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
function c23812568.initial_effect(c)
	-- 启用额外卡组特殊召唤次数限制的全局计数机制
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
-- 过滤函数，用于检测场上是否存在7星怪兽
function c23812568.filter1(c,tp)
	return c:IsFaceup() and c:IsLevel(7) and c:IsControler(tp)
end
-- 过滤函数，用于检测目标怪兽是否可以成为效果对象且满足特殊召唤条件
function c23812568.filter2(c,e,tp)
	return c:IsCanBeEffectTarget(e)
		-- 检测是否满足特殊召唤条件
		and Duel.IsExistingMatchingCard(c23812568.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp,c:GetCode())
end
-- 过滤函数，用于检测卡组中是否存在同名怪兽且可特殊召唤
function c23812568.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件：自己场上有7星怪兽特殊召唤
function c23812568.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23812568.filter1,1,nil,tp)
end
-- 过滤函数，用于检测手卡或卡组中是否存在2张「附加镜·等级7」
function c23812568.cfilter(c,tp)
	return c:IsCode(23812568) and c:IsAbleToGraveAsCost()
end
-- 效果处理：检索满足条件的2张「附加镜·等级7」并送去墓地
function c23812568.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足支付代价条件
	if chk==0 then return Duel.IsExistingMatchingCard(c23812568.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,2,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的2张「附加镜·等级7」
	local g=Duel.SelectMatchingCard(tp,c23812568.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,2,2,e:GetHandler())
	-- 将选择的卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理：设置目标怪兽并准备特殊召唤
function c23812568.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(c23812568.filter1,nil,tp):Filter(c23812568.filter2,nil,e,tp)
	if chkc then return mg:IsContains(chkc) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and #mg>0 end
	local g=mg
	if #mg>1 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=mg:Select(tp,1,1,nil)
	end
	-- 设置当前效果的目标怪兽
	Duel.SetTargetCard(g)
	-- 设置操作信息：准备特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：发动效果并设置限制
function c23812568.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置效果：禁止玩家从额外卡组特殊召唤怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c23812568.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果：禁止玩家从额外卡组特殊召唤怪兽
		Duel.RegisterEffect(e1,tp)
		-- 设置效果：监听特殊召唤成功事件并更新次数限制
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetOperation(c23812568.checkop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果：监听特殊召唤成功事件并更新次数限制
		Duel.RegisterEffect(e2,tp)
		-- 设置效果：设置额外卡组特殊召唤次数限制的全局计数机制
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(92345028)
		e3:SetTargetRange(1,0)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果：设置额外卡组特殊召唤次数限制的全局计数机制
		Duel.RegisterEffect(e3,tp)
	end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 判断场上是否还有足够的空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的2张同名怪兽
	local g=Duel.SelectMatchingCard(tp,c23812568.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,2,2,nil,e,tp,tc:GetCode())
	if #g~=2 then return end
	-- 将选择的怪兽特殊召唤
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 计算特殊召唤怪兽的攻击力总和
		local atk=Duel.GetOperatedGroup():GetSum(Card.GetBaseAttack)
		if atk==0 then return end
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 给予玩家伤害
		Duel.Damage(tp,atk,REASON_EFFECT)
	end
end
-- 限制函数：判断是否满足额外卡组特殊召唤次数限制
function c23812568.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 判断是否满足额外卡组特殊召唤次数限制
	return c:IsLocation(LOCATION_EXTRA) and aux.ExtraDeckSummonCountLimit[sump]<=0
end
-- 过滤函数：检测是否为从额外卡组召唤的怪兽
function c23812568.ckfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 效果处理函数：更新额外卡组特殊召唤次数
function c23812568.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c23812568.ckfilter,1,nil,tp) then
		-- 减少玩家的额外卡组特殊召唤次数
		aux.ExtraDeckSummonCountLimit[tp]=aux.ExtraDeckSummonCountLimit[tp]-1
	end
	if eg:IsExists(c23812568.ckfilter,1,nil,1-tp) then
		-- 减少对手的额外卡组特殊召唤次数
		aux.ExtraDeckSummonCountLimit[1-tp]=aux.ExtraDeckSummonCountLimit[1-tp]-1
	end
end
