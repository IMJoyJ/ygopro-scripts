--ふわんだりぃず×すのーる
-- 效果：
-- ①：上级召唤的这张卡存在的场合，1回合1次，可以发动。这个回合自己可以进行通常召唤最多3次。
-- ②：只要上级召唤的这张卡在怪兽区域存在，自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：对方回合1次，把1张手卡除外才能发动。对方场上的特殊召唤的怪兽全部变成里侧守备表示。
function c53212882.initial_effect(c)
	-- ①：上级召唤的这张卡存在的场合，1回合1次，可以发动。这个回合自己可以进行通常召唤最多3次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53212882,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c53212882.sumcon)
	e1:SetTarget(c53212882.sumtg)
	e1:SetOperation(c53212882.sumop)
	c:RegisterEffect(e1)
	-- ②：只要上级召唤的这张卡在怪兽区域存在，自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c53212882.sumcon)
	c:RegisterEffect(e2)
	-- ③：对方回合1次，把1张手卡除外才能发动。对方场上的特殊召唤的怪兽全部变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53212882,1))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(c53212882.poscon)
	e3:SetCost(c53212882.poscost)
	e3:SetTarget(c53212882.postg)
	e3:SetOperation(c53212882.posop)
	c:RegisterEffect(e3)
end
-- 判断此卡是否以上级召唤方式存在于场上（召唤类型为上级召唤），作为效果①的发动条件和效果②的适用条件。
function c53212882.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果①发动时确认本回合通常召唤次数上限：获取当前玩家tp受到的所有EFFECT_SET_SUMMON_COUNT_LIMIT效果并取最大值ct，只有ct<3时才可发动（保证能将上限提升到3次）。
function c53212882.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=0
		-- 获取玩家tp当前受到的所有“通常召唤次数限制”效果（EFFECT_SET_SUMMON_COUNT_LIMIT）并存入数组ce，用于计算现有的召唤次数上限。
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
		for _,te in ipairs(ce) do
			ct=math.max(ct,te:GetValue())
		end
		return ct<3
	end
end
-- 效果①的处理：为本回合的玩家tp创建一个场地永续效果，将通常召唤次数上限设为3（EFFECT_SET_SUMMON_COUNT_LIMIT），只影响该玩家，持续到结束阶段重置，并注册到Duel。
function c53212882.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合自己可以进行通常召唤最多3次。对方回合1次，把1张手卡除外才能发动。对方场上的特殊召唤的怪兽全部变成里侧守备表示。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(3)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新创建的“本回合通常召唤次数上限=3”的效果注册给玩家tp，使其在本回合内生效，结束阶段时自动重置。
	Duel.RegisterEffect(e1,tp)
end
-- 效果③的发动条件：仅在对方回合（当前回合玩家不是本卡控制者tp）才能发动，对应“对方回合1次”。
function c53212882.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方（即当前不是本卡控制者的回合），满足时效果③才可在对方回合发动。
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果③的发动代价：从手牌选择1张卡除外才能发动；包含代价检查、选择提示、选择手牌并表侧除外。
function c53212882.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：自己手牌中是否存在至少1张可作为代价除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 显示“请选择要除外的卡”的提示，引导玩家选择要除外的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家tp从手牌中选择1张可作为代价除外的卡，作为发动效果③的代价。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌以表侧表示除外（REASON_COST），完成效果③的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果③的过滤条件：对方场上的表侧表示怪兽，且是特殊召唤怪兽，并且可以变为里侧守备表示。
function c53212882.posfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果③的目标处理：确认对方怪兽区域存在至少1只满足条件的特殊召唤怪兽，获取全部符合条件的怪兽并设置操作信息为改变表示形式（CATEGORY_POSITION）。
function c53212882.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查对方怪兽区域是否存在至少1只表侧特殊召唤怪兽且可转为里侧守备表示，作为效果③的发动目标条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c53212882.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方怪兽区域所有满足posfilter条件的怪兽，即将被这次效果变为里侧守备表示的对象。
	local g=Duel.GetMatchingGroup(c53212882.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：本次效果将处理改变表示形式（CATEGORY_POSITION），对象为g，数量为g:GetCount()，供连锁判定和效果互动使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果③处理：重新获取对方场上所有满足条件的特殊召唤怪兽，若存在则将其全部变为里侧守备表示。
function c53212882.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取当前仍满足posfilter条件的对方怪兽，用于实际翻转。
	local g=Duel.GetMatchingGroup(c53212882.posfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将所有对象怪兽变为里侧守备表示（POS_FACEDOWN_DEFENSE），即“全部变成里侧守备表示”。
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
