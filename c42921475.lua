--妖精伝姫－ターリア
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡反转的场合才能发动。从手卡把1只怪兽特殊召唤。
-- ②：对方把通常魔法·通常陷阱卡发动时，把自己场上1只其他怪兽解放才能发动。那个效果变成「对方场上1只表侧表示怪兽变成里侧守备表示」。
function c42921475.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从手卡把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42921475,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c42921475.sptg)
	e1:SetOperation(c42921475.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方把通常魔法·通常陷阱卡发动时，把自己场上1只其他怪兽解放才能发动。那个效果变成「对方场上1只表侧表示怪兽变成里侧守备表示」。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42921475,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,42921475)
	e2:SetCondition(c42921475.chcon)
	e2:SetCost(c42921475.chcost)
	e2:SetTarget(c42921475.chtg)
	e2:SetOperation(c42921475.chop)
	c:RegisterEffect(e2)
end
-- 定义手牌怪兽的特殊召唤过滤条件：检查该怪兽能否被当前效果以表侧表示特殊召唤（需通过召唤条件和苏生限制的检查）。
function c42921475.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性与可用性判定：在自己怪兽区有空位且手牌存在可特殊召唤的怪兽时，才允许发动①效果。
function c42921475.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区格子，用于确保特殊召唤有可用位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足特殊召唤条件的怪兽（c42921475.spfilter），作为发动①效果的前提之一。
		and Duel.IsExistingMatchingCard(c42921475.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：提示本次效果将把手牌中的1只怪兽特殊召唤，用于后续连锁判定和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的实际处理：若自己怪兽区仍有空位，则从手牌选择1只符合条件的怪兽，以表侧攻击表示特殊召唤到自己的怪兽区。
function c42921475.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己怪兽区是否有空位，避免因连锁处理过程中场地变化导致无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，让玩家从手牌中选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选出1只满足特殊召唤条件的怪兽作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c42921475.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上，完成特殊召唤处理。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：对方发动魔法或陷阱卡（即卡的发动，EFFECT_TYPE_ACTIVATE）时，且该发动由对方进行，本卡可以在自己场上发动②效果。
function c42921475.chcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==1-tp and (rc:GetType()==TYPE_SPELL or rc:GetType()==TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 定义可解放怪兽的过滤条件：排除已经处于战斗破坏确定状态的卡，即只能解放正常存在于场上且未被战斗破坏确定（STATUS_BATTLE_DESTROYED）的怪兽。
function c42921475.cfilter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果的发动代价：解放自己场上1只除本卡以外的其他怪兽。该过程先检查是否存在可解放的怪兽，再选择并解放作为发动代价。
function c42921475.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上是否存在至少1只除本卡外、且未被战斗破坏确定的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c42921475.cfilter,1,e:GetHandler()) end
	-- 选择自己场上1只除本卡以外的、可解放的怪兽作为代价。
	local g=Duel.SelectReleaseGroup(tp,c42921475.cfilter,1,1,e:GetHandler())
	-- 以费用（REASON_COST）的方式解放选中的怪兽，完成代价支付。
	Duel.Release(g,REASON_COST)
end
-- 定义被处理效果的目标怪兽条件：对方场上的表侧表示怪兽，并且当前可以变成里侧表示。
function c42921475.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②效果发动时的目标存在性检查：确认对方场上存在至少1只满足条件的表侧表示怪兽，以便后续将其变成里侧守备表示。
function c42921475.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示且能够变为里侧表示（IsCanTurnSet）的怪兽，作为②效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c42921475.filter,rp,0,LOCATION_MZONE,1,nil) end
end
-- ②效果处理：将原对方魔陷的连锁对象清空，并把该连锁的处理函数替换为c42921475.repop，从而实现把原效果变成“选对方场上1只表侧表示怪兽变成里侧守备表示”。
function c42921475.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 清空原连锁的对象，使原效果不再以任何卡为对象，为替换效果做准备。
	Duel.ChangeTargetCard(ev,g)
	-- 将当前连锁的效果处理函数替换为c42921475.repop，使得后续处理执行的是“选对方场上1只表侧表示怪兽变成里侧守备表示”这一效果。
	Duel.ChangeChainOperation(ev,c42921475.repop)
end
-- 替换后的新效果处理：从对方场上选择1只表侧表示且可变为里侧表示的怪兽，将其变成里侧守备表示。
function c42921475.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择对方场上的1只表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择1只表侧表示且可变为里侧表示（IsCanTurnSet）的怪兽作为新效果的作用对象。
	local g=Duel.SelectMatchingCard(tp,c42921475.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的对方怪兽变成里侧守备表示（POS_FACEDOWN_DEFENSE），完成替换后的效果处理。
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
