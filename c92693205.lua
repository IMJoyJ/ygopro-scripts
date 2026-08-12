--ギアギアンカー
-- 效果：
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转的场合才能发动。选最多有这张卡以外的自己场上的「齿轮齿轮」怪兽数量的场上的怪兽破坏。
function c92693205.initial_effect(c)
	-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c92693205.postg)
	e1:SetOperation(c92693205.posop)
	c:RegisterEffect(e1)
	-- ②：这张卡反转的场合才能发动。选最多有这张卡以外的自己场上的「齿轮齿轮」怪兽数量的场上的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_FLIP)
	e2:SetCondition(c92693205.descon)
	e2:SetTarget(c92693205.destg)
	e2:SetOperation(c92693205.desop)
	c:RegisterEffect(e2)
end
-- 效果①的发动准备：检查自身是否能转为里侧守备表示且本回合未发动过此效果，注册1回合1次限制的Flag，并设置改变表示形式的操作信息
function c92693205.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(92693205)==0 end
	c:RegisterFlagEffect(92693205,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：将这张卡改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果①的效果处理：若此卡在场上表侧表示存在，则将其变为里侧守备表示
function c92693205.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡变成里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤条件：表侧表示的「齿轮齿轮」怪兽
function c92693205.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x72)
end
-- 效果②的发动条件：自己场上存在这张卡以外的「齿轮齿轮」怪兽
function c92693205.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张这张卡以外的表侧表示「齿轮齿轮」怪兽
	return Duel.IsExistingMatchingCard(c92693205.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果②的发动准备：检查场上是否存在怪兽，并设置破坏的操作信息
function c92693205.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1张怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏场上的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：计算自己场上「齿轮齿轮」怪兽的数量，并选择最多该数量的场上怪兽破坏
function c92693205.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上除这张卡以外的表侧表示「齿轮齿轮」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c92693205.cfilter,tp,LOCATION_MZONE,0,aux.ExceptThisCard(e))
	if ct==0 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1到ct张双方场上的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,ct,nil)
	if g:GetCount()>0 then
		-- 为选中的卡片显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将选中的怪兽因效果破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
