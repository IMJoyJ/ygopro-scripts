--バウンド・ワンド
-- 效果：
-- 魔法师族怪兽才能装备。
-- ①：装备怪兽的攻击力上升装备怪兽的等级×100。
-- ②：装备怪兽被对方破坏，这张卡被送去墓地的场合才能发动。那只怪兽从墓地往自己场上特殊召唤。
function c53610653.initial_effect(c)
	-- 魔法师族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c53610653.target)
	e1:SetOperation(c53610653.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升装备怪兽的等级×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c53610653.atkval)
	c:RegisterEffect(e2)
	-- 魔法师族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c53610653.eqlimit)
	c:RegisterEffect(e3)
	-- ②：装备怪兽被对方破坏，这张卡被送去墓地的场合才能发动。那只怪兽从墓地往自己场上特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(53610653,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c53610653.spcon)
	e4:SetTarget(c53610653.sptg)
	e4:SetOperation(c53610653.spop)
	c:RegisterEffect(e4)
end
-- 检查装备对象是否为魔法师族怪兽，是才能装备。
function c53610653.eqlimit(e,c)
	return c:IsRace(RACE_SPELLCASTER)
end
-- 筛选场上表侧表示的魔法师族怪兽，作为装备对象候选。
function c53610653.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 发动时的Target处理：确认有合法对象后，让玩家选择1只场上表侧表示的魔法师族怪兽，设定为效果对象，并登记本次操作将进行装备。
function c53610653.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53610653.filter(chkc) end
	-- 发动条件检查：场上是否存在至少1只表侧表示魔法师族怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c53610653.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给予玩家选择装备对象时显示的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只场上表侧表示魔法师族怪兽，并将其设为效果的对象。
	Duel.SelectTarget(tp,c53610653.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：这张卡将装备给选择的对象（供其他卡和效果连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的Operation：确认装备卡自身和选择的对象都仍然关联且对象表侧表示，则将这张卡装备给那只怪兽。
function c53610653.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算攻击力上升值：装备怪兽的等级×100。
function c53610653.atkval(e,c)
	return c:GetLevel()*100
end
-- 触发条件判断：这张卡因失去装备对象被送去墓地，且原装备怪兽是被对方破坏并进入墓地。
function c53610653.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetPreviousEquipTarget()
	return e:GetHandler():IsReason(REASON_LOST_TARGET) and ec and ec:IsReason(REASON_DESTROY)
		and ec:IsLocation(LOCATION_GRAVE) and ec:GetReasonPlayer()==1-tp
end
-- 特殊召唤的Target处理：确认自己怪兽区有空位，且原先的装备怪兽可以特殊召唤。
function c53610653.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetPreviousEquipTarget()
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and ec:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将原先装备的怪兽设为特殊召唤效果的对象。
	Duel.SetTargetCard(ec)
	-- 登记操作信息：将特殊召唤该怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,ec,1,0,0)
end
-- 特殊召唤处理：若对象仍与效果关联，则将那只怪兽以表侧攻击表示特殊召唤到己方场上。
function c53610653.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要特殊召唤的对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
