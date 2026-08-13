--E・HERO アイスエッジ
-- 效果：
-- 1回合1次，自己的主要阶段一丢弃1张手卡发动。这个回合这张卡可以直接攻击对方玩家。此外，这张卡直接攻击给与对方基本分战斗伤害时，可以把对方的魔法与陷阱卡区域盖放的1张卡破坏。
function c41077745.initial_effect(c)
	-- 1回合1次，自己的主要阶段一丢弃1张手卡发动。这个回合这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41077745,0))  --"直接攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c41077745.datcon)
	e1:SetCost(c41077745.datcost)
	e1:SetOperation(c41077745.datop)
	c:RegisterEffect(e1)
	-- 此外，这张卡直接攻击给与对方基本分战斗伤害时，可以把对方的魔法与陷阱卡区域盖放的1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41077745,1))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c41077745.descon)
	e2:SetTarget(c41077745.destg)
	e2:SetOperation(c41077745.desop)
	c:RegisterEffect(e2)
end
-- 直接攻击效果的发动条件：当前必须是我方的主要阶段一。
function c41077745.datcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段一。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 直接攻击效果的发动代价：从手牌选择1张可以丢弃的卡丢弃；同时进行代价合法性的检查。
function c41077745.datcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认手牌中至少有1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手牌选择1张可以丢弃的卡丢弃（丢弃原因记为代价+丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 处理直接攻击效果：若这张卡仍在自己怪兽区域且表侧表示，则给自己赋予本回合可以直接攻击对方玩家的效果。
function c41077745.datop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这个回合这张卡可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 破坏魔陷效果的发动的触发条件：这张卡直接攻击造成对方战斗伤害时。
function c41077745.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件：受到战斗伤害的是对方，且攻击目标为空（即这次攻击是直接攻击）。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 选择对象的筛选条件：对方的魔法与陷阱卡区域里侧表示的卡，且不在场地魔法区域（即不是场地魔法卡）。
function c41077745.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- 破坏效果发动时：从对方魔法与陷阱卡区域选择1张里侧表示且不是场地魔法卡的卡作为对象；若不存在可选对象则不能发动。
function c41077745.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c41077745.filter(chkc) end
	-- 发动时检查：对方魔法与陷阱卡区域是否存在至少1张符合条件的里侧卡。
	if chk==0 then return Duel.IsExistingTarget(c41077745.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 给予玩家选择破坏对象时的提示信息：“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方的魔法与陷阱卡区域选择1张符合条件的里侧卡，并作为本连锁的对象。
	local g=Duel.SelectTarget(tp,c41077745.filter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 将本次操作信息登记为破坏1张卡（对象为g），供其他卡连锁时判断。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象卡，若该卡仍在场上且为里侧表示，并且与效果存在关联，则将其破坏。
function c41077745.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中作为对象的1张卡（此处即之前选择的陷阱/魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
