--ディメンション・ゲート
-- 效果：
-- 这张卡的发动时，选择自己场上1只怪兽表侧表示从游戏中除外。此外，对方怪兽的直接攻击宣言时，可以把场上表侧表示存在的这张卡送去墓地。这张卡被送去墓地的场合，可以把这张卡的效果除外的怪兽特殊召唤。
function c44046281.initial_effect(c)
	-- 这张卡的发动时，选择自己场上1只怪兽表侧表示从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c44046281.target)
	e1:SetOperation(c44046281.operation)
	c:RegisterEffect(e1)
	-- 对方怪兽的直接攻击宣言时，可以把场上表侧表示存在的这张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44046281,0))  --"送去墓地"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c44046281.tgcon)
	e2:SetTarget(c44046281.tgtg)
	e2:SetOperation(c44046281.tgop)
	c:RegisterEffect(e2)
	-- 这张卡被送去墓地的场合，可以把这张卡的效果除外的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44046281,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c44046281.spcon)
	e2:SetTarget(c44046281.sptg)
	e2:SetOperation(c44046281.spop)
	c:RegisterEffect(e2)
end
-- 选择满足条件的怪兽作为效果的对象
function c44046281.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsAbleToRemove() end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理时要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 将选择的怪兽除外，并记录该怪兽为效果对象
function c44046281.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断效果是否有效且目标怪兽是否满足除外条件
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
		c:SetCardTarget(tc)
	end
end
-- 判断是否满足攻击宣言时的效果发动条件
function c44046281.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认攻击方不是自己且没有攻击目标
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 设置效果处理时要送去墓地的卡
function c44046281.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 将自身送去墓地
function c44046281.tgop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身送去墓地
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
-- 判断是否满足特殊召唤的发动条件
function c44046281.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and e:GetHandler():IsLocation(LOCATION_GRAVE) then
		e:SetLabelObject(tc)
		return true
	end
	return false
end
-- 判断是否满足特殊召唤的发动条件
function c44046281.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	-- 判断是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的目标怪兽
	Duel.SetTargetCard(tc)
	-- 设置效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 将效果对象怪兽特殊召唤
function c44046281.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
