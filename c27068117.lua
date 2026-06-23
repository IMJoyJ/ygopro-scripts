--オーバーレイ・リジェネレート
-- 效果：
-- 选择场上存在的1只超量怪兽才能发动。把这张卡在选择的怪兽下面重叠作为超量素材。
function c27068117.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点、取对象效果、费用函数、目标函数和发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c27068117.cost)
	e1:SetTarget(c27068117.target)
	e1:SetOperation(c27068117.activate)
	c:RegisterEffect(e1)
end
-- 费用函数，设置标签为1表示已支付费用
function c27068117.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数，用于筛选场上表侧表示的超量怪兽
function c27068117.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 目标选择函数，判断是否满足选择条件并进行选择
function c27068117.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c27068117.filter(chkc) end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检索场上是否存在满足条件的怪兽作为目标
		return Duel.IsExistingTarget(c27068117.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			and e:GetHandler():IsCanOverlay()
	end
	e:SetLabel(0)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c27068117.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 发动效果函数，将卡片叠放至目标怪兽下方
function c27068117.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) then
		c:CancelToGrave()
		-- 将当前卡片叠放至目标怪兽下方作为超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
