--裏切りの罪宝－シルウィア
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的手卡·场上（表侧表示）把1只「迪亚贝尔斯塔尔」怪兽送去墓地，以场上1张表侧表示卡为对象才能发动。那张卡的效果无效。
-- ②：对方连锁自己的「迪亚贝尔斯塔尔」怪兽或者自己的「罪宝」魔法·陷阱卡的效果的发动把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个对方的效果无效。
local s,id,o=GetID()
-- 定义该卡的初始化函数：创建并注册①的发动效果（将1只「迪亚贝尔斯塔尔」怪兽送墓作为代价，无效场上1张表侧表示卡）与②的墓地诱发即时效果（除外自身来无效对方发动的效果），两者通过同一CountLimit代码id共享1回合1次的使用限制。
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
	-- 设置②效果的发动代价：将墓地中的这张卡除外（aux.bfgcost实现除外自身作为cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 定义①效果代价的过滤函数：选择自己手卡或场上表侧表示的1只「迪亚贝尔斯塔尔」怪兽作为可送去墓地的代价，同时要求场上存在其他可被无效的表侧表示卡作为对象，且该对象不能是代价怪兽和这张卡自身。
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x119b) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 进一步检查场上是否存在除代价怪兽和本卡以外、可以被无效化效果选为对象的表侧表示卡，若不存在则不能选择该怪兽作为代价。
		and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,e:GetHandler()))
end
-- 定义①效果的代价处理：先确认存在符合条件的「迪亚贝尔斯塔尔」怪兽和可选对象，再让玩家从手卡或主要怪兽区选择1只该怪兽，将其送去墓地作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：在手卡或自己场上存在满足条件的「迪亚贝尔斯塔尔」怪兽，并且场上存在可被无效的表侧表示卡时，才允许发动①。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 显示“请选择要送去墓地的卡”的选择提示，引导玩家选择要作为代价送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手卡和主要怪兽区选择1只满足s.filter条件的「迪亚贝尔斯塔尔」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选中的「迪亚贝尔斯塔尔」怪兽送去墓地，作为①效果的发动代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义①效果的目标选择：必须选择场上1张除本卡以外的表侧表示卡作为对象；效果发动前检查场上是否存在这样的对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 对象合法性确认：当连锁中指定了对象chkc时，该对象必须位于场上、可被无效化处理，并且不是本卡自身。
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) and c~=chkc end
	if chk==0 then return e:IsCostChecked()
		-- 未指定对象时，若代价检查未完成，则检查场上是否存在除本卡以外可被无效化的表侧表示卡；存在则满足发动条件。
		or Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 显示“请选择表侧表示的卡”的选择提示，引导玩家选择取对象的目标卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择场上1张满足条件的表侧表示卡（除本卡外）作为对象，并将其登记为当前连锁的对象卡。
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
end
-- 定义①效果的结算：若对象仍与效果相关且表侧表示、可被无效，则使对象卡及其相关连锁无效；若对象是陷阱怪兽，则追加将其无效化的处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果发动时选择的对象卡（用SelectTarget登记的第一张对象卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		local c=e:GetHandler()
		-- 使该对象卡相关的连锁全部无效化，并在该卡变为里侧表示时重置（RESET_TURN_SET）。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那张卡的效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- 定义②效果的发动条件：对方连锁自己发动的「迪亚贝尔斯塔尔」怪兽效果或「罪宝」魔法·陷阱卡效果而发动魔法·陷阱·怪兽效果，且该对方效果可以被无效。满足时才能从墓地发动本效果。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：对方发动的这个连锁效果（ev）必须能够被无效，且发动者是对方（rp为对方回合玩家），否则②不能发动。
	if not Duel.IsChainDisablable(ev) or rp~=1-tp then return false end
	-- 获取被对方连锁的那个自己效果的连锁信息（ev-1），得到其效果对象te和发动玩家p，用于验证它是否是自己符合条件的「迪亚贝尔斯塔尔」或「罪宝」效果。
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if not te or p~=tp then return false end
	local tc=te:GetHandler()
	return tc:IsSetCard(0x119b) and te:IsActiveType(TYPE_MONSTER) or tc:IsSetCard(0x19e)
		and te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义②效果的target：由于发动条件已在condition中判断，这里直接允许发动，并设置操作信息：将对方发动的这个效果（eg）作为无效化对象。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明本次处理将无效对方发动的效果（eg），类别为CATEGORY_DISABLE，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义②效果的结算：直接无效对方发动的那个连锁效果。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 将编号为ev的连锁效果无效化。
	Duel.NegateEffect(ev)
end
