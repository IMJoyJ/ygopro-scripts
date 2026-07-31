--旧GMX第５研究所
-- 效果：
-- 自己把「GMX」怪兽召唤·特殊召唤时对方不能把卡的效果发动。
-- 自己主要阶段：可以从卡组把「GMX5号实验室」以外的1张「GMX」魔法·陷阱卡在自己场上盖放，那之后选1张手卡在卡组最上面放置。「GMX5号实验室」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①己方「GMX」怪兽召·特召成功时对方封锁效果发动、②从卡组盖放「GMX」魔陷并置顶1张手牌效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己把「GMX」怪兽召唤·特殊召唤时对方不能把卡的效果发动。
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
	-- 连锁结束时检测召·特召标志，在合适时机限制对方连锁
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.limop2)
	c:RegisterEffect(e3)
	-- ②：自己主要阶段：可以从卡组把「GMX5号实验室」以外的1张「GMX」魔法·陷阱卡在自己场地盖放，那之后选1张手卡在卡组最上面放置。
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
-- 过滤条件：自己场上表侧表示召唤·特殊召唤的「GMX」怪兽
function s.limfilter(c,tp)
	return c:IsSetCard(0x1dd) and c:IsSummonPlayer(tp) and c:IsFaceup()
end
-- 召·特召封锁效果条件检查：召唤·特殊召唤的怪兽中包含己方的「GMX」怪兽
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.limfilter,1,nil,tp)
end
-- 召·特召成功的封锁处理：当连锁为0时封锁对方发动；连锁为1时注册连续结算重置与连锁结束处理Flag
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsOnField() or c:IsFacedown() then return end
	-- 检查当前连锁数是否为0（非连锁中进行的召·特召）
	if Duel.GetCurrentChain()==0 then
		-- 封锁对方直到连锁结束前不能发动效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 检查当前连锁数是否为1（连锁1处理中进行的召·特召）
	elseif Duel.GetCurrentChain()==1 then
		c:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 注册全局连续效果：在连锁中发生召唤时，监测后续连锁与效果结算并及时重置Flag
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.limreset)
		-- 注册连锁中发生新连锁时重置Flag的效果
		Duel.RegisterEffect(ge1,tp)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_BREAK_EFFECT)
		ge2:SetReset(RESET_CHAIN)
		-- 注册连锁效果中途结算时重置Flag的效果
		Duel.RegisterEffect(ge2,tp)
	end
end
-- 重置召唤封锁标记及自身连续效果
function s.limreset(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id+o)
	e:Reset()
end
-- 连锁结束时的封锁处理：带有Flag标记时封锁对方直到连锁结束，并清除Flag
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsOnField() and not c:IsFacedown() and c:GetFlagEffect(id+o)~=0 then
		-- 封锁对方直到连锁结束前不能发动效果
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	c:ResetFlagEffect(id+o)
end
-- 连锁限制条件：仅允许发动玩家（己方）发动效果，禁止对方响应
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤条件：卡组中本卡同名卡以外可盖放的「GMX」魔法·陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id)
		and c:IsSSetable()
end
-- 盖放效果发动准备：检查卡组目标魔陷与手牌返回卡组条件
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的「GMX」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查手牌中是否存在可返回卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁操作信息：将1张手牌返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 盖放效果处理：从卡组盖放1张「GMX」魔陷，并将1张手牌置于卡组最上方
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足条件的「GMX」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选择的魔法·陷阱卡在自己场上盖放
	Duel.SSet(tp,tc)
	-- 连接前后效果处理（盖放与手牌置顶）
	Duel.BreakEffect()
	-- 洗切卡组
	Duel.ShuffleDeck(tp)
	-- 提示玩家选择要返回卡组最上面的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手牌选择1张卡
	local hg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	local hc=hg:GetFirst()
	if hc then
		-- 将选中的手牌放在卡组最上面
		Duel.SendtoDeck(hc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
