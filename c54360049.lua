--カトブレパスと運命の魔女
-- 效果：
-- 对方对怪兽的特殊召唤成功时，可以把自己墓地存在的1只攻击力是?的怪兽从游戏中除外，那些特殊召唤的怪兽破坏。
function c54360049.initial_effect(c)
	-- 对方对怪兽的特殊召唤成功时，可以把自己墓地存在的1只攻击力是?的怪兽从游戏中除外，那些特殊召唤的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54360049,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c54360049.cost)
	e1:SetTarget(c54360049.target)
	e1:SetOperation(c54360049.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中攻击力为?且可以作为代价除外的怪兽卡
function c54360049.cfilter(c)
	return c:GetTextAttack()==-2 and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 效果发动的代价：将自己墓地1只攻击力是?的怪兽除外
function c54360049.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认自己墓地是否存在至少1只满足条件的攻击力为?的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c54360049.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息，要求选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的攻击力为?的怪兽
	local g=Duel.SelectMatchingCard(tp,c54360049.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤由对方特殊召唤的怪兽
function c54360049.filter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 效果发动的目标：确认是否有对方特殊召唤的怪兽，并设置破坏的操作信息
function c54360049.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c54360049.filter,1,nil,tp) end
	local g=eg:Filter(c54360049.filter,nil,tp)
	-- 将本次特殊召唤的怪兽群设为效果的处理对象
	Duel.SetTargetCard(eg)
	-- 设置当前连锁的操作信息为“破坏对方特殊召唤的怪兽”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤仍存在于场上且与效果有关联的对方特殊召唤的怪兽
function c54360049.dfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsRelateToEffect(e)
end
-- 效果处理：破坏那些特殊召唤的怪兽
function c54360049.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c54360049.dfilter,nil,e,tp)
	if g:GetCount()>0 then
		-- 因效果将符合条件的怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
