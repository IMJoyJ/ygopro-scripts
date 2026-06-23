--裏切りの罪宝－シルウィア
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的手卡·场上（表侧表示）把1只「迪亚贝尔斯塔尔」怪兽送去墓地，以场上1张表侧表示卡为对象才能发动。那张卡的效果无效。
-- ②：对方连锁自己的「迪亚贝尔斯塔尔」怪兽或者自己的「罪宝」魔法·陷阱卡的效果的发动把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个对方的效果无效。
local s,id,o=GetID()
-- 注册两个效果，分别是①效果和②效果
function s.initial_effect(c)
	-- ①：从自己的手卡·场上（表侧表示）把1只「迪亚贝尔斯塔尔」怪兽送去墓地，以场上1张表侧表示卡为对象才能发动。那张卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方连锁自己的「迪亚贝尔斯塔尔」怪兽或者自己的「罪宝」魔法·陷阱卡的效果的发动把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个对方的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	-- 效果发动时需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「迪亚贝尔斯塔尔」怪兽
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x119b) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 检查场上是否存在可作为效果对象的卡
		and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,e:GetHandler()))
end
-- 处理①效果的费用，选择1只「迪亚贝尔斯塔尔」怪兽送去墓地
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置①效果的目标选择函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 判断目标是否满足条件
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) and c~=chkc end
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在可作为效果对象的卡
		or Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择要无效化的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上一张表侧表示的卡作为对象
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
end
-- 处理①效果的发动，使目标卡的效果无效
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		local c=e:GetHandler()
		-- 使目标卡相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标为陷阱怪兽时其效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- 设置②效果的发动条件，判断是否为对方连锁自己的「迪亚贝尔斯塔尔」怪兽或「罪宝」魔法·陷阱卡的效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁是否可以被无效
	if not Duel.IsChainDisablable(ev) or rp~=1-tp then return false end
	-- 获取连锁的触发效果和玩家
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if not te or p~=tp then return false end
	local tc=te:GetHandler()
	return tc:IsSetCard(0x119b) and te:IsActiveType(TYPE_MONSTER) or tc:IsSetCard(0x19e)
		and te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置②效果的目标信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将使对方效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 处理②效果的发动，使对方效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方连锁的效果无效
	Duel.NegateEffect(ev)
end
