--ながれ者傭兵部隊
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，把这张卡解放才能发动。选择对方场上里侧守备表示存在的1只怪兽破坏。
function c92887027.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽送去墓地时，把这张卡解放才能发动。选择对方场上里侧守备表示存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92887027,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c92887027.condition)
	e1:SetCost(c92887027.cost)
	e1:SetTarget(c92887027.target)
	e1:SetOperation(c92887027.operation)
	c:RegisterEffect(e1)
end
-- 判定发动条件：自身战斗破坏对方怪兽并送去墓地，且自身在战斗中关系成立。
function c92887027.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE) and c:IsRelateToBattle()
end
-- 判定并执行发动代价：解放自身。
function c92887027.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：处于里侧守备表示的卡。
function c92887027.filter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- 判定并选择对方场上里侧守备表示的1只怪兽作为效果对象，并设置破坏的操作信息。
function c92887027.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c92887027.filter(chkc) end
	-- 在发动时点判定对方场上是否存在至少1只里侧守备表示的怪兽作为可选对象。
	if chk==0 then return Duel.IsExistingTarget(c92887027.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送选择要破坏的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只里侧守备表示的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c92887027.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：破坏所选的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：若对象怪兽仍处于里侧守备表示且仍是该效果的对象，则将其破坏。
function c92887027.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsPosition(POS_FACEDOWN_DEFENSE) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
