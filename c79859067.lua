--R.B.ネクスト・フェーズ
-- 效果：
-- 自己场上有「奏悦机组」怪兽存在，对方把怪兽的效果发动时：自己场上1只怪兽破坏，那个发动无效并破坏，那之后，自己回复2000基本分。
-- 「奏悦机组 阶段转换」在1回合只能发动1张。
local s,id,o=GetID()
-- 初始化效果
function s.initial_effect(c)
	-- 自己场上有「奏悦机组」怪兽存在，对方把怪兽的效果发动时：自己场上1只怪兽破坏，那个发动无效并破坏，那之后，自己回复2000基本分。
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
-- 过滤条件：表侧表示且是「奏悦机组」卡
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf)
end
-- 效果条件：己方场上有表侧表示的「奏悦机组」怪兽，且对方发动了怪兽效果
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1张表侧表示的「奏悦机组」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查发动的效果是否为怪兽效果，并且该发动可以被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and rp==1-tp
end
-- 效果目标：设置无效该发动、破坏己方怪兽以及回复2000基本分的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效发动的效果
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 获取己方场上所有的怪兽卡
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	if re:GetHandler():IsRelateToEffect(re) then
		g:Merge(eg)
	end
	-- 设置操作信息：破坏己方场上的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：自己回复2000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
-- 效果处理：选己方场上1只怪兽破坏，无效对方的怪兽效果发动并破坏，那之后回复2000基本分
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 获取己方场上所有的怪兽卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家：请选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 为选中的即将破坏的怪兽显示对象动画
		Duel.HintSelection(sg)
		-- 如果成功破坏了玩家选中的怪兽
		if Duel.Destroy(sg,REASON_EFFECT)~=0
			-- 并且成功无效了对方发动的效果
			and Duel.NegateActivation(ev)
			and ec:IsRelateToChain(ev)
			-- 并且成功破坏了对方发动的卡，则执行下一步
			and Duel.Destroy(ec,REASON_EFFECT)~=0 then
			-- 中断当前效果，使得之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 自己回复2000基本分
			Duel.Recover(tp,2000,REASON_EFFECT)
		end
	end
end
