--氷帝メビウス
-- 效果：
-- ①：这张卡上级召唤成功时，以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。
function c4929256.initial_effect(c)
	-- ①：这张卡上级召唤成功时，以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4929256,0))  --"场上的最多2张魔法·陷阱卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c4929256.condition)
	e1:SetTarget(c4929256.target)
	e1:SetOperation(c4929256.operation)
	c:RegisterEffect(e1)
end
-- 判断这张卡的召唤类型是否为上级召唤，作为效果发动条件之一。
function c4929256.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 筛选场上的魔法·陷阱卡，用于确定可被选择为对象的卡片。
function c4929256.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的目标选择处理：确认有可选择的魔法·陷阱卡时，让玩家选择场上1~2张魔法·陷阱卡作为对象，并设置破坏的操作信息。
function c4929256.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c4929256.filter(chkc) end
	-- 发动时检查场上是否存在至少1张满足条件的魔法·陷阱卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c4929256.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作者弹出选择提示信息“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1~2张魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c4929256.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 将本次效果的处理信息设置为破坏所选择的对象，数量为已选对象数，用于后续破坏处理及连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：取得连锁中实际成为对象的卡片，过滤出仍与效果关联的卡片，并将其破坏。
function c4929256.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的效果对象卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 因效果原因破坏筛选出的对象卡片。
	Duel.Destroy(sg,REASON_EFFECT)
end
