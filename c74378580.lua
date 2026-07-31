--旧GMX第５研究所
-- 效果：
-- 自己把「GMX」怪兽召唤·特殊召唤时对方不能把卡的效果发动。
-- 自己主要阶段：可以从卡组把「GMX5号实验室」以外的1张「GMX」魔法·陷阱卡在自己场上盖放，那之后选1张手卡在卡组最上面放置。「GMX5号实验室」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册发动卡片、召唤/特召防连锁限制效果以及卡组盖放魔法陷阱的起动效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 初始化卡片效果：注册自己召唤·特殊召唤「GMX」怪兽时封锁对方响应发动的场上持续效果
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
	-- 初始化卡片效果：注册连锁结束时解除/应用连锁封锁检查的持续效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.limop2)
	c:RegisterEffect(e3)
	-- 初始化卡片效果：注册主要阶段从卡组盖放1张同名卡以外的「GMX」魔陷并将1张手牌置于卡组顶端的起动效果
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
-- 召唤/特召过滤条件：属于「GMX」字段、由自己召唤/特召且表侧表示
function s.limfilter(c,tp)
	return c:IsSetCard(0x1dd) and c:IsSummonPlayer(tp) and c:IsFaceup()
end
-- 封锁连锁发动条件：存在满足条件的「GMX」怪兽被召唤/特殊召唤
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.limfilter,1,nil,tp)
end
-- 封锁连锁效果处理：在连锁0时直接禁止对方连锁响应，连锁1时注册标记及监听效果以便在连锁结束时封锁
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsOnField() or c:IsFacedown() then return end
	-- 判断当前连锁数是否为0
	if Duel.GetCurrentChain()==0 then
		-- 限制直到连锁结束为止对方不能响应发动卡的效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 判断当前连锁数是否为1
	elseif Duel.GetCurrentChain()==1 then
		c:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 注册在连锁生成或效果中断时清除封锁标记的全局监听效果
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.limreset)
		-- 注册监听新的连锁发生的全局效果
		Duel.RegisterEffect(ge1,tp)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_BREAK_EFFECT)
		ge2:SetReset(RESET_CHAIN)
		-- 注册监听连锁中效果中断事件的全局效果
		Duel.RegisterEffect(ge2,tp)
	end
end
-- 清除标记回调：重置卡片的Flag标记并重置自身监听效果
function s.limreset(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id+o)
	e:Reset()
end
-- 连锁结束处理：在连锁结束时，若持有Flag标记则限制对方不能响应
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsOnField() and not c:IsFacedown() and c:GetFlagEffect(id+o)~=0 then
		-- 设置连锁限制：直到连锁结束前对方不能响应发动卡的效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	c:ResetFlagEffect(id+o)
end
-- 连锁限制判定函数：仅允许发动玩家继续连锁，禁止对方响应
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 卡组盖放卡片过滤条件：属于「GMX」字段的魔法·陷阱卡、非同名卡且可以在场上盖放
function s.setfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id)
		and c:IsSSetable()
end
-- 盖放效果发动准备：检查卡组是否存在可盖放的「GMX」魔陷且手牌存在可送回卡组的卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的「GMX」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查手牌是否存在可以放回卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁操作信息：将1张手牌放回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 盖放效果处理：从卡组盖放1张「GMX」魔陷，之后将1张手牌置于卡组最顶端
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足条件的「GMX」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选择的卡在自己场上盖放
	Duel.SSet(tp,tc)
	-- 分隔前后效果的处理阶段
	Duel.BreakEffect()
	-- 洗切卡组
	Duel.ShuffleDeck(tp)
	-- 提示玩家选择要放回卡组顶端的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手牌中选择1张卡
	local hg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	local hc=hg:GetFirst()
	if hc then
		-- 将选择的手牌放到卡组最上面
		Duel.SendtoDeck(hc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
