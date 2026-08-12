--王墓の罠
-- 效果：
-- ①：从对方墓地往自己场上有不死族怪兽特殊召唤时，以场上2张卡为对象才能发动。那些卡破坏。
function c80955168.initial_effect(c)
	-- ①：从对方墓地往自己场上有不死族怪兽特殊召唤时，以场上2张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c80955168.condition)
	e1:SetTarget(c80955168.target)
	e1:SetOperation(c80955168.activate)
	c:RegisterEffect(e1)
end
-- 过滤出满足“从对方墓地往自己场上表侧表示特殊召唤的不死族怪兽”条件的卡片
function c80955168.cfilter(c,tp)
	return c:IsFaceup() and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(1-tp)
		and c:IsControler(tp) and c:IsRace(RACE_ZOMBIE)
end
-- 发动条件判定，检查特殊召唤的怪兽中是否存在满足条件的卡片
function c80955168.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c80955168.cfilter,1,nil,tp)
end
-- 效果发动时的目标选择与合法性检测，选择场上2张卡作为对象，并设置破坏的操作信息
function c80955168.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 在发动阶段检测场上是否存在除这张卡以外的2张卡可以作为对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上2张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,e:GetHandler())
	-- 设置连锁的操作信息，表明此效果将破坏这2张选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果处理函数，获取并破坏仍与效果相关的对象卡片
function c80955168.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡片，并过滤出在效果处理时仍与该效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 因效果将过滤出的卡片破坏
	Duel.Destroy(g,REASON_EFFECT)
end
