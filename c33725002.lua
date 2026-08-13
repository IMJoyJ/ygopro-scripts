--Vサラマンダー
-- 效果：
-- 这张卡召唤成功时，可以选择自己墓地1只名字带有「希望皇 霍普」的怪兽特殊召唤。自己的主要阶段时，场上的这只怪兽可以给自己的「混沌No.39 希望皇 霍普雷V」装备。这张卡装备中的场合，1回合1次，把装备怪兽1个超量素材取除才能发动。装备怪兽的效果无效，对方场上的怪兽全部破坏，给与对方基本分那个数量×1000的数值的伤害。
function c33725002.initial_effect(c)
	-- 这张卡召唤成功时，可以选择自己墓地1只名字带有「希望皇 霍普」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33725002,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c33725002.sptg)
	e1:SetOperation(c33725002.spop)
	c:RegisterEffect(e1)
	-- 自己的主要阶段时，场上的这只怪兽可以给自己的「混沌No.39 希望皇 霍普雷V」装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33725002,1))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c33725002.eqtg)
	e2:SetOperation(c33725002.eqop)
	c:RegisterEffect(e2)
	-- 这张卡装备中的场合，1回合1次，把装备怪兽1个超量素材取除才能发动。装备怪兽的效果无效，对方场上的怪兽全部破坏，给与对方基本分那个数量×1000的数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33725002,2))  --"破坏并伤害"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c33725002.descost)
	e3:SetTarget(c33725002.destg)
	e3:SetOperation(c33725002.desop)
	c:RegisterEffect(e3)
end
-- 筛选墓地中符合『希望皇 霍普』字段且可以被特殊召唤的怪兽。
function c33725002.spfilter(c,e,tp)
	return c:IsSetCard(0x107f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标合法性与发动条件检查：对象必须是自己墓地可特殊召唤的『希望皇 霍普』字段怪兽，且自己场上需有空位。
function c33725002.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33725002.spfilter(chkc,e,tp) end
	-- 发动条件：自己场上有可以特殊召唤的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件：自己墓地存在至少1只满足『希望皇 霍普』字段且可特殊召唤的怪兽，且该怪兽能成为此效果的对象。
		and Duel.IsExistingTarget(c33725002.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示『请选择要特殊召唤的卡』的提示信息，用于选择卡牌时的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的『希望皇 霍普』怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c33725002.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次效果将进行特殊召唤的操作信息，对象为选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果处理：获取效果对象，确认对象仍与效果关联后，以表侧表示特殊召唤到己方场上。
function c33725002.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤效果处理时锁定的对象卡（之前选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 装备对象过滤器：选择己方场上表侧表示且卡名为『混沌No.39 希望皇 霍普雷V』的怪兽作为装备对象。
function c33725002.eqfilter(c)
	return c:IsFaceup() and c:IsCode(66970002)
end
-- 装备效果的发动条件与对象合法性判定：确认己方魔陷区有空位，且己方场上存在表侧表示的『混沌No.39 希望皇 霍普雷V』可作为对象。
function c33725002.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33725002.eqfilter(chkc) end
	-- 发动条件：己方魔陷区存在可使用的区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件：己方场上存在表侧表示的『混沌No.39 希望皇 霍普雷V』，且该怪兽能成为装备效果的对象。
		and Duel.IsExistingTarget(c33725002.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示『请选择要装备的卡』的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择己方场上1只表侧表示的『混沌No.39 希望皇 霍普雷V』作为装备对象。
	Duel.SelectTarget(tp,c33725002.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备处理：将这张卡装备给目标『混沌No.39 希望皇 霍普雷V』；若自身或对象已不满足装备条件，则这张卡送去墓地。
function c33725002.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取装备效果处理时锁定的装备对象（要装备给的霍普雷V）。
	local tc=Duel.GetFirstTarget()
	-- 装备合法性判断：若魔陷区无空位、目标已不是己方控制、目标变为里侧表示或与效果失去关联，则装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备条件不满足时，将这张卡以效果原因送入墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标『混沌No.39 希望皇 霍普雷V』。
	Duel.Equip(tp,c,tc)
	-- 自己的主要阶段时，场上的这只怪兽可以给自己的「混沌No.39 希望皇 霍普雷V」装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c33725002.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制判定：这张卡只允许装备给之前选择的那只『混沌No.39 希望皇 霍普雷V』。
function c33725002.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 发动代价：需要这张卡处于装备状态且装备怪兽有超量素材，取除其1个超量素材。
function c33725002.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipTarget() and c:GetEquipTarget():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:GetEquipTarget():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 破坏伤害效果的发动条件与操作信息：确认对方场上有怪兽；登记将破坏对方场上全部怪兽，并造成数量×1000的伤害。
function c33725002.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：对方场上的怪兽区域存在至少1只怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的全部怪兽作为准备破坏的对象集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 登记操作信息：将对方场上全部怪兽破坏，数量为获取的怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 登记操作信息：对对方造成破坏数量×1000的伤害，目标为对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*1000)
end
-- 破坏伤害效果处理：若这张卡仍装备中，先令装备怪兽的效果无效；然后破坏对方场上全部怪兽，若破坏数量大于0则给予对方该数量×1000的伤害。
function c33725002.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec then
		-- 装备怪兽的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
		-- 装备怪兽的效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2)
	end
	-- 效果处理时重新获取对方场上的全部怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 破坏对方场上全部怪兽，并记录实际被破坏的数量。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 根据实际破坏的怪兽数量，给予对方玩家数量×1000的伤害。
		Duel.Damage(1-tp,ct*1000,REASON_EFFECT)
	end
end
