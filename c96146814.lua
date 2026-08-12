--ADチェンジャー
-- 效果：
-- 把墓地存在的这张卡从游戏中除外，选择场上存在的1只怪兽发动。选择的怪兽的表示形式变更。
function c96146814.initial_effect(c)
	-- 把墓地存在的这张卡从游戏中除外，选择场上存在的1只怪兽发动。选择的怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96146814,0))  --"变更表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 设置发动成本为：将墓地的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c96146814.target)
	e1:SetOperation(c96146814.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：可以改变表示形式的怪兽
function c96146814.filter(c)
	return c:IsCanChangePosition()
end
-- 效果发动的目标选择与检测：选择场上1只可以改变表示形式的怪兽作为对象
function c96146814.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c96146814.filter(chkc) end
	-- 在发动阶段，检查场上是否存在可以改变表示形式的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c96146814.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上1只可以改变表示形式的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c96146814.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为改变所选怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：将选择的对象怪兽的表示形式变更
function c96146814.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 改变目标怪兽的表示形式（表侧攻击表示与守备表示、里侧守备表示之间相互变更）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
