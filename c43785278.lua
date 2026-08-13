--フーコーの魔砲石
-- 效果：
-- ←2 【灵摆】 2→
-- ①：这张卡发动的回合的结束阶段，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
-- 【怪兽描述】
-- 是彷徨于梦幻空间的机关生命体，本应是如此。
-- 最大的谜团是，过去的记录却几乎··留下来。
-- 那理由···呢，·····干涉···它在···拒··？
-- ···消去···
function c43785278.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性；active_effect=false 表示不注册灵摆卡“卡的发动”的效果，该效果由后面的 e1 处理。
	aux.EnablePendulumAttribute(c,false)
	-- 这张卡发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c43785278.reg)
	c:RegisterEffect(e1)
	-- ①：这张卡发动的回合的结束阶段，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43785278,0))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c43785278.descon)
	e2:SetTarget(c43785278.destg)
	e2:SetOperation(c43785278.desop)
	c:RegisterEffect(e2)
end
-- 作为 e1 的发动代价：给这张卡注册一个标识（结束阶段重置），用于记录“这张卡已发动”。
function c43785278.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(43785278,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 检查这张卡是否拥有已发动的标识，作为结束阶段发动破坏效果的条件。
function c43785278.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(43785278)~=0
end
-- 定义可选择为对象的卡：场上表侧表示的魔法·陷阱卡。
function c43785278.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动的目标选择阶段：检测是否存在合法对象，存在则提示玩家选择1张表侧表示魔法·陷阱卡作为对象，并登记破坏的操作信息。
function c43785278.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c43785278.filter(chkc) end
	-- 合法性检查：场上是否存在至少1张满足 filter 的表侧表示魔法·陷阱卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c43785278.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示提示信息“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张表侧表示的魔法·陷阱卡作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c43785278.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设定连锁操作信息：本连锁将破坏所选择的1张卡，供其他卡的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：获取对象卡，若对象仍与效果关联且为表侧表示，则将其破坏。
function c43785278.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的第一张（唯一一张）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 以“效果”作为破坏原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
