--サブテラーの妖魔
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把魔法·陷阱·怪兽的效果发动时，把手卡·场上的这张卡送去墓地，以自己场上1只「地中族」怪兽为对象才能发动。那个发动无效。那之后，作为对象的怪兽变成里侧守备表示。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示，选自己的手卡·墓地1只「地中族」怪兽表侧守备表示或者里侧守备表示特殊召唤。
function c74762582.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方把魔法·陷阱·怪兽的效果发动时，把手卡·场上的这张卡送去墓地，以自己场上1只「地中族」怪兽为对象才能发动。那个发动无效。那之后，作为对象的怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74762582,0))  --"发动无效"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,74762582)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCondition(c74762582.discon)
	e1:SetCost(c74762582.discost)
	e1:SetTarget(c74762582.distg)
	e1:SetOperation(c74762582.disop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示，选自己的手卡·墓地1只「地中族」怪兽表侧守备表示或者里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74762582,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,74762583)
	e2:SetTarget(c74762582.sptg)
	e2:SetOperation(c74762582.spop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动条件判定函数
function c74762582.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否为对方发动效果、自身未被战斗破坏且该发动可以被无效
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- ①号效果的发动代价（Cost）处理函数
function c74762582.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将手卡·场上的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：自己场上表侧表示、属于「地中族」且可以变成里侧表示的怪兽
function c74762582.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xed) and c:IsCanTurnSet()
end
-- ①号效果的发动目标（Target）判定与选择函数
function c74762582.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc~=c and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c74762582.filter(chkc) end
	-- 在发动时，检查场上是否存在除自身以外符合条件的「地中族」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c74762582.filter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只「地中族」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c74762582.filter,tp,LOCATION_MZONE,0,1,1,c)
	-- 设置操作信息：包含使发动无效的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：包含改变目标怪兽表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①号效果的实际效果处理（Operation）函数
function c74762582.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效
	if Duel.NegateActivation(ev) then
		-- 获取作为效果对象的怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			-- 中断当前效果处理，使后续的改变表示形式处理不与无效同时进行
			Duel.BreakEffect()
			-- 将作为对象的怪兽变成里侧守备表示
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 过滤条件：场上表侧表示且可以变成里侧表示的怪兽
function c74762582.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 过滤条件：手卡·墓地中属于「地中族」且可以特殊召唤的怪兽
function c74762582.spfilter(c,e,tp)
	return c:IsSetCard(0xed) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- ②号效果的发动目标（Target）判定与选择函数
function c74762582.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c74762582.posfilter(chkc) end
	-- 在发动时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己场上存在可以变成里侧表示的表侧表示怪兽
		and Duel.IsExistingTarget(c74762582.posfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 且自己的手卡·墓地存在可以特殊召唤的「地中族」怪兽
		and Duel.IsExistingMatchingCard(c74762582.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c74762582.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：包含改变目标怪兽表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置操作信息：包含从手卡·墓地特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②号效果的实际效果处理（Operation）函数
function c74762582.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc1=Duel.GetFirstTarget()
	-- 如果作为对象的怪兽仍表侧表示存在且成功变成里侧守备表示
	if tc1:IsFaceup() and tc1:IsRelateToEffect(e) and Duel.ChangePosition(tc1,POS_FACEDOWN_DEFENSE)>0
		-- 且此时自己场上仍有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·墓地选择1只不受「王家之谷」影响的「地中族」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c74762582.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if not tc then return end
		-- 如果成功以守备表示特殊召唤，且该怪兽是以里侧守备表示特殊召唤
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
			-- 向对方玩家确认该里侧特殊召唤的怪兽
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
