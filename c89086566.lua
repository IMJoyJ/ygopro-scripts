--機雷化
-- 效果：
-- 自己场上表侧表示存在的「栗子球」以及「栗子球衍生物」全部破坏。那之后，选最多有和破坏数量相同数量的对方场上的卡破坏。
function c89086566.initial_effect(c)
	-- 将「栗子球」的卡片密码注册到本卡的关联卡片列表中
	aux.AddCodeList(c,40640057)
	-- 自己场上表侧表示存在的「栗子球」以及「栗子球衍生物」全部破坏。那之后，选最多有和破坏数量相同数量的对方场上的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c89086566.target)
	e1:SetOperation(c89086566.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「栗子球」或「栗子球衍生物」
function c89086566.cfilter(c)
	return c:IsFaceup() and c:IsCode(40640057,40703223)
end
-- 效果发动的目标过滤与检测函数
function c89086566.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：自己场上存在至少1张表侧表示的「栗子球」或「栗子球衍生物」
	if chk==0 then return Duel.IsExistingMatchingCard(c89086566.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 且对方场上存在至少1张卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取自己场上所有表侧表示的「栗子球」及「栗子球衍生物」的卡片组
	local g=Duel.GetMatchingGroup(c89086566.cfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 设置效果处理信息：破坏自己场上的这些卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：执行破坏自己场上的卡，并根据破坏数量选择并破坏对方场上的卡
function c89086566.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时自己场上表侧表示的「栗子球」及「栗子球衍生物」的卡片组
	local g=Duel.GetMatchingGroup(c89086566.cfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 破坏自己场上的这些卡，并获取实际破坏的数量
	local dt=Duel.Destroy(g,REASON_EFFECT)
	if dt==0 then return end
	-- 获取对方场上所有的卡片组
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if dg:GetCount()>0 then
		-- 中断效果处理，使前后的破坏处理不视为同时进行（会造成错时点）
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=dg:Select(tp,1,dt,nil)
		-- 在场上对选中的卡进行闪烁提示
		Duel.HintSelection(sg)
		-- 破坏选中的对方场上的卡
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
