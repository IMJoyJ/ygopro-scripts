--時空混沌渦
-- 效果：
-- ①：自己场上的「银河」超量怪兽被对方怪兽的攻击或者对方的效果破坏送去墓地时才能发动。对方场上的表侧表示的卡全部破坏并除外。
-- ②：这张卡在墓地存在的场合，自己抽卡阶段作为进行通常抽卡的代替，把墓地的这张卡除外，以自己墓地1只「银河」超量怪兽为对象才能发动。那只怪兽特殊召唤。
function c59650656.initial_effect(c)
	-- ①：自己场上的「银河」超量怪兽被对方怪兽的攻击或者对方的效果破坏送去墓地时才能发动。对方场上的表侧表示的卡全部破坏并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59650656,0))  --"破坏并除外"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c59650656.descon)
	e1:SetTarget(c59650656.destg)
	e1:SetOperation(c59650656.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，自己抽卡阶段作为进行通常抽卡的代替，把墓地的这张卡除外，以自己墓地1只「银河」超量怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59650656,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c59650656.spcon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c59650656.sptg)
	e2:SetOperation(c59650656.spop)
	c:RegisterEffect(e2)
end
-- 过滤满足“自己场上的表侧表示的「银河」超量怪兽被对方怪兽的攻击或者对方的效果破坏送去墓地”条件的卡片
function c59650656.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
			-- 或者是由于对方回合的战斗破坏
			or c:IsReason(REASON_BATTLE) and Duel.GetTurnPlayer()==1-tp)
		and c:IsSetCard(0x7b) and c:IsType(TYPE_XYZ)
end
-- 检查送去墓地的卡中是否存在满足条件的自己场上的「银河」超量怪兽
function c59650656.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c59650656.cfilter,1,nil,tp)
end
-- 过滤对方场上表侧表示且可以除外的卡
function c59650656.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果①的发动准备与效果分类设置，确认对方场上是否存在可除外的表侧表示卡片，并设置破坏和除外的操作信息
function c59650656.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张表侧表示且可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c59650656.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有表侧表示且可以除外的卡片组
	local g=Duel.GetMatchingGroup(c59650656.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏卡片的操作信息，包含目标卡片组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置除外卡片的操作信息，包含目标卡片组及数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果①的处理，将对方场上表侧表示的卡全部破坏并除外
function c59650656.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示且可以除外的卡片组
	local g=Duel.GetMatchingGroup(c59650656.filter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 因效果将目标卡片组破坏并除外
		Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)
	end
end
-- 检查当前是否为自己的回合
function c59650656.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 过滤自己墓地中可以特殊召唤的「银河」超量怪兽
function c59650656.spfilter(c,e,tp)
	return c:IsSetCard(0x7b) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备，检查是否能放弃通常抽卡、是否有可用怪兽区域以及墓地中是否有可特召的「银河」超量怪兽，并选择特召对象
function c59650656.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c59650656.spfilter(chkc,e,tp) end
	-- 检查自己当前是否能进行通常抽卡，且自己场上是否有空余的怪兽区域
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地中存在至少1只可以特殊召唤的「银河」超量怪兽
		and Duel.IsExistingTarget(c59650656.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 使自己放弃本回合抽卡阶段的通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「银河」超量怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c59650656.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含目标卡片及数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理，将选择的墓地怪兽特殊召唤
function c59650656.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的目标对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
