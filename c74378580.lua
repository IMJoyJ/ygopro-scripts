--旧GMX第５研究所
-- 效果：
-- 自己把「GMX」怪兽召唤·特殊召唤时对方不能把卡的效果发动。
-- 自己主要阶段：可以从卡组把「GMX5号实验室」以外的1张「GMX」魔法·陷阱卡在自己场上盖放，那之后选1张手卡在卡组最上面放置。「GMX5号实验室」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①「GMX」怪兽召·特召成功时连锁封锁效果、②从卡组盖放「GMX」魔陷并手卡置顶效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己把「GMX」怪兽召唤·特殊召唤时，对方不能把卡的效果发动。
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
	-- 注册连锁结束监听：重置召唤·特殊召唤成功的连锁封锁限制
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.limop2)
	c:RegisterEffect(e3)
	-- ②：自己主要阶段才能发动。从卡组把同名卡以外的1张「GMX」魔法·陷阱卡在自己场上盖放。那之后，选1张手牌在卡组最上面放置。
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
-- 连锁封锁过滤条件：自己召唤·特殊召唤成功的表侧表示「GMX」怪兽
function s.limfilter(c,tp)
	return c:IsSetCard(0x1dd) and c:IsSummonPlayer(tp) and c:IsFaceup()
end
-- ①效果触发条件：本次召唤·特召的怪兽中存在符合条件的「GMX」怪兽
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.limfilter,1,nil,tp)
end
-- 连锁封锁处理：在当前连锁结算完毕前禁止对方发动卡的效果
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsOnField() or c:IsFacedown() then return end
	-- 判断当前是否处于连锁0（非连锁中召·特召）
	if Duel.GetCurrentChain()==0 then
		-- 直接封锁至本连锁/动作结束（对方不能发动效果）
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 判断当前是否处于连锁1（连锁中召·特召）
	elseif Duel.GetCurrentChain()==1 then
		c:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 注册全局监听：在连锁处理过程中保持封锁状态，并在连锁结束后恢复正常
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.limreset)
		-- 注册连锁发动监听全局效果
		Duel.RegisterEffect(ge1,tp)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_BREAK_EFFECT)
		ge2:SetReset(RESET_CHAIN)
		-- 注册效果中途中断监听全局效果
		Duel.RegisterEffect(ge2,tp)
	end
end
-- 若有后续连锁动作，重置Flag标记并清理全局监听效果
function s.limreset(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id+o)
	e:Reset()
end
-- 连锁结束处理：若仍在场上且存在Flag标记，施加封锁限制直至连锁结束
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsOnField() and not c:IsFacedown() and c:GetFlagEffect(id+o)~=0 then
		-- 封锁限制：连锁结束前对方不能发动卡的效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	c:ResetFlagEffect(id+o)
end
-- 连锁限制判定：只允许发动效果的玩家（自己）继续发动效果，禁止对方发动
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 盖放卡片过滤条件：同名卡以外的「GMX」魔法·陷阱卡且可在场上盖放
function s.setfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id)
		and c:IsSSetable()
end
-- ②效果发动准备：设置将卡片返回卡组顶的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组是否存在可盖放的「GMX」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 发动条件检查：手牌中是否存在可返回卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁操作信息：把手牌1张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理：从卡组盖放1张「GMX」魔法·陷阱卡，并将1张手牌置于卡组最上方
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足条件的「GMX」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 在己方场上盖放选中的魔法·陷阱卡
	Duel.SSet(tp,tc)
	-- 连接效果块（分隔卡片盖放与手卡置顶）
	Duel.BreakEffect()
	-- 洗混卡组
	Duel.ShuffleDeck(tp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手牌选择1张卡
	local hg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	local hc=hg:GetFirst()
	if hc then
		-- 将选中的手牌放置在卡组最上方
		Duel.SendtoDeck(hc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
