--EMスカイ・ピューピル
-- 效果：
-- 「娱乐伙伴 天空徒弟」的①的效果1回合只能使用1次。
-- ①：让自己场上1只5星以上的「娱乐伙伴」怪兽回到持有者手卡才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
-- ②：这张卡和对方怪兽进行战斗的场合，直到伤害步骤结束时那只怪兽的效果无效化。
-- ③：自己场上有其他的「娱乐伙伴」怪兽存在的场合，这张卡向对方怪兽攻击的伤害计算前才能发动。那只对方怪兽破坏。
function c122520.initial_effect(c)
	-- 「娱乐伙伴 天空徒弟」的①的效果1回合只能使用1次。①：让自己场上1只5星以上的「娱乐伙伴」怪兽回到持有者手卡才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(122520,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,122520)
	e1:SetCost(c122520.spcost)
	e1:SetTarget(c122520.sptg)
	e1:SetOperation(c122520.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的场合，直到伤害步骤结束时那只怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(c122520.distg)
	c:RegisterEffect(e2)
	-- ③：自己场上有其他的「娱乐伙伴」怪兽存在的场合，这张卡向对方怪兽攻击的伤害计算前才能发动。那只对方怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(122520,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetCondition(c122520.descon)
	e3:SetTarget(c122520.destg)
	e3:SetOperation(c122520.desop)
	c:RegisterEffect(e3)
end
-- ①的代价筛选：怪兽须表侧表示、属于「娱乐伙伴」、等级不低于5，且能作为代价返回持有者手卡。
function c122520.spcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:IsLevelAbove(5) and c:IsAbleToHandAsCost()
end
-- ①的代价处理：确认自己场上有满足条件的怪兽，选择1只表侧表示的5星以上「娱乐伙伴」怪兽返回持有者手卡（返回属于代价）。
function c122520.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己场上是否存在1只满足筛选条件的「娱乐伙伴」怪兽可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c122520.spcfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，要求玩家选择要返回手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己场上筛选出1只符合条件的怪兽，作为代价返回手卡。
	local g=Duel.SelectMatchingCard(tp,c122520.spcfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽以代价形式送到持有者手卡（这是发动①所支付的代价）。
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- ①的发动目标判定：确认自己场上有特殊召唤空位，且这张卡自身可以被特殊召唤。
function c122520.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断特殊召唤是否可行的格数条件：自己场上至少有1个可用的怪兽区（若目前没有空位，因代价返回手牌后腾出位置也算满足，故用 > -1）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本效果将进行特殊召唤的操作信息，指定要特殊召唤的卡为这张卡本身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：若这张卡仍在效果关联中，则将其从手卡特殊召唤到自己的场上表侧攻击表示。
function c122520.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上，不视为召唤条件限制（nocheck/nolimit为false表示仍检查召唤条件和苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②的无效化对象筛选：以与这张卡进行战斗的对方怪兽为无效化对象。
function c122520.distg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
-- ③的条件筛选：自己场上的其他「娱乐伙伴」怪兽需表侧表示。
function c122520.descfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- ③的发动条件：自己场上存在其他表侧表示的「娱乐伙伴」怪兽。
function c122520.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在1只除自身以外的表侧表示「娱乐伙伴」怪兽。
	return Duel.IsExistingMatchingCard(c122520.descfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- ③的发动目标判定：确认攻击者是这张卡，且存在攻击对象，然后将该攻击对象设为要破坏的卡。
function c122520.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得这张卡攻击的对方怪兽（战斗对象）。
	local t=Duel.GetAttackTarget()
	-- 确认本次战斗的攻击者是这张卡，并且存在攻击对象（对方怪兽）。
	if chk==0 then return Duel.GetAttacker()==e:GetHandler() and t~=nil end
	-- 将攻击对象的对方怪兽设置为当前连锁的效果处理对象（取对象）。
	Duel.SetTargetCard(t)
	-- 登记本效果将破坏该怪兽的操作信息，破坏的对象为确定的攻击对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,t,1,0,0)
end
-- ③的效果处理：若攻击对象仍与本次战斗关联，则将其破坏。
function c122520.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的破坏对象（③发动时锁定的对方怪兽）。
	local t=Duel.GetFirstTarget()
	if t:IsRelateToBattle() then
		-- 以效果原因将那只对方怪兽破坏。
		Duel.Destroy(t,REASON_EFFECT)
	end
end
