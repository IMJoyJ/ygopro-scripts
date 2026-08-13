--若い忍者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有怪兽表侧表示特殊召唤的场合，以那之内的1只为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽变成里侧守备表示。
-- ②：这张卡从手卡·场上送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽变成表侧攻击表示或里侧守备表示。
local s,id,o=GetID()
-- 注册两个效果：e1为①的诱发选发效果（自己场上有怪兽表侧表示特殊召唤成功时，从手牌将自身特殊召唤并让对象变成里侧守备表示），e2为②的诱发选发效果（自身从手牌或场上送去墓地时，改变场上1只怪兽的表示形式）；两个效果各自1回合1次。
function s.initial_effect(c)
	-- ①：自己场上有怪兽表侧表示特殊召唤的场合，以那之内的1只为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·场上送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽变成表侧攻击表示或里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 定义①的取对象筛选条件：对象必须是刚刚特殊召唤成功、位于我方主要怪兽区、表侧表示、可被我方变成里侧守备表示、且能成为效果对象的怪兽。
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsCanBeEffectTarget(e)
end
-- ①效果的发动阶段处理：若在连锁确认时（chkc）则校验该卡是否属于本次特殊召唤成功的一组且满足筛选条件；发动时确认存在符合条件的特殊召唤成功怪兽、我方主要怪兽区有空位，并且这张卡自身可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.filter(chkc,e,tp) end
	local c=e:GetHandler()
	-- ①发动条件判断：在本次特殊召唤成功的怪兽中，存在至少1只满足s.filter且能成为效果对象的我方表侧怪兽，同时我方主要怪兽区有可用的空格。
	if chk==0 then return eg:IsExists(s.filter,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向操作玩家显示选择提示，提示内容为“请选择要改变表示形式的怪兽”，用于后续选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	local g=eg:FilterSelect(tp,s.filter,1,1,nil,e,tp)
	-- 将选择出的怪兽登记为当前连锁的对象，使该卡与效果建立关联，并可在效果处理时通过Duel.GetFirstTarget()获取。
	Duel.SetTargetCard(g)
	-- 设置操作信息：后续处理会改变对象怪兽的表示形式，对象数量为1，用于时点与连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置操作信息：后续处理会将这张卡自身从手牌特殊召唤，对象为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其以表侧攻击表示特殊召唤；特殊召唤成功后，若之前选择的对象仍与效果关联且在场上表侧表示，则将其变为里侧守备表示。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与效果关联，并尝试把这张卡从手牌以表侧攻击表示特殊召唤到tp的怪兽区；只有特殊召唤成功才继续后续的对象变更处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 取回效果发动时选择的那1只对象怪兽。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
			-- 将对象怪兽的表示形式变为里侧守备表示。
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- ②效果发动条件：这张卡被送去墓地之前所在的位置是手牌或场上（即从手牌·场上送去墓地）。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 定义②可选对象的筛选条件：怪兽能够变成里侧守备表示，或者当前不是表侧攻击表示；保证该怪兽至少能变成表侧攻击表示或里侧守备表示中的一种。
function s.pfilter(c)
	return c:IsCanTurnSet() or not c:IsPosition(POS_FACEUP_ATTACK)
end
-- ②效果发动阶段处理：连锁确认时校验对象是否位于主要怪兽区且满足pfilter；发动时确认场上存在符合条件的对象；随后提示玩家选择1只怪兽，将其设为对象并设置改变表示形式的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.pfilter(chkc) end
	-- ②发动条件判断：场上存在至少1只满足pfilter且能成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.pfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示选择提示，提示内容为“请选择要改变表示形式的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从双方场上主要怪兽区选择1只满足pfilter的怪兽作为效果对象，并自动将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.pfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：后续处理会改变对象怪兽的表示形式，对象数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果处理：取得对象；若对象仍与效果关联，则根据其当前表示形式处理：表侧攻击表示→里侧守备表示；里侧守备表示→表侧攻击表示；其他表示形式且可里侧表示时由玩家选择变成表侧攻击或里侧守备，不能里侧表示则直接变成表侧攻击表示。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取回②效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsPosition(POS_FACEUP_ATTACK) then
		-- 当对象怪兽当前是表侧攻击表示时，将其变为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	elseif tc:IsPosition(POS_FACEDOWN_DEFENSE) then
		-- 当对象怪兽当前是里侧守备表示时，将其变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	elseif tc:IsCanTurnSet() then
		-- 当对象怪兽为其他表示形式且可变为里侧表示时，让玩家选择要变成表侧攻击表示还是里侧守备表示。
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		-- 将对象怪兽改变为玩家选择的表示形式。
		Duel.ChangePosition(tc,pos)
	else
		-- 当对象怪兽无法变为里侧表示时，直接将其变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
