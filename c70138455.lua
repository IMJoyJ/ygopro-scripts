--ミスター・ボンバー
-- 效果：
-- 在自己的准备阶段时发动。表侧表示的这张卡作为祭品，选择2只表侧表示的攻击力1000以下的怪兽破坏。
function c70138455.initial_effect(c)
	-- 在自己的准备阶段时发动。表侧表示的这张卡作为祭品，选择2只表侧表示的攻击力1000以下的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70138455,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c70138455.condition)
	e1:SetCost(c70138455.cost)
	e1:SetTarget(c70138455.target)
	e1:SetOperation(c70138455.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数，判定是否在自己的准备阶段
function c70138455.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 定义效果发动代价函数，将自身作为祭品（解放）
function c70138455.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义过滤条件：场上表侧表示且攻击力1000以下的怪兽
function c70138455.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(1000)
end
-- 定义效果发动对象选择与操作信息注册函数
function c70138455.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动阶段，检查场上是否存在至少2只满足条件的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c70138455.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,e:GetHandler()) end
	-- 给玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择2只表侧表示且攻击力1000以下的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c70138455.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
	-- 设置连锁操作信息，表明此效果将破坏选中的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 定义效果处理时的过滤条件：仍与效果相关、表侧表示且攻击力1000以下的怪兽
function c70138455.desfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup() and c:IsAttackBelow(1000)
end
-- 定义效果处理执行函数
function c70138455.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c70138455.desfilter,nil,e)
	-- 破坏仍满足条件的卡片
	Duel.Destroy(sg,REASON_EFFECT)
end
