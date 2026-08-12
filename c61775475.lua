--A・O・G リターンゼロ
-- 效果：
-- 暗属性调整＋调整以外的怪兽1只以上
-- ①：对方把怪兽的效果发动时，把属性和那只怪兽相同的1只怪兽从自己墓地除外才能发动（这个回合，不能为这个卡名的这个效果发动而把相同属性的怪兽除外）。那个发动无效并破坏。
-- ②：1回合1次，以自己的墓地·除外状态的最多6只「次世代」怪兽为对象才能发动（相同属性最多1只）。那些怪兽回到卡组。那之后，可以把最多有那个数量的魔法与陷阱区域的卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、①效果（无效并破坏）和②效果（回收并破坏魔陷）
function s.initial_effect(c)
	-- 设置同调召唤手续：暗属性调整 + 调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：对方把怪兽的效果发动时，把属性和那只怪兽相同的1只怪兽从自己墓地除外才能发动（这个回合，不能为这个卡名的这个效果发动而把相同属性的怪兽除外）。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动无效"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.ngcon)
	e1:SetCost(s.ngcost)
	e1:SetTarget(s.ngtg)
	e1:SetOperation(s.ngop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己的墓地·除外状态的最多6只「次世代」怪兽为对象才能发动（相同属性最多1只）。那些怪兽回到卡组。那之后，可以把最多有那个数量的魔法与陷阱区域的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数：用于作为发动Cost，从墓地除外的与发动效果怪兽属性相同的怪兽
function s.cfilter(c,att)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(att)
end
-- ①效果的发动条件：对方发动怪兽效果，且该发动可以被无效
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的怪兽效果，自身未被战斗破坏，且该连锁的发动可以被无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- ①效果的发动Cost：将1只与发动效果怪兽相同属性的怪兽从自己墓地除外，并注册本回合不能再除外相同属性怪兽的限制
function s.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local att=re:GetHandler():GetAttribute()
	-- Cost检查：检查自己墓地是否存在可以作为Cost除外的、与发动效果怪兽属性相同的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,att) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1只与发动效果怪兽属性相同的墓地怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,att)
	e:SetLabel(g:GetFirst():GetAttribute())
	-- 将选中的怪兽作为Cost表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- ①：对方把怪兽的效果发动时，把属性和那只怪兽相同的1只怪兽从自己墓地除外才能发动（这个回合，不能为这个卡名的这个效果发动而把相同属性的怪兽除外）。那个发动无效并破坏。②：1回合1次，以自己的墓地·除外状态的最多6只「次世代」怪兽为对象才能发动（相同属性最多1只）。那些怪兽回到卡组。那之后，可以把最多有那个数量的魔法与陷阱区域的卡破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.rmlimit)
	e1:SetLabel(e:GetLabel())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该玩家本回合不能再除外相同属性怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- ①效果的Target：设置无效与破坏的操作信息
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①效果的Operation：使发动无效并破坏
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡在连锁中关系成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 限制条件函数：限制本卡名的效果发动时不能除外相同属性的怪兽
function s.rmlimit(e,c,tp,r,re)
	return c:IsAttribute(e:GetLabel()) and re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsCode(id) and r==REASON_COST
end
-- 过滤函数：用于作为②效果对象的、自己墓地或除外状态的表侧表示「次世代」怪兽
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2) and c:IsAbleToDeck() and c:IsFaceup()
end
-- 过滤函数：用于作为破坏对象的、魔法与陷阱区域的卡（格子序号小于5）
function s.desfilter(c)
	return c:GetSequence()<5
end
-- ②效果的Target：选择最多6只不同属性的「次世代」怪兽作为对象，并设置回到卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查是否存在至少1只符合条件的「次世代」怪兽可以作为对象
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 获取自己墓地及除外状态中所有符合条件的「次世代」怪兽
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择1到6只属性互不相同的「次世代」怪兽
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,6)
	-- 将选中的怪兽注册为效果的对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息：将选中的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
end
-- ②效果的Operation：将对象怪兽送回卡组，之后可以破坏最多有那个数量的魔法与陷阱区域的卡
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与该效果关系成立的对象怪兽
	local tg=Duel.GetTargetsRelateToChain()
	if #tg==0 then return end
	-- 将这些怪兽送回卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际回到卡组的卡片组
	local g=Duel.GetOperatedGroup()
	local ct=g:GetCount()
	-- 获取场上魔法与陷阱区域的所有卡
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 如果有卡成功回到卡组、场上有可破坏的魔陷，且玩家选择发动破坏效果
	if ct>0 and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否破坏魔法·陷阱区域的卡？"
		-- 中断当前效果处理，使后续的破坏处理不与回到卡组同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg2=dg:Select(tp,1,ct,nil)
		-- 手动显示被选择破坏的卡片的动画效果
		Duel.HintSelection(sg2)
		-- 破坏选中的魔法·陷阱卡
		Duel.Destroy(sg2,REASON_EFFECT)
	end
end
