--幻獣サンダーペガス
-- 效果：
-- 对方怪兽的攻击宣言时，把墓地的这张卡从游戏中除外，选择自己场上1只名字带有「幻兽」的怪兽才能发动。这个回合，选择的自己怪兽不会被战斗破坏。
function c34961968.initial_effect(c)
	-- 创建一个诱发即时效果，发动条件为对方怪兽攻击宣言时，效果发动时需要将墓地的这张卡从游戏中除外，选择自己场上1只名字带有「幻兽」的怪兽才能发动，这个回合选择的自己怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34961968,0))  --"不被战斗破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c34961968.condition)
	e1:SetCost(c34961968.cost)
	e1:SetTarget(c34961968.target)
	e1:SetOperation(c34961968.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时，判断攻击方是否为对方。
function c34961968.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(1-tp)
end
-- 将墓地的这张卡从游戏中除外作为发动代价。
function c34961968.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将墓地的这张卡从游戏中除外作为发动代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 筛选场上正面表示且名字带有「幻兽」的怪兽。
function c34961968.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1b)
end
-- 选择场上正面表示且名字带有「幻兽」的怪兽作为效果对象。
function c34961968.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c34961968.filter(chkc) end
	-- 判断场上是否存在名字带有「幻兽」的正面表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c34961968.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择一只名字带有「幻兽」的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(34961968,1))  --"请选择一只名字带有「幻兽」的怪兽"
	-- 选择场上正面表示且名字带有「幻兽」的怪兽作为效果对象。
	Duel.SelectTarget(tp,c34961968.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 为选择的怪兽设置不会被战斗破坏的效果。
function c34961968.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，选择的自己怪兽不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
