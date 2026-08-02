--旧GMX第５研究所
-- 效果：
-- 自己把「GMX」怪兽召唤·特殊召唤时对方不能把卡的效果发动。
-- 自己主要阶段：可以从卡组把「GMX5号实验室」以外的1张「GMX」魔法·陷阱卡在自己场上盖放，那之后选1张手卡在卡组最上面放置。「GMX5号实验室」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 自己主要阶段：可以从卡组把「GMX5号实验室」以外的1张「GMX」魔法·陷阱卡在自己场上盖放，那之后选1张手卡在卡组最上面放置。「GMX5号实验室」的这个效果1回合只能使用1次。
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
	-- 自己主要阶段：可以从卡组把「GMX5号实验室」以外的1张「GMX」魔法·陷阱卡在自己场上盖放，那之后选1张手卡在卡组最上面放置。
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
-- 过滤条件：检查是否是自己召唤·特殊召唤的表侧表示「GMX」怪兽
function s.limfilter(c,tp)
	return c:IsSetCard(0x1dd) and c:IsSummonPlayer(tp) and c:IsFaceup()
end
-- 封锁效果的发动条件：检查是否存在符合条件的「GMX」怪兽的召唤·特殊召唤
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.limfilter,1,nil,tp)
end
-- 封锁效果的处理函数：当自己把「GMX」怪兽召唤·特殊召唤时，限制对方发动卡的效果
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsOnField() or c:IsFacedown() then return end
	-- 如果当前不在连锁中，即召唤·特殊召唤没有被连锁
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制，令对方不能发动卡的效果直到当前连锁串结束
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 如果当前已经在连锁中
	elseif Duel.GetCurrentChain()==1 then
		c:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 对方不能把卡的效果发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.limreset)
		-- 把卡片发动的事件注册给全局环境
		Duel.RegisterEffect(ge1,tp)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_BREAK_EFFECT)
		ge2:SetReset(RESET_CHAIN)
		-- 把BreakEffect中断调用的事件注册给全局环境
		Duel.RegisterEffect(ge2,tp)
	end
end
-- 移除标记并重置当前封锁处理相关的连续效果
function s.limreset(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id+o)
	e:Reset()
end
-- 连锁结束或特定时点恢复检查函数：如果卡片仍在场且有标记，则重新对对方封锁效果直到连锁结束
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsOnField() and not c:IsFacedown() and c:GetFlagEffect(id+o)~=0 then
		-- 限制对方发动卡的效果直到当前连锁串结束
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	c:ResetFlagEffect(id+o)
end
-- 限制连锁发动的条件：只有自己可以发动效果
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤条件：检查是否是卡组中「GMX5号实验室」以外的「GMX」魔法·陷阱卡且能盖放
function s.setfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id)
		and c:IsSSetable()
end
-- 起动效果的目标函数：检查卡组是否有符合条件的卡盖放，以及手卡是否有卡可放回卡组，并设置回卡组的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以盖放的符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 并且检查手卡中是否有可以放回卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	-- 设置从手卡将卡返回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 起动效果的处理函数：从卡组盖放1张指定卡，洗牌后将1张手卡放回卡组最上方
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张符合条件的「GMX」魔法或陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的卡盖放在自己场上
	Duel.SSet(tp,tc)
	-- 中断当前效果，使之后的效果处理视为不同时处理
	Duel.BreakEffect()
	-- 洗切卡组
	Duel.ShuffleDeck(tp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手卡中选择1张卡
	local hg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	local hc=hg:GetFirst()
	if hc then
		-- 将选中的手卡放置在卡组最上方
		Duel.SendtoDeck(hc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
