--ヴェルズ・オランタ
-- 效果：
-- 把这张卡解放发动。选择对方场上表侧表示存在的1只怪兽破坏。
function c72429240.initial_effect(c)
	-- 把这张卡解放发动。选择对方场上表侧表示存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72429240,0))  --"怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c72429240.cost)
	e1:SetTarget(c72429240.target)
	e1:SetOperation(c72429240.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动代价的函数：检查自身是否可以解放，并执行解放操作
function c72429240.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：用于筛选表侧表示的卡片
function c72429240.filter(c)
	return c:IsFaceup()
end
-- 定义效果目标的函数：进行对象合法性检测、选择对方场上1只表侧表示怪兽作为对象并设置破坏的操作信息
function c72429240.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c72429240.filter(chkc) end
	-- 在发动阶段（chk==0）检查对方场上是否存在至少1只可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c72429240.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上表侧表示存在的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72429240.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表明此效果的处理是破坏选定的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果处理的函数：获取对象怪兽，若其仍表侧表示存在且仍是该效果的对象，则将其破坏
function c72429240.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
