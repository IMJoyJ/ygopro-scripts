--ZW－極星神馬聖鎧
-- 效果：
-- ①：「异热同心武器-极星神马圣铠」在自己场上只能有1张表侧表示存在。
-- ②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1000的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
-- ③：装备怪兽被对方破坏让这张卡被送去墓地时，以自己墓地1只「希望皇 霍普」怪兽为对象才能发动。那只怪兽特殊召唤。
function c2648201.initial_effect(c)
	c:SetUniqueOnField(1,0,2648201)
	-- ②：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升1000的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2648201,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCondition(c2648201.eqcon)
	e1:SetTarget(c2648201.eqtg)
	e1:SetOperation(c2648201.eqop)
	c:RegisterEffect(e1)
	-- ③：装备怪兽被对方破坏让这张卡被送去墓地时，以自己墓地1只「希望皇 霍普」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2648201,1))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c2648201.spcon)
	e2:SetTarget(c2648201.sptg)
	e2:SetOperation(c2648201.spop)
	c:RegisterEffect(e2)
end
-- 效果发动时检查此卡是否满足在自己场上只能有1张表侧表示存在的条件
function c2648201.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 筛选自己场上表侧表示的「希望皇 霍普」怪兽
function c2648201.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 设置效果目标为己方场上的「希望皇 霍普」怪兽
function c2648201.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2648201.filter(chkc) end
	-- 判断己方魔法陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断己方场上是否存在「希望皇 霍普」怪兽
		and Duel.IsExistingTarget(c2648201.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c2648201.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果处理函数
function c2648201.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取效果目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 不满足条件时将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c2648201.zw_equip_monster(c,tp,tc)
end
-- 装备卡装备给目标怪兽并设置装备效果
function c2648201.zw_equip_monster(c,tp,tc)
	-- 尝试将装备卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备对象限制，只能装备给指定怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c2648201.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 设置装备卡装备时攻击力上升1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备对象限制判断函数
function c2648201.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断此卡是否因装备怪兽被破坏而送入墓地
function c2648201.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and c:IsPreviousControler(tp) and ec:IsReason(REASON_DESTROY) and ec:GetReasonPlayer()==1-tp
end
-- 筛选可特殊召唤的「希望皇 霍普」怪兽
function c2648201.spfilter(c,e,tp)
	return c:IsSetCard(0x107f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标为己方墓地的「希望皇 霍普」怪兽
function c2648201.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c2648201.spfilter(chkc,e,tp) end
	-- 判断己方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断己方墓地是否存在「希望皇 霍普」怪兽
		and Duel.IsExistingTarget(c2648201.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c2648201.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果处理函数
function c2648201.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
