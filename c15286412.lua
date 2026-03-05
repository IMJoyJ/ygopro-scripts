--極星宝グングニル
-- 效果：
-- 把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
function c15286412.initial_effect(c)
	-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c15286412.cost)
	e1:SetTarget(c15286412.target)
	e1:SetOperation(c15286412.activate)
	c:RegisterEffect(e1)
end
-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
function c15286412.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x42,0x4b) and c:IsAbleToRemoveAsCost()
end
-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
function c15286412.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	if chk==0 then return Duel.IsExistingMatchingCard(c15286412.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	local g=Duel.SelectMatchingCard(tp,c15286412.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	Duel.Remove(g,0,REASON_COST+REASON_TEMPORARY)
	e:SetLabelObject(g:GetFirst())
end
-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
function c15286412.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	if chk==0 then
		e:SetLabel(0)
		-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
		return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	end
	-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
function c15286412.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	local tc=Duel.GetFirstTarget()
	-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and e:GetLabel()==1 then
		-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetCondition(c15286412.retcon)
		e1:SetOperation(c15286412.retop)
		e1:SetLabel(2)
		e1:SetLabelObject(e:GetLabelObject())
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
function c15286412.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	return Duel.GetTurnPlayer()==tp
end
-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
function c15286412.retop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct-1
	e:SetLabel(ct)
	-- 效果原文：把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	if ct==0 then Duel.ReturnToField(e:GetLabelObject(),POS_FACEUP_ATTACK) end
end
