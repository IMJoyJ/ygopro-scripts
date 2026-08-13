--EMモモンカーペット
-- 效果：
-- ←7 【灵摆】 7→
-- ①：另一边的自己的灵摆区域没有卡存在的场合这张卡破坏。
-- ②：只要这张卡在灵摆区域存在，自己受到的战斗伤害变成一半。
-- 【怪兽效果】
-- ①：这张卡反转的场合，以场上盖放的1张卡为对象才能发动。那张卡破坏。
-- ②：这张卡特殊召唤成功的场合才能发动。这张卡变成里侧守备表示。
function c20281581.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其能作为灵摆卡发动并支持灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域没有卡存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c20281581.descon)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在灵摆区域存在，自己受到的战斗伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(HALF_DAMAGE)
	c:RegisterEffect(e2)
	-- ①：这张卡反转的场合，以场上盖放的1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20281581,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(c20281581.target)
	e3:SetOperation(c20281581.operation)
	c:RegisterEffect(e3)
	-- ②：这张卡特殊召唤成功的场合才能发动。这张卡变成里侧守备表示。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20281581,2))
	e4:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(c20281581.postg)
	e4:SetOperation(c20281581.posop)
	c:RegisterEffect(e4)
end
-- 定义效果e1的自毁条件：检查自己的灵摆区域中是否存在除自身以外的其他卡；若不存在则满足自毁条件。
function c20281581.descon(e)
	-- 若自己的灵摆区域不存在除本卡以外的其他卡则返回真，用于判定“另一边的自己的灵摆区域没有卡存在”的自毁条件。
	return not Duel.IsExistingMatchingCard(nil,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end
-- 定义目标筛选函数：选择场上里侧表示（盖放）的卡。
function c20281581.filter(c)
	return c:IsFacedown()
end
-- 反转效果的发动条件和目标选择处理：确认存在可选择的里侧表示卡，让玩家选择1张场上盖放的卡作为对象，并设置破坏的操作信息。
function c20281581.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c20281581.filter(chkc) end
	-- 效果发动合法性检查：在发动时确认场上是否有至少1张里侧表示且能成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(c20281581.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张里侧表示卡并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c20281581.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息：将对象卡g标记为将被破坏的1张卡，供相关效果（如星尘龙）进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时，取得之前选择的对象卡；若该卡仍与效果关联，则将其破坏。
function c20281581.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果登记的（唯一）对象卡，即玩家选择的里侧表示卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 特殊召唤成功后的诱发效果的目标/发动条件：确认这张卡可以变为里侧表示，并设置表示形式变更的操作信息。
function c20281581.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() end
	-- 设置操作信息：标记这张卡将被改变表示形式（变为里侧守备表示）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理时，若这张卡仍与效果关联且为表侧表示，则将其变成里侧守备表示。
function c20281581.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡从当前表示形式直接变成里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
