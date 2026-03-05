--若い忍者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有怪兽表侧表示特殊召唤的场合，以那之内的1只为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽变成里侧守备表示。
-- ②：这张卡从手卡·场上送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽变成表侧攻击表示或里侧守备表示。
local s,id,o=GetID()
-- 创建两个效果，分别对应卡片效果①和②
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
-- 定义过滤函数，用于筛选可以变成里侧守备表示的场上怪兽
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsCanBeEffectTarget(e)
end
-- 效果①的发动时的处理函数，用于判断是否满足发动条件并设置效果对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.filter(chkc,e,tp) end
	local c=e:GetHandler()
	-- 判断是否满足效果①的发动条件，包括是否有符合条件的怪兽、是否有特殊召唤空间、自身是否可以特殊召唤
	if chk==0 then return eg:IsExists(s.filter,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=eg:FilterSelect(tp,s.filter,1,1,nil,e,tp)
	-- 设置效果对象为选中的怪兽
	Duel.SetTargetCard(g)
	-- 设置效果处理信息，表示要改变对象怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置效果处理信息，表示要特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理函数，执行特殊召唤和改变对象怪兽表示形式的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否可以特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取效果对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
			-- 将对象怪兽变为里侧守备表示
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 判断效果②是否满足发动条件，即卡片是否从手牌或场上送去墓地
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 定义过滤函数，用于筛选可以改变表示形式的场上怪兽
function s.pfilter(c)
	return c:IsCanTurnSet() or not c:IsPosition(POS_FACEUP_ATTACK)
end
-- 效果②的发动时的处理函数，用于判断是否满足发动条件并设置效果对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.pfilter(chkc) end
	-- 判断是否满足效果②的发动条件，即场上是否存在可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.pfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	-- 选择场上符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.pfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示要改变对象怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果②的处理函数，执行改变对象怪兽表示形式的操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsPosition(POS_FACEUP_ATTACK) then
		-- 将对象怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	elseif tc:IsPosition(POS_FACEDOWN_DEFENSE) then
		-- 将对象怪兽变为表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	elseif tc:IsCanTurnSet() then
		-- 让玩家选择对象怪兽的表示形式
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		-- 将对象怪兽变为选择的表示形式
		Duel.ChangePosition(tc,pos)
	else
		-- 将对象怪兽变为表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
