--白夜の女王
-- 效果：
-- 这张卡不能特殊召唤。1回合1次，可以把场上盖放的1张卡破坏。
function c20193924.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值设为假，使该卡永远不满足特殊召唤条件，即不能进行特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把场上盖放的1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20193924,0))  --"场上盖放的1张卡破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c20193924.target)
	e3:SetOperation(c20193924.activate)
	c:RegisterEffect(e3)
end
-- 定义破坏对象的选择筛选函数：选中的卡必须是里侧表示，即场上盖放的卡。
function c20193924.filter(c)
	return c:IsFacedown()
end
-- 定义起动效果的发动时处理函数，负责检查能否发动、选择对象并设置破坏的操作信息。
function c20193924.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c20193924.filter(chkc) end
	-- 发动时检查：场上是否存在至少1张里侧表示的卡可作为效果对象；若不存在则无法发动。
	if chk==0 then return Duel.IsExistingTarget(c20193924.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的提示信息，用于选择对象的交互提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张里侧表示的卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c20193924.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记本次连锁的处理信息为破坏效果，并指定预期破坏的对象为该选择的卡，供其他卡牌效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果处理时的操作：取得对象卡，若其仍是里侧表示且与发动效果保持关联，则将其破坏。
function c20193924.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动效果时选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 以效果原因将该对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
