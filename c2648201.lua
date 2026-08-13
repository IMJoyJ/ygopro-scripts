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
-- 检查此卡是否满足『自己场上只能有1张表侧表示存在』的唯一性限制，作为装备效果的发动的条件之一。
function c2648201.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 筛选可作为对象的怪兽：表侧表示且卡名属于「希望皇 霍普」字段（0x107f）。
function c2648201.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 装备效果的发动目标处理：确认自己魔陷区有空位，并选择自己场上1只表侧表示的「希望皇 霍普」怪兽为对象。
function c2648201.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2648201.filter(chkc) end
	-- 发动条件之一：自己魔陷区存在空位，用于放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且自己场上存在1只表侧表示的「希望皇 霍普」怪兽能够被选择为对象。
		and Duel.IsExistingTarget(c2648201.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择自己场上1只符合条件的「希望皇 霍普」怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,c2648201.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果处理：若这张卡与对象仍合法，则将其装备给对象；否则将此卡送入墓地。
function c2648201.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取装备效果选择的对象（「希望皇 霍普」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 若魔陷区无空位、对象已不由自己控制、对象变为里侧表示、对象与效果无关或此卡不再满足唯一性，则装备处理失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 因上述条件不满足导致装备失败时，将这张卡以效果原因送入墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c2648201.zw_equip_monster(c,tp,tc)
end
-- 将这张卡装备给目标「希望皇 霍普」怪兽，并给它设置「只能装备给该怪兽」的限制以及攻击力上升1000的效果。
function c2648201.zw_equip_monster(c,tp,tc)
	-- 尝试将这张卡作为装备卡装备给目标怪兽，若装备失败则直接中止。
	if not Duel.Equip(tp,c,tc) then return end
	-- 给那只自己的「希望皇 霍普」怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c2648201.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 攻击力上升1000的装备卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 设置装备限制：此卡只能装备给发动时选择的那只「希望皇 霍普」怪兽。
function c2648201.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ③的发动条件：这张卡作为装备卡因装备对象被对方破坏而失去装备对象并送去墓地，且这张卡原来的控制者是自己。
function c2648201.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and c:IsPreviousControler(tp) and ec:IsReason(REASON_DESTROY) and ec:GetReasonPlayer()==1-tp
end
-- 筛选墓地中可以被特殊召唤的「希望皇 霍普」怪兽。
function c2648201.spfilter(c,e,tp)
	return c:IsSetCard(0x107f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动目标处理：确认自己怪兽区有空位，并选择自己墓地1只「希望皇 霍普」怪兽为对象。
function c2648201.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c2648201.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己怪兽区存在空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在1只符合条件的「希望皇 霍普」怪兽能够被选择为对象。
		and Duel.IsExistingTarget(c2648201.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只符合条件的「希望皇 霍普」怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c2648201.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置处理信息：本次效果将进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果处理：将选择的「希望皇 霍普」怪兽以表侧表示特殊召唤到自己场上。
function c2648201.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
