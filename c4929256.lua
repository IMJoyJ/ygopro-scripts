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
-- 效果发动时的条件判断，确保是上级召唤成功
function c4929256.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 筛选场上的魔法·陷阱卡
function c4929256.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择破坏对象，限制为1~2张场上魔法·陷阱卡
function c4929256.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c4929256.filter(chkc) end
	-- 检查是否有满足条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(c4929256.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1到2张符合条件的场上卡片作为破坏对象
	local g=Duel.SelectTarget(tp,c4929256.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置连锁操作信息，确定将要破坏的卡片数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行效果破坏操作
function c4929256.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 将符合条件的卡片进行破坏处理
	Duel.Destroy(sg,REASON_EFFECT)
end
