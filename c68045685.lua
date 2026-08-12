--武神籬
-- 效果：
-- ①：自己场上的兽战士族「武神」怪兽在战斗阶段以外不会被对方的效果破坏。
-- ②：1回合1次，从手卡以及自己场上的表侧表示怪兽之中把1只「武神」怪兽送去墓地，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。
-- ③：自己结束阶段，把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己墓地1只「武神」怪兽为对象才能发动。那只怪兽特殊召唤。
function c68045685.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的兽战士族「武神」怪兽在战斗阶段以外不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c68045685.indcon)
	e2:SetTarget(c68045685.indtg)
	-- 设置不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从手卡以及自己场上的表侧表示怪兽之中把1只「武神」怪兽送去墓地，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68045685,0))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c68045685.discost)
	e3:SetTarget(c68045685.distg)
	e3:SetOperation(c68045685.disop)
	c:RegisterEffect(e3)
	-- ③：自己结束阶段，把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己墓地1只「武神」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(68045685,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCondition(c68045685.spcon)
	e4:SetCost(c68045685.spcost)
	e4:SetTarget(c68045685.sptg)
	e4:SetOperation(c68045685.spop)
	c:RegisterEffect(e4)
end
-- 不被破坏效果的适用条件：战斗阶段以外
function c68045685.indcon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 不被破坏效果的适用对象：自己场上的兽战士族「武神」怪兽
function c68045685.indtg(e,c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsSetCard(0x88)
end
-- 用于送去墓地的「武神」怪兽的过滤条件（手卡或场上表侧表示）
function c68045685.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x88) and c:IsAbleToGraveAsCost()
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
-- 效果②的发动代价（Cost）处理函数
function c68045685.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可送去墓地的「武神」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c68045685.costfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1只手卡或场上表侧表示的「武神」怪兽
	local g=Duel.SelectMatchingCard(tp,c68045685.costfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的靶向目标（Target）处理函数
function c68045685.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 重载目标检查：必须是对方场上表侧表示且可被无效的卡
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 检查对方场上是否存在可被无效的表侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：无效选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果②的效果处理（Operation）函数
function c68045685.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与该卡相关的连锁都无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- 效果③的发动条件：自己结束阶段
function c68045685.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 效果③的发动代价（Cost）处理函数
function c68045685.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将魔法与陷阱区域表侧表示的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 用于特殊召唤的「武神」怪兽的过滤条件
function c68045685.spfilter(c,e,tp)
	return c:IsSetCard(0x88) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的靶向目标（Target）处理函数
function c68045685.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c68045685.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可特殊召唤的「武神」怪兽
		and Duel.IsExistingTarget(c68045685.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「武神」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68045685.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的效果处理（Operation）函数
function c68045685.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
