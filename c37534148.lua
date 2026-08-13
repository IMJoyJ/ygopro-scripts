--リボーンリボン
-- 效果：
-- 装备怪兽被战斗破坏送去墓地的场合，那个回合的结束阶段时把那只怪兽在自己场上特殊召唤。
function c37534148.initial_effect(c)
	-- 对应效果原文中的“装备怪兽”：作为装备魔法发动，选择场上1只表侧表示怪兽作为装备对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c37534148.target)
	e1:SetOperation(c37534148.operation)
	c:RegisterEffect(e1)
	-- 对应效果原文中的“装备怪兽”：装备对象必须是可以特殊召唤的怪兽（不受“不能特殊召唤”效果影响）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c37534148.eqlimit)
	c:RegisterEffect(e2)
	-- 对应效果原文中的“装备怪兽被战斗破坏送去墓地的场合”：当装备卡因装备怪兽被战斗破坏而失去装备对象并送去墓地时触发。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c37534148.regcon)
	e3:SetOperation(c37534148.regop)
	c:RegisterEffect(e3)
end
-- 装备限制判定：若目标怪兽带有“不能特殊召唤”效果，则不能装备，否则后续效果无法将其特殊召唤。
function c37534148.eqlimit(e,c)
	return not c:IsHasEffect(EFFECT_CANNOT_SPECIAL_SUMMON)
end
-- 筛选条件：选择场上表侧表示且不受“不能特殊召唤”效果影响的怪兽作为装备对象。
function c37534148.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_CANNOT_SPECIAL_SUMMON)
end
-- 装备魔法发动时的目标处理：选择我方或对方场上1只符合条件的怪兽作为装备对象，并设置装备操作信息。
function c37534148.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37534148.filter(chkc) end
	-- 发动时点检查：若场上不存在符合条件的表侧表示怪兽，则不能发动此卡。
	if chk==0 then return Duel.IsExistingTarget(c37534148.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择要装备的卡”的提示，用于选择装备怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让操作者从符合条件的怪兽中选择1只，并将其登记为这张卡的效果对象。
	Duel.SelectTarget(tp,c37534148.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次发动的效果分类为装备，对象为这张装备魔法卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法发动后的处理：若此卡和目标怪兽仍与效果相关且目标仍为表侧表示，则将此卡装备给目标怪兽。
function c37534148.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时确认的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将此卡装备到目标怪兽的魔法与陷阱区。
		Duel.Equip(tp,c,tc)
	end
end
-- 触发条件判定：装备卡因失去装备对象而送去墓地，且原装备对象是被战斗破坏并正处于墓地中的怪兽。
function c37534148.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_BATTLE) and ec:IsLocation(LOCATION_GRAVE)
end
-- 满足条件时，在墓地注册一个结束阶段必发的特殊召唤效果，并给原装备对象怪兽设置标记，防止重复处理。
function c37534148.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	-- 对应效果原文中的“那个回合的结束阶段时把那只怪兽在自己场上特殊召唤”：在结束阶段将那只被战斗破坏的怪兽特殊召唤到自己场上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37534148,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetTarget(c37534148.sptg)
	e1:SetOperation(c37534148.spop)
	e1:SetLabelObject(ec)
	e1:SetReset(RESET_EVENT+0x16c0000+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
	ec:RegisterFlagEffect(37534148,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 结束阶段特殊召唤效果的目标处理：确定要特殊召唤的是之前被战斗破坏并带有标记的装备怪兽。
function c37534148.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetPreviousEquipTarget()
	if chk==0 then return ec:GetFlagEffect(37534148)~=0 end
	-- 将需要特殊召唤的怪兽登记为当前效果的处理对象。
	Duel.SetTargetCard(ec)
	-- 设置操作信息：本次效果处理包含特殊召唤该怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,ec,1,0,0)
end
-- 结束阶段效果的实际处理：若我方怪兽区有空位且对象怪兽仍与效果相关，则将其特殊召唤。
function c37534148.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方主要怪兽区没有可用格子，则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取要特殊召唤的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将被战斗破坏的装备怪兽以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
