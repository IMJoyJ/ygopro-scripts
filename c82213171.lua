--闇王プロメティス
-- 效果：
-- ①：这张卡召唤成功的场合发动。选自己墓地的暗属性怪兽任意数量除外。这张卡的攻击力直到回合结束时上升除外数量×400。
function c82213171.initial_effect(c)
	-- ①：这张卡召唤成功的场合发动。选自己墓地的暗属性怪兽任意数量除外。这张卡的攻击力直到回合结束时上升除外数量×400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82213171,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c82213171.target)
	e1:SetOperation(c82213171.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地的暗属性且可以除外的怪兽
function c82213171.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
-- 效果发动的准备：作为必发效果直接返回true，若墓地有符合条件的卡则设置除外的操作信息
function c82213171.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己墓地所有满足条件的暗属性怪兽
	local g=Duel.GetMatchingGroup(c82213171.cfilter,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		-- 设置操作信息：从自己墓地将至少1张卡除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
	end
end
-- 效果处理：让玩家选择自己墓地的暗属性怪兽除外，并根据除外数量上升这张卡的攻击力
function c82213171.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地任意数量（1到63张）满足条件的暗属性怪兽
	local cg=Duel.SelectMatchingCard(tp,c82213171.cfilter,tp,LOCATION_GRAVE,0,1,63,nil)
	-- 将选中的怪兽表侧表示除外，并获取实际除外的数量
	local ct=Duel.Remove(cg,POS_FACEUP,REASON_EFFECT)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升除外数量×400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,1)
		c:RegisterEffect(e1)
	end
end
