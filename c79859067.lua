--R.B.ネクスト・フェーズ
-- 效果：
-- 自己场上有「奏悦机组」怪兽存在，对方把怪兽的效果发动时：自己场上1只怪兽破坏，那个发动无效并破坏，那之后，自己回复2000基本分。
-- 「奏悦机组 阶段转换」在1回合只能发动1张。
local s,id,o=GetID()
-- 初始化卡片效果：注册对方怪兽效果发动时破坏己方怪兽、无效并破坏该效果、恢复LP的陷阱发动效果
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
-- 过滤条件：场上表侧表示的「奏悦机组」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf)
end
-- 发动条件检查：己方场上有表侧「奏悦机组」怪兽，且对方发动的怪兽效果可被无效
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「奏悦机组」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查引发连锁的效果是否为怪兽效果且该发动可被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and rp==1-tp
end
-- 发动准备：设置无效发动、破坏己方及对方卡片、回复LP的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：无效目标效果的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 获取自己场上的所有怪兽
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	if re:GetHandler():IsRelateToEffect(re) then
		g:Merge(eg)
	end
	-- 设置连锁操作信息：破坏卡片（包含自己场上怪兽及对方发动效果的卡）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置连锁操作信息：自己回复2000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
-- 效果处理：破坏自己场上1只怪兽，无效对方效果发动并破坏，随后回复2000基本分
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 获取自己场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 高亮显示选中的怪兽
		Duel.HintSelection(sg)
		-- 破坏自己选中的1只怪兽
		if Duel.Destroy(sg,REASON_EFFECT)~=0
			-- 无效对方怪兽效果的发动
			and Duel.NegateActivation(ev)
			and ec:IsRelateToChain(ev)
			-- 破坏发动的对方怪兽
			and Duel.Destroy(ec,REASON_EFFECT)~=0 then
			-- 连接效果块（分隔破坏与回复LP的处理）
			Duel.BreakEffect()
			-- 自己回复2000基本分
			Duel.Recover(tp,2000,REASON_EFFECT)
		end
	end
end
