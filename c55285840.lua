--クロノダイバー・リダン
-- 效果：
-- 4星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方的准备阶段才能发动。把对方卡组最上面的卡作为这张卡的超量素材。
-- ②：自己·对方回合可以发动。这张卡的超量素材最多3种类（怪兽·魔法·陷阱）取除。那之后，那些种类的以下效果适用。
-- ●怪兽：这张卡直到结束阶段除外。
-- ●魔法：自己抽1张。
-- ●陷阱：对方场上1张表侧表示卡回到卡组最上面。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function c55285840.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	-- ①：自己·对方的准备阶段才能发动。把对方卡组最上面的卡作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55285840,0))  --"补充超量素材"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c55285840.mattg)
	e1:SetOperation(c55285840.matop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合可以发动。这张卡的超量素材最多3种类（怪兽·魔法·陷阱）取除。那之后，那些种类的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55285840,1))  --"取除超量素材"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,55285840)
	e2:SetTarget(c55285840.target)
	e2:SetOperation(c55285840.operation)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件与目标检查函数
function c55285840.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否为XYZ怪兽，且对方卡组是否有卡
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 end
	-- 向对方玩家提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的效果处理函数
function c55285840.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	if c:IsRelateToEffect(e) and g:GetCount()==1 then
		local tc=g:GetFirst()
		-- 禁用接下来的洗牌检测，防止因操作卡组顶端的卡而导致系统自动洗牌
		Duel.DisableShuffleCheck()
		if tc:IsCanOverlay() then
			-- 将获取的卡作为超量素材叠放在这张卡下方
			Duel.Overlay(c,g)
		else
			-- 若无法作为超量素材叠放，则根据规则送去墓地
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end
end
-- 过滤对方场上表侧表示且能回到卡组的卡的条件函数
function c55285840.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
-- 效果②的发动条件与目标检查函数
function c55285840.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		if not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return false end
		local g=c:GetOverlayGroup()
		if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
			and c:IsAbleToRemove() then return true end
		if g:IsExists(Card.IsType,1,nil,TYPE_SPELL)
			-- 检查超量素材中是否有魔法卡，且自己是否可以抽卡
			and Duel.IsPlayerCanDraw(tp,1) then return true end
		if g:IsExists(Card.IsType,1,nil,TYPE_TRAP)
			-- 检查超量素材中是否有陷阱卡，且对方场上是否存在可以回到卡组的表侧表示卡
			and Duel.IsExistingMatchingCard(c55285840.tgfilter,tp,0,LOCATION_ONFIELD,1,nil) then return true end
		return false
	end
	-- 向对方玩家提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 检查选取的超量素材组中，怪兽、魔法、陷阱卡各不超过1张的过滤函数
function c55285840.check(g)
	return g:FilterCount(Card.IsType,nil,TYPE_MONSTER)<=1
		and g:FilterCount(Card.IsType,nil,TYPE_SPELL)<=1
		and g:FilterCount(Card.IsType,nil,TYPE_TRAP)<=1
end
-- 效果②的效果处理函数
function c55285840.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return end
	local g=c:GetOverlayGroup()
	local tg=Group.CreateGroup()
	if c:IsAbleToRemove() then
		tg:Merge(g:Filter(Card.IsType,nil,TYPE_MONSTER))
	end
	-- 检查自己是否可以抽卡，以决定是否能将魔法卡作为可选的取除素材
	if Duel.IsPlayerCanDraw(tp,1) then
		tg:Merge(g:Filter(Card.IsType,nil,TYPE_SPELL))
	end
	-- 检查对方场上是否有满足条件的表侧表示卡，以决定是否能将陷阱卡作为可选的取除素材
	if Duel.IsExistingMatchingCard(c55285840.tgfilter,tp,0,LOCATION_ONFIELD,1,nil) then
		tg:Merge(g:Filter(Card.IsType,nil,TYPE_TRAP))
	end
	-- 提示玩家选择要取除的超量素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	local sg=tg:SelectSubGroup(tp,c55285840.check,false,1,3)
	if not sg then return end
	-- 将选中的超量素材送去墓地（即取除素材）
	Duel.SendtoGrave(sg,REASON_EFFECT)
	-- 触发“超量素材被取除”的单体时点
	Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	if sg:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then
		-- 中断当前效果处理，使后续的适用效果与取除素材不视为同时处理
		Duel.BreakEffect()
		-- 尝试将这张卡暂时除外，并确认除外成功且卡片未改变
		if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
			-- ●怪兽：这张卡直到结束阶段除外。●魔法：自己抽1张。●陷阱：对方场上1张表侧表示卡回到卡组最上面。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(c)
			e1:SetCountLimit(1)
			e1:SetOperation(c55285840.retop)
			-- 注册在结束阶段将这张卡返回场上的延迟效果
			Duel.RegisterEffect(e1,tp)
		end
	end
	if sg:IsExists(Card.IsType,1,nil,TYPE_SPELL) then
		-- 中断当前效果处理，使后续的抽卡效果不与前面的效果视为同时处理
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if sg:IsExists(Card.IsType,1,nil,TYPE_TRAP) then
		-- 中断当前效果处理，使后续的弹回卡组效果不与前面的效果视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 玩家选择对方场上1张表侧表示的卡
		local dg=Duel.SelectMatchingCard(tp,c55285840.tgfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 将选中的卡送回持有者卡组的最上面
		Duel.SendtoDeck(dg,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- 暂时除外的卡在结束阶段返回场上的效果处理函数
function c55285840.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的这张卡返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
