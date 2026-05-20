--埋蔵金の地図
-- 效果：
-- 要让盖放的这张卡回到手卡的效果发动时才能发动。从自己卡组抽2张卡，那之后丢弃1张手卡。
function c54762426.initial_effect(c)
	-- 要让盖放的这张卡回到手卡的效果发动时才能发动。从自己卡组抽2张卡，那之后丢弃1张手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c54762426.condition)
	e1:SetTarget(c54762426.target)
	e1:SetOperation(c54762426.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：触发连锁的效果是否包含将此卡送回手卡的操作
function c54762426.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发连锁中关于“加入手卡”的操作信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	return ex and tg~=nil and tg:IsContains(e:GetHandler())
end
-- 效果发动的目标确认与操作信息注册
function c54762426.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为2（抽卡张数）
	Duel.SetTargetParam(2)
	-- 注册效果处理包含“抽卡”分类，预计由自己抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 注册效果处理包含“丢弃手卡”分类，预计由自己丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果处理：执行抽卡，并在之后丢弃手卡
function c54762426.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，若成功抽了2张卡，则继续处理后续效果
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		-- 中断当前效果处理，使后续的丢弃手卡与抽卡不视为同时处理
		Duel.BreakEffect()
		-- 让玩家选择并因效果丢弃1张手卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
