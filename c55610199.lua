--ジェムナイトレディ・ローズ・ダイヤ
-- 效果：
-- 「宝石骑士」怪兽＋天使族怪兽
-- ①：只要这张卡在怪兽区域存在，对方回合只有1次，自己场上的「宝石骑士」怪兽不会被效果破坏。
-- ②：自己回合，对方把怪兽的效果发动时，从自己墓地把1张「宝石骑士」卡除外，以对方场上1张表侧表示卡为对象才能发动。那张卡破坏。
function c55610199.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，素材为「宝石骑士」怪兽＋天使族怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),true)
	-- ①：只要这张卡在怪兽区域存在，对方回合只有1次，自己场上的「宝石骑士」怪兽不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c55610199.indcon)
	e1:SetTarget(c55610199.indtg)
	e1:SetCountLimit(1)
	e1:SetValue(c55610199.valcon)
	c:RegisterEffect(e1)
	-- ②：自己回合，对方把怪兽的效果发动时，从自己墓地把1张「宝石骑士」卡除外，以对方场上1张表侧表示卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c55610199.descon)
	e2:SetCost(c55610199.descost)
	e2:SetTarget(c55610199.destg)
	e2:SetOperation(c55610199.desop)
	c:RegisterEffect(e2)
end
-- 效果①的条件函数：当前回合是对方回合
function c55610199.indcon(e)
	-- 判定当前回合玩家是否不是自身效果的控制者（即对方回合）
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 效果①的适用对象过滤：自己场上表侧表示的「宝石骑士」怪兽
function c55610199.indtg(e,c)
	return c:IsSetCard(0x1047) and c:IsFaceup()
end
-- 效果①的破坏原因过滤：仅在被效果破坏时适用
function c55610199.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 效果②的发动条件：此卡未确定战破，且对方发动了怪兽效果，且当前是自己回合
function c55610199.descon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
		-- 判定当前回合玩家是否为自己（即自己回合）
		and Duel.GetTurnPlayer()==tp
end
-- 效果②的Cost过滤：自己墓地可以除外的「宝石骑士」卡
function c55610199.cfilter(c)
	return c:IsSetCard(0x1047) and c:IsAbleToRemoveAsCost()
end
-- 效果②的Cost处理：从自己墓地把1张「宝石骑士」卡除外
function c55610199.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：检查自己墓地是否存在至少1张可除外的「宝石骑士」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c55610199.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1张「宝石骑士」卡
	local g=Duel.SelectMatchingCard(tp,c55610199.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的目标选择与发动准备：以对方场上1张表侧表示卡为对象
function c55610199.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在可以作为对象的表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张表侧表示卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的卡破坏
function c55610199.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
