--海造賊－祝宴
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，②的效果在决斗中只能使用1次。
-- ①：自己场上有「海造贼」怪兽存在的场合才能把这张卡发动。自己从卡组抽出自己场上的装备卡的数量＋1张，那之后手卡选自己场上的装备卡的数量回到卡组。
-- ②：这张卡在墓地存在，自己从额外卡组把「海造贼」怪兽特殊召唤的场合才能发动。这张卡给那1只怪兽当作攻击力上升500的装备卡使用来装备。
function c43004235.initial_effect(c)
	-- ①：自己场上有「海造贼」怪兽存在的场合才能把这张卡发动。自己从卡组抽出自己场上的装备卡的数量＋1张，那之后手卡选自己场上的装备卡的数量回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43004235,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,43004235)
	e1:SetCondition(c43004235.condition)
	e1:SetTarget(c43004235.target)
	e1:SetOperation(c43004235.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己从额外卡组把「海造贼」怪兽特殊召唤的场合才能发动。这张卡给那1只怪兽当作攻击力上升500的装备卡使用来装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43004235,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_EQUIP)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,43004236+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(c43004235.eqcon)
	e2:SetTarget(c43004235.eqtg)
	e2:SetOperation(c43004235.eqop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「海造贼」怪兽（表侧表示）
function c43004235.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- 效果条件函数，判断自己场上是否存在「海造贼」怪兽
function c43004235.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只「海造贼」怪兽
	return Duel.IsExistingMatchingCard(c43004235.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断场上存在的装备卡（表侧表示或被装备的卡）
function c43004235.drfilter(c)
	return (c:IsFaceup() or c:GetEquipTarget()) and c:IsType(TYPE_EQUIP)
end
-- 效果目标函数，计算场上装备卡数量并设置抽卡和回卡组的数量
function c43004235.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上装备卡数量
	local i=Duel.GetMatchingGroupCount(c43004235.drfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 检查玩家是否可以抽i+1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,i+1) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为i+1
	Duel.SetTargetParam(i+1)
	-- 设置效果操作信息为抽卡效果，抽i+1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,i+1)
	-- 设置效果操作信息为回卡组效果，回i张卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,i)
end
-- 效果发动函数，执行抽卡和回卡组操作
function c43004235.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取场上装备卡数量
	local i=Duel.GetMatchingGroupCount(c43004235.drfilter,p,LOCATION_ONFIELD,0,nil)
	-- 执行抽卡效果，抽i+1张卡
	if Duel.Draw(p,i+1,REASON_EFFECT)==0 then return end
	if i>0 then
		-- 将玩家手牌洗切
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择玩家手牌中最多i张卡返回卡组
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,i,i,nil)
		if g:GetCount()>0 then
			-- 将选中的卡送回卡组
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于判断是否为从额外卡组特殊召唤的「海造贼」怪兽
function c43004235.exfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(tp) and c:IsSetCard(0x13f) and c:IsFaceup()
end
-- 效果条件函数，判断是否有从额外卡组特殊召唤的「海造贼」怪兽
function c43004235.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c43004235.exfilter,1,nil,tp)
end
-- 过滤函数，用于判断是否为特殊召唤的「海造贼」怪兽
function c43004235.eqfilter(c,g)
	return g:IsContains(c)
end
-- 装备效果目标函数，检查是否满足装备条件
function c43004235.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(c43004235.exfilter,nil,tp)
	-- 检查玩家场上是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
		-- 检查是否场上存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c43004235.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g) end
	-- 设置效果操作信息为墓地效果，将此卡加入操作对象
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 装备效果发动函数，执行装备操作
function c43004235.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家场上是否有足够的装备区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	if not c:IsRelateToEffect(e) or c:IsForbidden() or not c:CheckUniqueOnField(tp,LOCATION_SZONE) then return end
	local g=eg:Filter(c43004235.exfilter,nil,tp)
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上满足条件的怪兽进行装备
	local sg=Duel.SelectMatchingCard(tp,c43004235.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	local tc=sg:GetFirst()
	if tc then
		-- 显示选中的怪兽被选为对象
		Duel.HintSelection(sg)
		-- 执行装备操作
		if Duel.Equip(tp,c,tc) then
			-- 装备效果限制，限制只能装备给特定怪兽
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(tc)
			e1:SetValue(c43004235.eqlimit)
			c:RegisterEffect(e1)
			-- 装备效果，使装备卡攻击力上升500
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(500)
			c:RegisterEffect(e2)
		end
	end
end
-- 装备效果限制函数，限制只能装备给特定怪兽
function c43004235.eqlimit(e,c)
	return c==e:GetLabelObject()
end
