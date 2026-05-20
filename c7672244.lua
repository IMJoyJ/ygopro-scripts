--シエンの間者
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽发动。直到这个回合的结束阶段时，选择的卡的控制权移给对方。
function c7672244.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只怪兽发动。直到这个回合的结束阶段时，选择的卡的控制权移给对方。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c7672244.target)
	e1:SetOperation(c7672244.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示且可以改变控制权的怪兽
function c7672244.filter(c)
	return c:IsControlerCanBeChanged() and c:IsFaceup()
end
-- 效果发动的目标选择：判断是否能选择符合条件的对象，并进行对象选择和操作信息注册
function c7672244.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7672244.filter(chkc) end
	-- 判断自己场上是否存在可以改变控制权的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c7672244.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c7672244.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示该效果包含改变控制权的操作，对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：获取对象怪兽，并在效果关系成立时将其控制权转移给对方，直到结束阶段
function c7672244.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽的控制权转移给对方，直到这个回合的结束阶段
		Duel.GetControl(tc,1-tp,PHASE_END,1)
	end
end
