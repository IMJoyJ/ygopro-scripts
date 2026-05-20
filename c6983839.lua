--竜巻竜
-- 效果：
-- 4星怪兽×2
-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c6983839.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6983839,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c6983839.cost)
	e1:SetTarget(c6983839.target)
	e1:SetOperation(c6983839.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的代价：把这张卡1个超量素材取除
function c6983839.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的目标选择：以场上1张魔法·陷阱卡为对象
function c6983839.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置效果处理信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：将作为对象的卡片破坏
function c6983839.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
