--GMX Lab #5
-- 效果：
-- 自己把「GMX」怪兽召唤·特殊召唤时对方不能把卡的效果发动。
-- 自己主要阶段：可以从卡组把「GMX5号实验室」以外的1张「GMX」魔法·陷阱卡在自己场上盖放，那之后选1张手卡在卡组最上面放置。「GMX5号实验室」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册表侧发动效果、召唤/特殊召唤成功的事件监听效果、连锁结束监听效果以及盖放卡片并返回手卡至卡组的效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 自己把「GMX」怪兽召唤·特殊召唤时对方不能把卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.limcon)
	e1:SetOperation(s.limop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 自己把「GMX」怪兽召唤·特殊召唤时对方不能把卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.limop2)
	c:RegisterEffect(e3)
	-- 自己主要阶段：可以从卡组把「GMX5号实验室」以外的1张「GMX」魔法·陷阱卡在自己场上盖放，那之后选1张手卡在卡组最上面放置。「GMX5号实验室」的这个效果1回合只能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"盖放"
	e4:SetCategory(CATEGORY_SSET+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 过滤条件：属于「GMX」系列且由自己召唤并表侧表示存在的怪兽
function s.limfilter(c,tp)
	return c:IsSetCard(0x1dd) and c:IsSummonPlayer(tp) and c:IsFaceup()
end
-- 判断召唤/特殊召唤成功的是否是自己的「GMX」怪兽
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.limfilter,1,nil,tp)
end
-- 在召唤/特殊召唤成功时，应用阻止对方发动卡片效果的连锁限制
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsOnField() or c:IsFacedown() then return end
	-- 如果当前没有处理的连锁（即召唤在连锁外成功）
	if Duel.GetCurrentChain()==0 then
		-- 设置直到连锁结束前对方无法响应我方发动卡片的效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 如果正处于连锁处理中（召唤在连锁中成功）
	elseif Duel.GetCurrentChain()==1 then
		c:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 自己把「GMX」怪兽召唤·特殊召唤时对方不能把卡的效果发动。自己主要阶段：可以从卡组把「GMX5号实验室」以外的1张「GMX」魔法·陷阱卡在自己场上盖放，那之后选1张手卡在卡组最上面放置。「GMX5号实验室」的这个效果1回合只能使用1次。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.limreset)
		-- 注册全局效果：用于在其它效果发动时重置标记
		Duel.RegisterEffect(ge1,tp)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_BREAK_EFFECT)
		ge2:SetReset(RESET_CHAIN)
		-- 克隆注册全局效果：用于在效果处理中断时重置标记
		Duel.RegisterEffect(ge2,tp)
	end
end
-- 重置当前卡片的连锁标记并使该重置效果自身失效
function s.limreset(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id+o)
	e:Reset()
end
-- 连锁结束时的效果处理：如果满足标记条件，则在连锁结束时应用连锁限制
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsOnField() and not c:IsFacedown() and c:GetFlagEffect(id+o)~=0 then
		-- 设置连锁限制，直到连锁结束前对手不能发动卡片的效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	c:ResetFlagEffect(id+o)
end
-- 过滤函数：限制只有自己可以发动卡片效果（对方不能响应）
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤条件：卡组中除同名卡以外的「GMX」魔法·陷阱卡，且满足盖放条件
function s.setfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id)
		and c:IsSSetable()
end
-- 效果的发动可行性检查及操作信息设定
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 可行性检查：自己卡组中是否存在可盖放的「GMX」魔陷卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 可行性检查：手牌中是否存在可以放回卡组的卡片
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：将1张手牌送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果的实际处理逻辑
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择需要盖放的魔陷卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「GMX」魔陷卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的卡片在自己场上盖放
	Duel.SSet(tp,tc)
	-- 中断效果处理，视为不同时处理
	Duel.BreakEffect()
	-- 手动洗切自己的卡组
	Duel.ShuffleDeck(tp)
	-- 提示玩家选择要返回卡组的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1张手牌
	local hg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	local hc=hg:GetFirst()
	if hc then
		-- 将选中的手牌送回卡组最上方
		Duel.SendtoDeck(hc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
