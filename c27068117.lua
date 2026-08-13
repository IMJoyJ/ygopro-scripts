--オーバーレイ・リジェネレート
-- 效果：
-- 选择场上存在的1只超量怪兽才能发动。把这张卡在选择的怪兽下面重叠作为超量素材。
function c27068117.initial_effect(c)
	-- 选择场上存在的1只超量怪兽才能发动。把这张卡在选择的怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c27068117.cost)
	e1:SetTarget(c27068117.target)
	e1:SetOperation(c27068117.activate)
	c:RegisterEffect(e1)
end
-- 发动代价判定：设置效果标签为1作为‘已进行发动条件检查’的标记，实际无代价并返回true。
function c27068117.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果对象筛选函数：选择场上表侧表示的超量怪兽。
function c27068117.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 目标选择与发动条件判定：在chk阶段检查是否存在表侧超量怪兽可作为对象且本卡可作为超量素材；在发动时选择场上1只表侧超量怪兽作为对象。
function c27068117.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c27068117.filter(chkc) end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在至少1只满足条件的表侧超量怪兽可作为效果对象。
		return Duel.IsExistingTarget(c27068117.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			and e:GetHandler():IsCanOverlay()
	end
	e:SetLabel(0)
	-- 给玩家显示‘请选择效果的对象’的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从双方主要怪兽区选择1只表侧表示的超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c27068117.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：若对象超量怪兽仍与效果关联且不免疫此效果，自身也仍与效果关联，则取消这张卡作为魔法卡发动后送墓的确定状态，并将其叠放到对象超量怪兽下面作为超量素材。
function c27068117.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的超量怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) then
		c:CancelToGrave()
		-- 将这张卡作为超量素材叠放到对象超量怪兽下方。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
