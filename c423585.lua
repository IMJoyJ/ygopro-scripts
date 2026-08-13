--召喚僧サモンプリースト
-- 效果：
-- ①：这张卡召唤·反转召唤的场合发动。这张卡变成守备表示。
-- ②：只要这张卡在怪兽区域存在，这张卡不能解放。
-- ③：1回合1次，从手卡丢弃1张魔法卡才能发动。从卡组把1只4星怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c423585.initial_effect(c)
	-- ①：这张卡召唤·反转召唤的场合发动。这张卡变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(423585,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c423585.potg)
	e1:SetOperation(c423585.poop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ③：1回合1次，从手卡丢弃1张魔法卡才能发动。从卡组把1只4星怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(423585,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c423585.spcost)
	e3:SetTarget(c423585.sptg)
	e3:SetOperation(c423585.spop)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，这张卡不能解放。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UNRELEASABLE_SUM)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e5)
end
-- 效果①的发动条件检定：召唤成功时必发，无额外条件，因此直接通过，并登记本效果将改变这张卡的表示形式。
function c423585.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记效果①的操作信息：改变表示形式，对象为效果发动者自身（这张卡），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果①处理：若这张卡仍表侧表示、为攻击表示且与发动时效果仍有联系，则将其变为表侧守备表示。
function c423585.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将这张卡的表示形式改为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 代价筛选函数：判断手卡中的卡是否为魔法卡且可以被丢弃，用于作为效果③的发动代价。
function c423585.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 效果③的代价处理：先检查手卡中是否存在可丢弃的魔法卡，若存在则选择并丢弃1张手卡魔法卡作为代价。
function c423585.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价判断阶段：确认手卡中存在至少1张满足costfilter（魔法卡且可丢弃）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c423585.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手卡中挑选并丢弃1张魔法卡，丢弃原因标记为代价。
	Duel.DiscardHand(tp,c423585.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤候选卡的筛选函数：选择等级为4星、且可以被当前效果特殊召唤的怪兽。
function c423585.filter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动条件判断：确保自己主要怪兽区有空位，且卡组中存在满足条件的4星怪兽，否则无法发动。
function c423585.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判断第一步：确认自己的主要怪兽区域还有空位可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件判断第二步：确认卡组中存在至少1只4星且可以被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c423585.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记效果③将进行特殊召唤，对象为卡组中的1只怪兽，供连锁判定和处理时使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③处理：若仍有空位，则从卡组选择1只4星怪兽表侧表示特殊召唤，并给那只怪兽附加这个回合不能攻击的效果。
function c423585.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时确认主要怪兽区仍有空位；若没有空位，效果不适用并结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示玩家从卡组中选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足filter条件的4星怪兽（不取对象，在处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c423585.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
