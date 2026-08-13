--ギガンテック・ファイター／バスター
-- 效果：
-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。只要这张卡在场上表侧表示存在，全部对方怪兽的攻击力下降自己墓地存在的战士族怪兽数量×100的数值。这张卡特殊召唤成功时，可以从自己卡组选择最多2只战士族怪兽送去墓地。此外，场上存在的这张卡被破坏时，可以把自己墓地存在的1只「巨人斗士」特殊召唤。
function c38898779.initial_effect(c)
	-- 记录此卡上记载的『爆裂模式』的卡号（80280737），用于规则上关联该卡名。
	aux.AddCodeList(c,80280737)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设定特殊召唤条件判定函数为 aux.AssaultModeLimit，仅当通过《爆裂模式》的效果或以爆裂体方式特殊召唤时才允许这次特殊召唤。
	e1:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功时，可以从自己卡组选择最多2只战士族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38898779,0))  --"送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c38898779.tgtg)
	e2:SetOperation(c38898779.tgop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，全部对方怪兽的攻击力下降自己墓地存在的战士族怪兽数量×100的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c38898779.atkval)
	c:RegisterEffect(e3)
	-- 此外，场上存在的这张卡被破坏时，可以把自己墓地存在的1只「巨人斗士」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38898779,1))  --"特殊召唤「巨人斗士」"
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c38898779.spcon)
	e4:SetTarget(c38898779.sptg)
	e4:SetOperation(c38898779.spop)
	c:RegisterEffect(e4)
end
c38898779.assault_name=23693634
-- 定义送墓用过滤函数：选择自己卡组中种族为战士族且可以被送去墓地的怪兽。
function c38898779.tgfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToGrave()
end
-- 定义特殊召唤成功时送墓效果的目标判定：发动时检查卡组是否存在符合条件的战士族怪兽，并设置操作为从卡组送墓。
function c38898779.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在效果发动条件检查中，确认卡组中存在至少1只满足 tgfilter 条件的战士族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c38898779.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息为『送去墓地』，目标范围为卡组，数量为1，用于相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行送墓操作：由玩家从卡组选择1到2只符合条件的战士族怪兽，然后以效果原因送去墓地。
function c38898779.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示『请选择要送去墓地的卡』的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的卡组中选择1到2只符合 tgfilter 条件的战士族怪兽。
	local g=Duel.SelectMatchingCard(tp,c38898779.tgfilter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选择的一组怪兽以效果原因 REASON_EFFECT 送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义对方怪兽攻击力的增减值计算函数：根据自己墓地中战士族怪兽的数量决定下降数值。
function c38898779.atkval(e,c)
	-- 取得自己墓地中战士族怪兽的数量并乘以-100，作为对方怪兽攻击力的下降值。
	return Duel.GetMatchingGroupCount(Card.IsRace,e:GetHandler():GetControler(),LOCATION_GRAVE,0,nil,RACE_WARRIOR)*-100
end
-- 破坏效果发动条件：这张卡被破坏前存在于场上（即从场上被破坏）时允许发动。
function c38898779.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义可特殊召唤的对象的过滤条件：卡名是「巨人斗士」且能够被当前效果特殊召唤。
function c38898779.spfilter(c,e,tp)
	return c:IsCode(23693634) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义破坏时特召效果的目标判定：若已指定对象则验证其位于自己墓地且满足条件；发动时则检查场上有空位且墓地存在符合条件的对象。
function c38898779.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38898779.spfilter(chkc,e,tp) end
	-- 在发动条件检查中，确认自己主要怪兽区域存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动条件检查中，确认墓地存在至少1只符合条件的「巨人斗士」可以作为特殊召唤的对象。
		and Duel.IsExistingTarget(c38898779.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示『请选择要特殊召唤的卡』的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「巨人斗士」作为效果对象。
	local g=Duel.SelectTarget(tp,c38898779.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息为『特殊召唤』，对象为选中的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤处理：取得效果对象，若对象仍与效果关联，则将其特殊召唤到自己场上。
function c38898779.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第一个效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己场上，不检测召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
