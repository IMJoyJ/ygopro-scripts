--7
-- 效果：
-- 当自己场上凑齐3张以表侧表示存在的「7」时，自己抽3张卡。之后，所有的「7」被破坏。当这张卡从场上被送去墓地时，自己回复700基本分。
function c67048711.initial_effect(c)
	-- 当自己场上凑齐3张以表侧表示存在的「7」时，自己抽3张卡。之后，所有的「7」被破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c67048711.target)
	e1:SetOperation(c67048711.operation)
	c:RegisterEffect(e1)
	-- 当这张卡从场上被送去墓地时，自己回复700基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67048711,1))  --"回复"
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c67048711.reccon)
	e3:SetTarget(c67048711.rectg)
	e3:SetOperation(c67048711.recop)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选自己场上表侧表示存在的「7」
function c67048711.filter(c)
	return c:IsFaceup() and c:IsCode(67048711)
end
-- 魔法卡发动时的效果处理准备，若场上凑齐3张「7」则设置抽卡和破坏的操作信息
function c67048711.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查自己魔陷区表侧表示存在的「7」的数量是否等于3
	if Duel.GetMatchingGroupCount(c67048711.filter,tp,LOCATION_SZONE,0,nil)==3 then
		-- 获取自己场上所有表侧表示存在的「7」的卡片组
		local g=Duel.GetMatchingGroup(c67048711.filter,tp,LOCATION_ONFIELD,0,nil)
		-- 设置效果处理信息：玩家抽3张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
		-- 设置效果处理信息：破坏场上所有的「7」
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 魔法卡发动时的效果处理：若满足抽卡条件则抽3张卡，之后破坏场上所有的「7」
function c67048711.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁中是否设置了抽卡的操作信息（即发动时是否凑齐了3张「7」）
	local ex=Duel.GetOperationInfo(0,CATEGORY_DRAW)
	if ex then
		-- 让玩家因效果抽3张卡，并判断是否成功抽卡
		if Duel.Draw(tp,3,REASON_EFFECT)~=0 then
			-- 中断当前效果处理，使后续的破坏处理与抽卡不视为同时进行
			Duel.BreakEffect()
			-- 重新获取当前场上所有表侧表示存在的「7」的卡片组
			local g=Duel.GetMatchingGroup(c67048711.filter,tp,LOCATION_ONFIELD,0,nil)
			-- 以规则原因破坏所有获取到的「7」（无视代破和免疫效果）
			Duel.Destroy(g,REASON_RULE)
		end
	end
end
-- 触发条件：此卡此前存在于场上
function c67048711.reccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 回复效果的发动准备，设置回复对象玩家、回复数值及操作信息
function c67048711.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复效果的参数值为700
	Duel.SetTargetParam(700)
	-- 设置效果处理信息：玩家回复700基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,700)
end
-- 回复效果的实际处理，使目标玩家回复设定的基本分
function c67048711.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复基本分的操作
	Duel.Recover(p,d,REASON_EFFECT)
end
