--燎星のプロメテオロン
-- 效果：
-- ①：这张卡的攻击破坏主要怪兽区域的对方怪兽时，丢弃1张手卡才能发动。这张卡可以继续攻击。直到下个回合的结束时，那只怪兽存在过的区域不能使用。
function c75713017.initial_effect(c)
	-- ①：这张卡的攻击破坏主要怪兽区域的对方怪兽时，丢弃1张手卡才能发动。这张卡可以继续攻击。直到下个回合的结束时，那只怪兽存在过的区域不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75713017,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c75713017.atcon)
	e1:SetCost(c75713017.atcost)
	e1:SetOperation(c75713017.atop)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：检查此卡是否攻击破坏了对方主要怪兽区域的怪兽，并记录该怪兽原本所在的格子序号。
function c75713017.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not bc then return false end
	local seq=bc:GetPreviousSequence()
	e:SetLabel(seq)
	-- 判断此卡是否为攻击怪兽、是否战斗破坏了对方怪兽、被破坏怪兽是否在主要怪兽区域（序号小于5），以及此卡是否能继续攻击。
	return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and seq<5 and c:IsChainAttackable(0)
end
-- 定义代价函数：检查并执行丢弃1张手卡的操作。
function c75713017.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查手卡中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡中选择1张卡丢弃送去墓地，作为发动的代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_DISCARD+REASON_COST)
end
-- 定义效果处理函数：使此卡可以继续攻击，并封锁被破坏怪兽原本存在的怪兽区域直到下个回合结束。
function c75713017.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前进行攻击的怪兽可以再进行1次攻击。
	Duel.ChainAttack()
	local seq=e:GetLabel()
	-- 将被破坏的对方怪兽原本所在的怪兽区域序号转换为全局区域掩码。
	local val=aux.SequenceToGlobal(1-tp,LOCATION_MZONE,seq)
	-- 直到下个回合的结束时，那只怪兽存在过的区域不能使用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetValue(val)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 向系统注册该区域封锁效果，使其对指定的怪兽区域生效。
	Duel.RegisterEffect(e1,tp)
end
