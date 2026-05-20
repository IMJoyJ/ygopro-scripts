--ミュートリア反射作用
-- 效果：
-- 自己场上的8星以上的「秘异三变」怪兽才能装备。这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽向特殊召唤的对方怪兽攻击的伤害步骤开始时才能发动。那只对方怪兽除外。
-- ②：把装备的这张卡除外才能发动。这张卡装备过的怪兽送去墓地，原本属性和那只怪兽不同的1只8星「秘异三变」怪兽从手卡·卡组特殊召唤。
function c79072916.initial_effect(c)
	-- 自己场上的8星以上的「秘异三变」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c79072916.target)
	e1:SetOperation(c79072916.operation)
	c:RegisterEffect(e1)
	-- 自己场上的8星以上的「秘异三变」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c79072916.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽向特殊召唤的对方怪兽攻击的伤害步骤开始时才能发动。那只对方怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79072916,0))  --"怪兽除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c79072916.rmcon)
	e3:SetTarget(c79072916.rmtg)
	e3:SetOperation(c79072916.rmop)
	c:RegisterEffect(e3)
	-- ②：把装备的这张卡除外才能发动。这张卡装备过的怪兽送去墓地，原本属性和那只怪兽不同的1只8星「秘异三变」怪兽从手卡·卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(79072916,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,79072916)
	-- 把装备的这张卡除外作为发动效果的Cost
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c79072916.sptg)
	e4:SetOperation(c79072916.spop)
	c:RegisterEffect(e4)
end
-- 装备限制：自己场上的8星以上的「秘异三变」怪兽
function c79072916.eqlimit(e,c)
	return c:IsSetCard(0x157) and e:GetHandler():IsControler(c:GetControler()) and c:IsLevelAbove(8)
end
-- 过滤条件：自己场上表侧表示的8星以上的「秘异三变」怪兽
function c79072916.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x157) and c:IsLevelAbove(8)
end
-- 魔法卡发动时的效果处理：选择自己场上1只符合条件的怪兽作为装备对象
function c79072916.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c79072916.filter(chkc) end
	-- 检查自己场上是否存在可以装备的怪兽
	if chk==0 then return Duel.IsExistingTarget(c79072916.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c79072916.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 魔法卡发动后的效果处理：将这张卡装备给目标怪兽
function c79072916.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 效果①的发动条件：装备怪兽向特殊召唤的对方怪兽攻击的伤害步骤开始时
function c79072916.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return false end
	local tc=ec:GetBattleTarget()
	-- 检查装备怪兽是否是攻击方，且其攻击对象是特殊召唤的怪兽
	return tc and Duel.GetAttacker()==ec and tc:IsSummonType(SUMMON_TYPE_SPECIAL)
		and tc:IsControler(1-tp)
end
-- 效果①的靶向处理：确认对方怪兽是否可以除外并设置操作信息
function c79072916.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	if chk==0 then return tc and tc:IsAbleToRemove() end
	-- 设置操作信息：除外那只对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end
-- 效果①的效果处理：将那只对方怪兽除外
function c79072916.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	if tc:IsRelateToBattle() then
		-- 将那只对方怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤条件：原本属性与装备怪兽不同、且可以特殊召唤的8星「秘异三变」怪兽
function c79072916.sptgfilter(c,e,tp,attr)
	return c:GetOriginalAttribute()~=attr and c:IsLevel(8) and c:IsSetCard(0x157) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：确认装备怪兽是否能送去墓地，并确认手卡·卡组是否有可特殊召唤的怪兽
function c79072916.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local tc=e:GetHandler():GetEquipTarget()
		e:SetLabelObject(tc)
		-- 检查装备怪兽是否能送去墓地，且送去墓地后是否有可用的怪兽区域
		return tc and tc:IsAbleToGrave() and Duel.GetMZoneCount(tp,tc)>0
			-- 检查手卡或卡组中是否存在原本属性与装备怪兽不同的8星「秘异三变」怪兽
			and Duel.IsExistingMatchingCard(c79072916.sptgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,tc:GetOriginalAttribute())
	end
	local tc=e:GetLabelObject()
	tc:CreateEffectRelation(e)
	-- 设置操作信息：将装备怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tc,1,0,0)
	-- 设置操作信息：从手卡·卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的效果处理：将装备怪兽送去墓地，并从手卡·卡组特殊召唤符合条件的怪兽
function c79072916.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc:IsRelateToEffect(e) then return end
	-- 将装备怪兽送去墓地，并确认是否成功送去墓地
	if Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE)
		-- 确认自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡或卡组选择1只原本属性与装备怪兽不同的8星「秘异三变」怪兽
		local g=Duel.SelectMatchingCard(tp,c79072916.sptgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,tc:GetOriginalAttribute())
		if #g>0 then
			-- 将选择的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
