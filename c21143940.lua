--マスク・チェンジ
-- 效果：
-- ①：以自己场上1只「英雄」怪兽为对象才能发动。把那只怪兽的属性确认，送去墓地。这个效果让那只怪兽从场上离开的场合，再把持有相同属性的1只「假面英雄」怪兽从额外卡组特殊召唤。
function c21143940.initial_effect(c)
	-- ①：以自己场上1只「英雄」怪兽为对象才能发动。把那只怪兽的属性确认，送去墓地。这个效果让那只怪兽从场上离开的场合，再把持有相同属性的1只「假面英雄」怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c21143940.target)
	e1:SetOperation(c21143940.activate)
	c:RegisterEffect(e1)
end
-- 筛选额外卡组中的卡：必须是「假面英雄」怪兽且属性与对象怪兽相同，能够被当前效果特殊召唤，并且从额外卡组特殊召唤时有可用区域（计算对象怪兽离场后的空位）。
function c21143940.tfilter(c,att,e,tp,tc)
	return c:IsSetCard(0xa008) and c:IsAttribute(att)
		-- 追加判定该「假面英雄」怪兽能否被此效果特殊召唤，以及在对象怪兽离场后额外卡组怪兽能特殊召唤的区域仍有空位。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,true) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 筛选可作为对象的怪兽：自己场上表侧表示的「英雄」怪兽，且额外卡组中存在满足条件的可特殊召唤的「假面英雄」怪兽。
function c21143940.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x8)
		-- 确认额外卡组中存在至少1只属性与这张「英雄」怪兽相同的「假面英雄」怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c21143940.tfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetAttribute(),e,tp,c)
end
-- 用于连锁选择时确认对象仍然有效：对象必须是自己场上表侧表示的「英雄」怪兽，且其属性包含效果记录的要求属性（由于发动时记录的是对象属性，此处用位运算检查）。
function c21143940.chkfilter(c,att)
	return c:IsFaceup() and c:IsSetCard(0x8) and (c:GetAttribute()&att)==att
end
-- 发动时的目标处理：检查是否存在合法对象；让玩家选择自己场上1只符合条件的「英雄」怪兽，将其设为效果对象；记录对象属性到效果标签，并设置特殊召唤的操作信息。
function c21143940.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c21143940.chkfilter(chkc,e:GetLabel()) end
	-- 发动条件判定（非连锁时）：检查自己场上是否存在至少1只符合条件的「英雄」怪兽（表侧表示且额外卡组有对应属性「假面英雄」可特殊召唤）。
	if chk==0 then return Duel.IsExistingTarget(c21143940.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 显示选择提示消息，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1只符合条件的「英雄」怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c21143940.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：此效果处理中可能进行特殊召唤，目标区域为额外卡组（用于给其他卡响应时检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	e:SetLabel(g:GetFirst():GetAttribute())
end
-- 效果处理：确认对象仍与效果关联；获取对象属性并将其送去墓地；若送墓成功，则从额外卡组选择1只相同属性且可特殊召唤的「假面英雄」怪兽；然后用中断效果处理的方式将其特殊召唤，并补办正规召唤手续。
function c21143940.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local att=tc:GetAttribute()
	-- 将对象怪兽送去墓地，若没有成功送去墓地（如受其他效果影响无法送墓），则终止处理，不进行后续特殊召唤。
	if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
	-- 显示选择提示消息，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的「假面英雄」怪兽：持有与对象怪兽相同的属性，且能被效果特殊召唤。
	local sg=Duel.SelectMatchingCard(tp,c21143940.tfilter,tp,LOCATION_EXTRA,0,1,1,nil,att,e,tp,nil)
	if sg:GetCount()>0 then
		-- 中断当前效果处理，使后续特殊召唤作为不同时点处理，以契合『送去墓地后，再从额外卡组特殊召唤』的先后顺序并正确对应时点。
		Duel.BreakEffect()
		-- 将选择的「假面英雄」怪兽表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,true,POS_FACEUP)
		sg:GetFirst():CompleteProcedure()
	end
end
