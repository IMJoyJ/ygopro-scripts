--相剣大公－承影
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：让这张卡的攻击力·守备力上升并让对方场上的怪兽的攻击力·守备力下降除外状态的卡数量×100。
-- ②：这张卡被效果破坏的场合，可以作为代替把自己墓地1张卡除外。
-- ③：卡被除外的场合才能发动。对方的场上以及墓地的卡各1张除外。
function c96633955.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：让这张卡的攻击力·守备力上升并让对方场上的怪兽的攻击力·守备力下降除外状态的卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c96633955.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ①：让这张卡的攻击力·守备力上升并让对方场上的怪兽的攻击力·守备力下降除外状态的卡数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c96633955.value1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ②：这张卡被效果破坏的场合，可以作为代替把自己墓地1张卡除外。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetTarget(c96633955.desreptg)
	c:RegisterEffect(e5)
	-- ③：卡被除外的场合才能发动。对方的场上以及墓地的卡各1张除外。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(96633955,0))  --"选对方两张卡除外"
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_REMOVE)
	e6:SetCountLimit(1,96633955)
	e6:SetTarget(c96633955.remtg)
	e6:SetOperation(c96633955.remop)
	c:RegisterEffect(e6)
end
-- 定义自身攻击力·守备力上升数值的计算函数
function c96633955.value(e,c)
	-- 获取双方除外状态的卡片总数并乘以100
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED)*100
end
-- 定义对方场上怪兽攻击力·守备力下降数值的计算函数
function c96633955.value1(e,c)
	-- 获取双方除外状态的卡片总数并乘以-100
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED)*(-100)
end
-- 代替破坏效果的条件与目标检查函数
function c96633955.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
		-- 检查自己墓地是否存在可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己墓地中选择1张可以除外的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的卡除外以代替破坏
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 效果③的条件与目标检查函数
function c96633955.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查对方墓地是否存在可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 设置效果处理信息，表示将除外对方场上和墓地的卡各1张
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,0,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果③的效果处理函数，执行除外操作
function c96633955.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以除外的卡片
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	-- 获取对方墓地所有可以除外的卡片
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 提示玩家选择要除外的卡片（对方场上）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 提示玩家选择要除外的卡片（对方墓地）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		-- 在画面上框选并展示被选择的卡片
		Duel.HintSelection(sg1)
		-- 将选中的卡片除外
		Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)
	end
end
