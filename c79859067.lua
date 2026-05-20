--R.B. Next Phase
-- 效果：
-- 自己场上有「奏悦机组」怪兽存在，对方把怪兽的效果发动时：自己场上1只怪兽破坏，那个发动无效并破坏，那之后，自己回复2000基本分。
-- 「奏悦机组 阶段转换」在1回合只能发动1张。
local s,id,o=GetID()
-- 定义卡片效果初始化函数
function s.initial_effect(c)
	-- 自己场上有「奏悦机组」怪兽存在，对方把怪兽的效果发动时：自己场上1只怪兽破坏，那个发动无效并破坏，那之后，自己回复2000基本分。「奏悦机组 阶段转换」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「奏悦机组」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf)
end
-- 效果发动条件判定函数
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「奏悦机组」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查发动的效果是否为怪兽效果，且该发动能否被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and rp==1-tp
end
-- 效果发动时的目标选择与操作信息设置函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 获取自己场上的所有怪兽
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	if re:GetHandler():IsRelateToEffect(re) then
		g:Merge(eg)
	end
	-- 设置操作信息：破坏自己场上的怪兽以及对方发动的怪兽卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：自己回复2000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
-- 效果处理的执行函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 获取自己场上所有的怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显式示出被选择破坏的卡
		Duel.HintSelection(sg)
		-- 破坏自己场上选择的1只怪兽，若成功破坏则继续处理
		if Duel.Destroy(sg,REASON_EFFECT)~=0
			-- 使该怪兽效果的发动无效
			and Duel.NegateActivation(ev)
			and ec:IsRelateToChain(ev)
			-- 破坏那张发动效果的怪兽卡，若成功破坏则继续处理
			and Duel.Destroy(ec,REASON_EFFECT)~=0 then
			-- 中断当前效果处理，使后续的回复基本分处理不与前面的破坏视为同时处理
			Duel.BreakEffect()
			-- 自己回复2000基本分
			Duel.Recover(tp,2000,REASON_EFFECT)
		end
	end
end
