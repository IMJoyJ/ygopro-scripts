--幻獣サンダーペガス
-- 效果：
-- 对方怪兽的攻击宣言时，把墓地的这张卡从游戏中除外，选择自己场上1只名字带有「幻兽」的怪兽才能发动。这个回合，选择的自己怪兽不会被战斗破坏。
function c34961968.initial_effect(c)
	-- 对方怪兽的攻击宣言时，把墓地的这张卡从游戏中除外，选择自己场上1只名字带有「幻兽」的怪兽才能发动。
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
-- 判定攻击宣言的怪兽是否为对方怪兽：仅当攻击宣言怪兽的控制者是对方时条件成立，即对方怪兽攻击宣言时才能发动。
function c34961968.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(1-tp)
end
-- 代价判定与执行：先检查此卡是否可作为代价从墓地除外；若可通过则将其从墓地除外作为发动代价。
function c34961968.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 把墓地的这张卡从游戏中除外作为发动代价（表侧表示除外）。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数：选择己方场上表侧表示且名字带有「幻兽」字段的怪兽。
function c34961968.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1b)
end
-- 发动时目标处理：检查是否存在合法对象；若存在则提示玩家选择1只满足条件的幻兽怪兽作为效果对象。
function c34961968.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c34961968.filter(chkc) end
	-- 发动合法性检查：确认自己场上是否存在至少1只表侧表示且名字带有「幻兽」的怪兽，满足则效果可发动。
	if chk==0 then return Duel.IsExistingTarget(c34961968.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示信息，提示内容为“请选择一只名字带有「幻兽」的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(34961968,1))  --"请选择一只名字带有「幻兽」的怪兽"
	-- 让玩家从自己场上选择1只表侧表示且名字带有「幻兽」的怪兽，并设定为效果的对象。
	Duel.SelectTarget(tp,c34961968.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽，若对象仍与该效果关联，则给它赋予“这个回合不会被战斗破坏”的效果。
function c34961968.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象怪兽（本效果只取1只对象）。
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
