--D・D・R
-- 效果：
-- ①：丢弃1张手卡，以除外的1只自己怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
function c9622164.initial_effect(c)
	-- ①：丢弃1张手卡，以除外的1只自己怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c9622164.cost)
	e1:SetTarget(c9622164.target)
	e1:SetOperation(c9622164.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c9622164.desop)
	c:RegisterEffect(e2)
end
-- 代价处理函数：检查并丢弃手卡
function c9622164.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己手卡中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡中选择1张卡作为发动代价丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：筛选除外区中可以表侧攻击表示特殊召唤的怪兽
function c9622164.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动时的对象选择与合法性检查
function c9622164.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c9622164.filter(chkc,e,tp) end
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己除外区是否存在至少1只满足条件的怪兽
		and Duel.IsExistingTarget(c9622164.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外的1只自己怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c9622164.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置效果处理信息：包含将这张卡装备的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制函数：限制这张卡只能装备给由该效果特殊召唤的怪兽
function c9622164.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理函数：执行特殊召唤并装备此卡
function c9622164.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤，若特殊召唤失败则结束处理
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then return end
		-- 将这张卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c9622164.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 离场时破坏怪兽的处理函数
function c9622164.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果将装备的怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
