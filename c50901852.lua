--機巧菟－稻羽之淤岐素
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。攻击力和守备力的数值相同的1只机械族怪兽从手卡守备表示特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只攻击力和守备力的数值相同的机械族怪兽为对象才能发动。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽的攻击力·守备力变成自己场上的攻击力和守备力的数值相同的机械族怪兽的原本攻击力合计数值。
function c50901852.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。攻击力和守备力的数值相同的1只机械族怪兽从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50901852,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c50901852.sptg)
	e1:SetOperation(c50901852.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外，以自己场上1只攻击力和守备力的数值相同的机械族怪兽为对象才能发动。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽的攻击力·守备力变成自己场上的攻击力和守备力的数值相同的机械族怪兽的原本攻击力合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50901852,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果的发动代价：将墓地的这张卡除外作为cost。
	e2:SetCost(aux.bfgcost)
	e2:SetCountLimit(1,50901852)
	e2:SetTarget(c50901852.atktg)
	e2:SetOperation(c50901852.atkop)
	c:RegisterEffect(e2)
end
-- 定义①效果可特殊召唤的怪兽的筛选函数：需攻守数值相同、机械族，且能以表侧守备表示特殊召唤。
function c50901852.spfilter(c,e,tp)
	-- 筛选条件：攻守数值相同且为机械族怪兽。
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动条件判断：自己场上有空位，且手牌中存在符合条件的机械族怪兽。
function c50901852.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件之一：自己主要怪兽区存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：手牌中存在至少1只满足spfilter的机械族怪兽。
		and Duel.IsExistingMatchingCard(c50901852.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁涉及从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：若仍有空位，从手牌选择1只符合条件的机械族怪兽，以表侧守备表示特殊召唤。
function c50901852.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上有空位，无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足spfilter的机械族怪兽。
	local g=Duel.SelectMatchingCard(tp,c50901852.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 定义②效果中“自己场上的攻击力和守备力的数值相同的机械族怪兽”的过滤函数：表侧表示、攻守相同、机械族。
function c50901852.atkfilter(c)
	-- 过滤条件：表侧表示、攻守数值相同、机械族。
	return c:IsFaceup() and aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE)
end
-- 定义②效果对象的过滤函数：需满足上述条件，且当前攻击力和守备力不同时等于atk。
function c50901852.cfilter(c,atk)
	return c50901852.atkfilter(c) and not (c:IsAttack(atk) and c:IsDefense(atk))
end
-- ②效果的发动条件与取对象处理：计算己方场上符合条件的机械族怪兽原本攻击力合计，选择1只尚未等于该合计的符合条件怪兽作为对象。
function c50901852.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取己方场上所有满足atkfilter的机械族怪兽，用于计算原本攻击力合计值。
	local g=Duel.GetMatchingGroup(c50901852.atkfilter,tp,LOCATION_MZONE,0,nil)
	local atk=0
	if g:GetCount()>0 then atk=g:GetSum(Card.GetBaseAttack) end
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c50901852.cfilter(chkc,atk) end
	-- 发动条件：存在至少1只符合条件的机械族怪兽用于计算合计，且场上存在可选对象。
	if chk==0 then return g:GetCount()>0 and Duel.IsExistingTarget(c50901852.cfilter,tp,LOCATION_MZONE,0,1,nil,atk) end
	-- 弹出选择提示，要求玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只满足cfilter的怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c50901852.cfilter,tp,LOCATION_MZONE,0,1,1,nil,atk)
	-- 设置操作信息：将对象标记为CATEGORY_TODECK分类，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理：若对象仍与效果关联且表侧表示，重新计算己方场上符合条件的机械族怪兽原本攻击力合计，将对象攻击力/守备力变成该合计，并对其施加本回合不能攻击的限制（除该对象外其他怪兽不能攻击宣言）。
function c50901852.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=0
		-- 处理时重新获取己方场上符合条件的机械族怪兽，用于计算当前原本攻击力合计。
		local g=Duel.GetMatchingGroup(c50901852.atkfilter,tp,LOCATION_MZONE,0,nil)
		if g:GetCount()>0 then atk=g:GetSum(Card.GetBaseAttack) end
		-- 那只怪兽的攻击力变成自己场上的攻击力和守备力的数值相同的机械族怪兽的原本攻击力合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
		-- 这个回合，自己不用那只怪兽不能攻击宣言。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetTarget(c50901852.ftarget)
		e3:SetLabel(tc:GetFieldID())
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将不能攻击宣言的限制效果注册到场上，使我方场上非对象怪兽本回合不能攻击宣言。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 定义限制效果的目标判定：返回true表示该怪兽不是②效果选择的对象，因此不能攻击宣言。
function c50901852.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
