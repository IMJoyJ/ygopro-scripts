--黄血鬼
-- 效果：
-- 自己超量召唤成功时，这张卡可以从手卡特殊召唤。此外，1回合1次，把自己场上1个超量素材取除，选择场上1只超量怪兽才能发动。选择的怪兽的阶级下降1阶，攻击力下降300。
function c53090623.initial_effect(c)
	-- 自己超量召唤成功时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53090623,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c53090623.condition)
	e1:SetTarget(c53090623.target)
	e1:SetOperation(c53090623.operation)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，把自己场上1个超量素材取除，选择场上1只超量怪兽才能发动。选择的怪兽的阶级下降1阶，攻击力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53090623,1))  --"阶级下降"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c53090623.rdcost)
	e2:SetTarget(c53090623.rdtg)
	e2:SetOperation(c53090623.rdop)
	c:RegisterEffect(e2)
end
-- 判定诱发条件：最近特殊召唤成功的怪兽只有1只、由自己控制，并且那次召唤为超量召唤。
function c53090623.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	return eg:GetCount()==1 and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 特殊召唤效果的发动条件：自己场上有可用的主要怪兽区空位，且这张卡能够被特殊召唤（满足召唤条件与苏生限制）。
function c53090623.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还存在空余的怪兽区域，用于容纳这张卡从手卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本效果处理时将要把这张卡特殊召唤，供其他卡片（如星尘龙等）进行效果发动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与发动效果关联，则将其表侧表示特殊召唤到自己场上，且不无视召唤条件与苏生限制。
function c53090623.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到其持有者（即自己）的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 发动代价：确认自己场上存在至少1个可因代价取除的超量素材，若有则取除1个作为发动代价。
function c53090623.rdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上是否有至少1个超量素材可以作为代价取除。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 实际支付代价：从自己场上取除1个超量素材。
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 对象筛选条件：卡片为表侧表示且阶级在1以上（即超量怪兽）。
function c53090623.filter(c)
	return c:IsFaceup() and c:IsRankAbove(1)
end
-- 取对象阶段：从双方场上表侧表示且阶级1以上的超量怪兽中选择1只作为效果对象；若已有选择目标则先验证其合法性，否则检查是否存在合法目标并让玩家选择。
function c53090623.rdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53090623.filter(chkc) end
	-- 发动时点检查：双方场上是否存在至少1只满足条件的表侧超量怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c53090623.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择效果的对象”的选择提示消息，引导玩家选择目标卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从双方场上选择1只满足条件的表侧超量怪兽作为效果对象，并将其登记为当前连锁的取对象目标。
	Duel.SelectTarget(tp,c53090623.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：确认对象怪兽仍与效果关联且为表侧表示时，对其赋予攻击力下降300和阶级下降1的持续效果，并在怪兽离场等标准重置时机后失效。
function c53090623.rdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理时选择的那1只取对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 攻击力下降300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RANK)
		e2:SetValue(-1)
		tc:RegisterEffect(e2)
	end
end
