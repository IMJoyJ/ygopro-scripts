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
	-- 1回合1次，把自己场上1个超量素材取除，选择场上1只超量怪兽才能发动。选择的怪兽的阶级下降1阶，攻击力下降300。
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
-- 检测是否为己方超量召唤成功且仅召唤1只怪兽
function c53090623.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	return eg:GetCount()==1 and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 判断是否可以将此卡特殊召唤到场上
function c53090623.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c53090623.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡从手牌特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 支付效果代价，移除自身1个超量素材
function c53090623.rdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以移除自身1个超量素材作为代价
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 执行移除自身1个超量素材的操作
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 筛选场上正面表示且阶级大于等于1的怪兽
function c53090623.filter(c)
	return c:IsFaceup() and c:IsRankAbove(1)
end
-- 设置选择目标，选取符合条件的场上怪兽
function c53090623.rdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53090623.filter(chkc) end
	-- 判断场上是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c53090623.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的场上怪兽作为效果对象
	Duel.SelectTarget(tp,c53090623.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 执行效果，使目标怪兽攻击力下降300，阶级下降1阶
function c53090623.rdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为对象怪兽添加攻击力下降300的效果
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
