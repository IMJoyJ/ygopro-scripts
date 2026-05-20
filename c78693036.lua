--呪雷神ジュラ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，每次对方把卡的效果发动，自己回复300基本分。
-- ②：对方回合，可以支付1500基本分，把这张卡解放，从以下效果选择1个发动。
-- ●对方场上的表侧表示怪兽全部破坏。
-- ●对方场上的表侧表示的魔法·陷阱卡全部破坏。
local s,id,o=GetID()
-- 注册卡片初始效果（同调召唤手续、效果①的连锁监听与回复处理、效果②的对方回合解放破坏效果）
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，每次对方把卡的效果发动，自己回复300基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，每次对方把卡的效果发动，自己回复300基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.reccon)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
	-- ②：对方回合，可以支付1500基本分，把这张卡解放，从以下效果选择1个发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.descon)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 对方发动效果时，给自身卡片注册一个在当前连锁结算完毕前有效的标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 检查是否为对方发动了效果，且自身卡片带有对应的发动标记
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c:GetFlagEffect(id)~=0
end
-- 执行回复300基本分的效果处理
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家展示本卡片以提示效果发动
	Duel.Hint(HINT_CARD,0,id)
	-- 自己回复300基本分
	Duel.Recover(tp,300,REASON_EFFECT)
end
-- 检查当前是否为对方回合
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果②的发动代价：检查并支付1500基本分，并将这张卡解放
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查玩家是否能支付1500基本分，且自身是否可以解放
	if chk==0 then return Duel.CheckLPCost(tp,1500) and e:GetHandler():IsReleasable() end
	-- 支付1500基本分
	Duel.PayLPCost(tp,1500)
	-- 将这张卡解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤对方场上表侧表示的魔法·陷阱卡
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果②的发动准备：检查并让玩家选择要破坏的卡片类型，并设置对应的破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧表示的怪兽
	local b1=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方场上是否存在表侧表示的魔法·陷阱卡
	local b2=Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	-- 让玩家选择要发动的效果分支（破坏怪兽或破坏魔陷）
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"破坏怪兽"
		{b2,aux.Stringid(id,2),2})  --"破坏魔陷"
	e:SetLabel(op)
	local g=Group.CreateGroup()
	if op==1 then
		-- 获取对方场上所有表侧表示的怪兽
		g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	elseif op==2 then
		-- 获取对方场上所有表侧表示的魔法·陷阱卡
		g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	end
	if #g>0 then
		-- 设置破坏对应卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	end
end
-- 效果②的效果处理：根据选择的分支，破坏对方场上对应的全部表侧表示卡片
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	if e:GetLabel()==1 then
		-- 获取对方场上所有表侧表示的怪兽
		g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	elseif e:GetLabel()==2 then
		-- 获取对方场上所有表侧表示的魔法·陷阱卡
		g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	end
	-- 破坏选中的卡片
	Duel.Destroy(g,REASON_EFFECT)
end
