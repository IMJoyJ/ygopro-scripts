--双天将 金剛
-- 效果：
-- 「双天拳之熊罴」＋「双天」怪兽×2
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ②：这张卡攻击的伤害计算后才能发动。选对方场上1只怪兽回到持有者手卡。
-- ③：自己场上有融合怪兽2只以上存在，场上的这张卡为对象的对方的魔法·陷阱卡的效果发动时才能发动。那个发动无效。
function c33026283.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：需要1只「双天拳之熊罴」（卡号85360035）和2只满足「双天」系列条件的怪兽作为融合素材，并启用该融合手续的辅助规则。
	aux.AddFusionProcCodeFun(c,85360035,aux.FilterBoolFunction(Card.IsFusionSetCard,0x14f),2,true,true)
	-- 「双天拳之熊罴」＋「双天」怪兽×2
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c33026283.matcheck)
	c:RegisterEffect(e0)
	-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(c33026283.actcon)
	c:RegisterEffect(e1)
	-- ②：这张卡攻击的伤害计算后才能发动。选对方场上1只怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33026283,0))  --"破坏怪兽"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c33026283.thcon)
	e2:SetTarget(c33026283.thtg)
	e2:SetOperation(c33026283.thop)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：自己场上有融合怪兽2只以上存在，场上的这张卡为对象的对方的魔法·陷阱卡的效果发动时才能发动。那个发动无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33026283,1))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,33026283)
	e3:SetCondition(c33026283.discon)
	e3:SetTarget(c33026283.distg)
	e3:SetOperation(c33026283.disop)
	c:RegisterEffect(e3)
end
-- 在作为融合素材进行融合召唤时，检查融合素材中是否存在效果怪兽；若存在，则给这张卡注册一个标记（FlagEffect），该标记会在离场、去手牌/卡组/墓地/除外等标准重置条件下清除。
function c33026283.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_EFFECT) then
		c:RegisterFlagEffect(85360035,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
end
-- ①效果的发动条件：判断这张卡是否正处于战斗之中，即这张卡是攻击怪兽或攻击对象。
function c33026283.actcon(e)
	-- 返回是否为“这张卡进行战斗”的条件——这张卡是攻击怪兽或攻击目标。
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- ②效果的发动条件：这张卡是攻击怪兽（表示这张卡进行攻击的伤害计算后）。
function c33026283.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前攻击怪兽是否为这张卡。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 选择返回手牌的过滤条件：该怪兽可以被加入手卡，且不是已确定被战斗破坏的怪兽。
function c33026283.thfilter(c)
	return c:IsAbleToHand() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果发动时的目标设定：获取对方场上所有可返回手牌的怪兽，若存在至少1张则允许发动，并设置“返回1张手牌”的操作信息。注意该效果不取对象，在处理时选择。
function c33026283.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有满足返回手牌条件的怪兽集合。
	local g=Duel.GetMatchingGroup(c33026283.thfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置当前连锁的操作信息为“从该集合中选择1张返回手牌”，用于连锁判定与效果响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：由玩家从对方场上选择1只符合条件的怪兽，播放选择动画并将其送回持有者手卡。
function c33026283.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要返回手牌的卡”的提示消息，并设定选择UI的提示文本。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 在对方怪兽区域选择1只满足返回手牌条件的怪兽（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c33026283.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		-- 为选择的卡播放“选中”动画，并记录该卡被选为广义对象。
		Duel.HintSelection(g)
		-- 将选中的怪兽以效果原因送回持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- ③效果额外条件用的过滤函数：判定怪兽是否为表侧表示且为融合怪兽。
function c33026283.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- ③效果的发动条件：仅在对手回合且对手发动以这张卡为对象的魔法·陷阱卡效果时，且该连锁可被无效，自己场上还有2只以上表侧表示融合怪兽的情况下才能发动；同时排除这张卡已被战斗破坏确定的状态。
function c33026283.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 获取当前连锁的对象卡集合，用于确认这张卡是否被选为对象。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 最终判定条件：对手发动的效果对象包含这张卡、且该效果为魔法·陷阱卡、该连锁可以被无效、自己场上有至少2只表侧表示融合怪兽。
	return tg and tg:IsContains(c) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(c33026283.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- ③效果发动时的目标设定：无需额外选择卡，直接设置操作信息为“无效当前连锁的发动”。
function c33026283.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将操作信息设为“无效该连锁（eg）的发动”，用于无效类效果的处理判定。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ③效果处理：无效对手发动的该魔法·陷阱卡效果的连锁。
function c33026283.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁ev的发动无效。
	Duel.NegateActivation(ev)
end
