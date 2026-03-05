--ZW－玄武絶対聖盾
-- 效果：
-- 这张卡召唤·特殊召唤成功时，可以选择从游戏中除外的1只自己的超量怪兽表侧守备表示特殊召唤。此外，自己的主要阶段时，场上的这只怪兽可以当作守备力上升2000的装备卡使用给自己场上的名字带有「希望皇 霍普」的怪兽装备。「异热同心武器-玄武绝对圣盾」在自己场上只能有1张表侧表示存在。
function c18865703.initial_effect(c)
	c:SetUniqueOnField(1,0,18865703)
	-- 这张卡召唤·特殊召唤成功时，可以选择从游戏中除外的1只自己的超量怪兽表侧守备表示特殊召唤。此外，自己的主要阶段时，场上的这只怪兽可以当作守备力上升2000的装备卡使用给自己场上的名字带有「希望皇 霍普」的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18865703,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c18865703.eqcon)
	e1:SetTarget(c18865703.eqtg)
	e1:SetOperation(c18865703.eqop)
	c:RegisterEffect(e1)
	-- 「异热同心武器-玄武绝对圣盾」在自己场上只能有1张表侧表示存在。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18865703,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetTarget(c18865703.sptg)
	e2:SetOperation(c18865703.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果适用时，检查此卡是否满足唯一性条件。
function c18865703.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 过滤满足条件的怪兽（名字带有「希望皇 霍普」且表侧表示）。
function c18865703.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 设置装备效果的目标选择条件，选择自己场上的名字带有「希望皇 霍普」的怪兽。
function c18865703.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c18865703.filter(chkc) end
	-- 判断是否满足装备条件，即玩家魔陷区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足装备条件，即是否存在满足条件的怪兽。
		and Duel.IsExistingTarget(c18865703.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的怪兽作为装备对象。
	Duel.SelectTarget(tp,c18865703.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行装备操作，若条件不满足则将装备卡送入墓地。
function c18865703.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取装备效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足，包括魔陷区空位、目标怪兽控制权、表示形式等。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若装备条件不满足，将装备卡送入墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c18865703.zw_equip_monster(c,tp,tc)
end
-- 执行装备卡的装备操作，包括设置装备限制和守备力加成效果。
function c18865703.zw_equip_monster(c,tp,tc)
	-- 尝试将装备卡装备给目标怪兽，若失败则返回。
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备卡的装备对象限制，只能装备给特定怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c18865703.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 设置装备卡的守备力加成效果，使装备怪兽守备力上升2000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(2000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备对象限制的判断函数，判断目标怪兽是否为设定的装备对象。
function c18865703.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤满足条件的超量怪兽（表侧表示、超量怪兽类型、可特殊召唤）。
function c18865703.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置特殊召唤效果的目标选择条件，选择自己除外区的超量怪兽。
function c18865703.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c18865703.spfilter(chkc,e,tp) end
	-- 判断是否满足特殊召唤条件，即是否存在满足条件的除外怪兽。
	if chk==0 then return Duel.IsExistingTarget(c18865703.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		-- 判断是否满足特殊召唤条件，即玩家怪兽区是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的除外怪兽作为特殊召唤对象。
	local g=Duel.SelectTarget(tp,c18865703.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置特殊召唤效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将目标怪兽特殊召唤到场上。
function c18865703.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
