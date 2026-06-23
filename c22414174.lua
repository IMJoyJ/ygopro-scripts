--シンクロ・クリード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：场上有同调怪兽存在的场合才能发动。自己抽1张。场上有同调怪兽3只以上存在的场合，再让自己可以抽1张。
local s,id,o=GetID()
-- 创建并注册同调贪欲的发动效果
function s.initial_effect(c)
	-- ①：场上有同调怪兽存在的场合才能发动。自己抽1张。场上有同调怪兽3只以上存在的场合，再让自己可以抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于检测场上是否存在表侧表示的同调怪兽
function s.filter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 判断发动条件：场上有至少1只同调怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1只同调怪兽
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 设置效果目标：玩家抽1张卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果目标参数为1
	Duel.SetTargetParam(1)
	-- 设置操作信息为玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果发动时的处理函数，执行抽卡和二次抽卡判断
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行第一次抽卡并判断是否成功抽卡且玩家可以再抽卡
	if Duel.Draw(p,d,REASON_EFFECT)>0 and Duel.IsPlayerCanDraw(p,1)
		-- 判断场上有3只或以上同调怪兽存在
		and Duel.GetMatchingGroupCount(s.filter,p,LOCATION_MZONE,LOCATION_MZONE,nil)>=3
		-- 询问玩家是否再抽1张卡
		and Duel.SelectYesNo(p,aux.Stringid(id,0)) then  --"是否再抽1张？"
		-- 中断当前效果，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 执行第二次抽卡
		Duel.Draw(p,1,REASON_EFFECT)
	end
end
