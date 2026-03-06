--チェンジ・シンクロン
-- 效果：
-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合，选择对方场上存在的1只怪兽把表示形式变更。
function c25652655.initial_effect(c)
	-- 效果原文：这张卡被同调怪兽的同调召唤使用送去墓地的场合，选择对方场上存在的1只怪兽把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25652655,0))  --"变更表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c25652655.condition)
	e1:SetTarget(c25652655.target)
	e1:SetOperation(c25652655.operation)
	c:RegisterEffect(e1)
end
-- 规则层面：判断此卡是否因同调召唤被送入墓地
function c25652655.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 规则层面：筛选可以改变表示形式的怪兽
function c25652655.filter(c)
	return c:IsCanChangePosition()
end
-- 规则层面：选择对方场上1只可以改变表示形式的怪兽作为目标
function c25652655.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c25652655.filter(chkc) end
	if chk==0 then return true end
	-- 规则层面：提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 规则层面：选择对方场上1只可以改变表示形式的怪兽
	local g=Duel.SelectTarget(tp,c25652655.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 规则层面：设置连锁操作信息，确定要改变表示形式的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 规则层面：执行表示形式变更效果
function c25652655.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 规则层面：将目标怪兽变为表侧守备、里侧守备、表侧攻击或表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
