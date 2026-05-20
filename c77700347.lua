--ネクロ・ディフェンダー
-- 效果：
-- 自己的主要阶段时，把墓地存在的这张卡从游戏中除外，选择自己场上存在的1只怪兽才能发动。直到下次的对方的结束阶段时，选择的怪兽不会被战斗破坏，选择的怪兽的战斗发生的对自己的战斗伤害变成0。
function c77700347.initial_effect(c)
	-- 自己的主要阶段时，把墓地存在的这张卡从游戏中除外，选择自己场上存在的1只怪兽才能发动。直到下次的对方的结束阶段时，选择的怪兽不会被战斗破坏，选择的怪兽的战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77700347,0))  --"战斗耐性"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(c77700347.cost)
	e1:SetTarget(c77700347.target)
	e1:SetOperation(c77700347.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查自身是否能作为除外代价，并将自身从墓地表侧表示除外
function c77700347.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身作为发动代价表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 定义发动目标：检查并选择自己场上存在的1只怪兽作为效果对象
function c77700347.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 在第一阶段（chk==0）检查自己场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置选择卡片时的提示信息为选择对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上的1只怪兽作为效果对象
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果处理：使选择的怪兽直到下次对方结束阶段为止获得战斗破坏抗性，且其战斗产生的对自己的战斗伤害变成0
function c77700347.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 直到下次的对方的结束阶段时，选择的怪兽的战斗发生的对自己的战斗伤害变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		-- 直到下次的对方的结束阶段时，选择的怪兽不会被战斗破坏
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e2)
	end
end
