--ZW－玄武絶対聖盾
-- 效果：
-- 这张卡召唤·特殊召唤成功时，可以选择从游戏中除外的1只自己的超量怪兽表侧守备表示特殊召唤。此外，自己的主要阶段时，场上的这只怪兽可以当作守备力上升2000的装备卡使用给自己场上的名字带有「希望皇 霍普」的怪兽装备。「异热同心武器-玄武绝对圣盾」在自己场上只能有1张表侧表示存在。
function c18865703.initial_effect(c)
	c:SetUniqueOnField(1,0,18865703)
	-- 此外，自己的主要阶段时，场上的这只怪兽可以当作守备力上升2000的装备卡使用给自己场上的名字带有「希望皇 霍普」的怪兽装备。
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
	-- 这张卡召唤·特殊召唤成功时，可以选择从游戏中除外的1只自己的超量怪兽表侧守备表示特殊召唤。
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
-- 装备效果的发动条件：检查此卡在自己场上是否满足「只能有1张表侧表示存在」的场上唯一性限制。
function c18865703.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 筛选可作为装备对象的卡：表侧表示且卡名包含「希望皇 霍普」（0x107f）的怪兽。
function c18865703.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 装备效果的取对象处理：若指定对象则校验其是否为表侧表示且含「希望皇 霍普」的我方场上怪兽；发动时还需满足魔陷区有空位，并选择1张符合条件的怪兽作为装备对象。
function c18865703.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c18865703.filter(chkc) end
	-- 发动条件之一：自己的魔陷区存在可用空格，用于放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且场上存在至少1张表侧表示且含「希望皇 霍普」的我方怪兽可以作为装备对象。
		and Duel.IsExistingTarget(c18865703.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示“请选择要装备的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1张符合条件的「希望皇 霍普」怪兽作为装备对象，并将其设为效果对象。
	Duel.SelectTarget(tp,c18865703.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果处理：若此卡仍与效果关联且表侧表示，且魔陷区有空格、装备对象合法、此卡仍满足场上唯一性，则将其作为装备卡装备给对象；否则将此卡送去墓地。
function c18865703.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 取得装备效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断是否无法装备：魔陷区无空格、对象怪兽已不是自己控制/变成里侧/与效果不关联，或此卡不满足场上唯一性。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 装备失败时，将这张卡因效果从场上送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c18865703.zw_equip_monster(c,tp,tc)
end
-- 将这张卡作为装备卡装备给目标怪兽；若成功，则给它设置只能装备给该目标的装备限制，并让它作为装备卡时令对象守备力上升2000。
function c18865703.zw_equip_monster(c,tp,tc)
	-- 尝试将这张卡作为装备卡装备给目标怪兽；若系统判定装备不成功，则直接结束本次处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 给自己场上的名字带有「希望皇 霍普」的怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c18865703.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 守备力上升2000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(2000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制判定：只有当前装备的目标是发动时选择的那只怪兽时才允许继续装备。
function c18865703.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 特殊召唤对象筛选：从除外区选择自己1张表侧表示的超量怪兽，且该怪兽能被效果以表侧守备表示特殊召唤。
function c18865703.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的取对象处理：若指定对象则校验其是否为自己除外区的表侧超量怪兽且可被特殊召唤；发动时需满足除外区存在符合条件的怪兽且自己主要怪兽区有空位，并选择1张作为对象。
function c18865703.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c18865703.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己除外区存在1张符合条件的表侧超量怪兽，且能够以表侧守备表示被特殊召唤。
	if chk==0 then return Duel.IsExistingTarget(c18865703.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		-- 并且自己的主要怪兽区有足够的空格来特殊召唤该怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己除外区选择1张符合条件的超量怪兽作为特殊召唤对象，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c18865703.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：该效果处理时将进行1只怪兽的特殊召唤（对象为已选目标），供连锁处理与效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果处理：取得对象卡，若其仍与效果关联，则将其以表侧守备表示特殊召唤到自己场上。
function c18865703.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得特殊召唤效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
