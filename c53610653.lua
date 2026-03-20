--バウンド・ワンド
-- 效果：
-- 魔法师族怪兽才能装备。
-- ①：装备怪兽的攻击力上升装备怪兽的等级×100。
-- ②：装备怪兽被对方破坏，这张卡被送去墓地的场合才能发动。那只怪兽从墓地往自己场上特殊召唤。
function c53610653.initial_effect(c)
	-- ①：装备怪兽的攻击力上升装备怪兽的等级×100。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c53610653.target)
	e1:SetOperation(c53610653.operation)
	c:RegisterEffect(e1)
	-- ②：装备怪兽被对方破坏，这张卡被送去墓地的场合才能发动。那只怪兽从墓地往自己场上特殊召唤。
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
-- 限制装备对象为魔法师族怪兽。
function c53610653.eqlimit(e,c)
	return c:IsRace(RACE_SPELLCASTER)
end
-- 筛选场上正面表示的魔法师族怪兽作为装备目标。
function c53610653.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 设置装备效果的处理目标为场上正面表示的魔法师族怪兽。
function c53610653.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53610653.filter(chkc) end
	-- 判断是否存在符合条件的装备目标。
	if chk==0 then return Duel.IsExistingTarget(c53610653.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个场上正面表示的魔法师族怪兽作为装备对象。
	Duel.SelectTarget(tp,c53610653.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽。
function c53610653.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算装备怪兽攻击力提升值，为等级×100。
function c53610653.atkval(e,c)
	return c:GetLevel()*100
end
-- 判断装备卡是否因失去装备对象且被破坏而送入墓地，且该怪兽在墓地且为对方破坏。
function c53610653.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetPreviousEquipTarget()
	return e:GetHandler():IsReason(REASON_LOST_TARGET) and ec and ec:IsReason(REASON_DESTROY)
		and ec:IsLocation(LOCATION_GRAVE) and ec:GetReasonPlayer()==1-tp
end
-- 判断是否可以将装备卡的装备对象特殊召唤。
function c53610653.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetPreviousEquipTarget()
	-- 判断玩家场上是否有足够的召唤区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and ec:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的目标卡为装备卡的装备对象。
	Duel.SetTargetCard(ec)
	-- 设置特殊召唤效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,ec,1,0,0)
end
-- 执行特殊召唤操作，将装备卡的装备对象从墓地特殊召唤到场上。
function c53610653.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的特殊召唤目标。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽从墓地特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
