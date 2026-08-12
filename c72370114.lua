--ギアギアタッカー
-- 效果：
-- 这张卡1回合只有1次可以变成里侧守备表示。这张卡反转时，可以选最多有这张卡以外的自己场上的名字带有「齿轮齿轮」的怪兽数量的场上的魔法·陷阱卡破坏。
function c72370114.initial_effect(c)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72370114,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c72370114.target)
	e1:SetOperation(c72370114.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转时，可以选最多有这张卡以外的自己场上的名字带有「齿轮齿轮」的怪兽数量的场上的魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72370114,1))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetTarget(c72370114.destg)
	e2:SetOperation(c72370114.desop)
	c:RegisterEffect(e2)
end
-- 变成里侧守备表示效果的发动条件检查与目标设置（注册1回合1次Flag，设置操作信息为改变表示形式）
function c72370114.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(72370114)==0 end
	c:RegisterFlagEffect(72370114,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置当前连锁的操作信息为：将1张卡（自身）改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果的执行（若自身在场且表侧表示，则转为里侧守备表示）
function c72370114.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤条件：表侧表示且名字带有「齿轮齿轮」的怪兽
function c72370114.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x72)
end
-- 过滤条件：魔法或陷阱卡
function c72370114.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动条件检查与目标设置（检查是否存在其他「齿轮齿轮」怪兽以及场上是否存在魔陷，并设置破坏操作信息）
function c72370114.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除自身以外的表侧表示「齿轮齿轮」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72370114.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 检查场上是否存在至少1张魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c72370114.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c72370114.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置当前连锁的操作信息为：破坏场上的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行（计算除自身外的「齿轮齿轮」怪兽数量，选择并破坏对应数量的魔陷）
function c72370114.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上除自身以外的表侧表示「齿轮齿轮」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c72370114.cfilter,tp,LOCATION_MZONE,0,aux.ExceptThisCard(e))
	-- 获取场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c72370114.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if ct>0 and g:GetCount()>0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=g:Select(tp,1,ct,nil)
		-- 为选中的卡片显示被选为对象的动画效果
		Duel.HintSelection(dg)
		-- 因效果破坏选中的卡片
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
