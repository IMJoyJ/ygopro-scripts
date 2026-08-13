--継承の印
-- 效果：
-- 自己墓地有3张同名怪兽卡存在时发动。选择那些怪兽的其中1只在自己场上特殊召唤，并装备这张卡。这张卡破坏时，装备怪兽破坏。
function c45305419.initial_effect(c)
	-- 对应效果原文“自己墓地有3张同名怪兽卡存在时发动。选择那些怪兽的其中1只在自己场上特殊召唤，并装备这张卡。”，注册发动效果：启动时点自由发动，取对象，设置发动条件和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c45305419.target)
	e1:SetOperation(c45305419.operation)
	c:RegisterEffect(e1)
	-- 对应效果原文“这张卡破坏时，装备怪兽破坏。”，注册持续效果：当这张卡离场时触发后续处理，实际在破坏时让装备怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c45305419.desop)
	c:RegisterEffect(e2)
end
-- 过滤器：判断候选怪兽能否被特殊召唤，且自己墓地除它以外还存在至少2张同名怪兽卡，即墓地里合计有3张同名怪兽满足发动条件。
function c45305419.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地是否存在至少2张与候选怪兽同卡名的卡（排除候选怪兽自身），用于确认墓地有3张同名怪兽。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,2,c,c:GetCode())
end
-- 发动合法性与取对象逻辑：非连锁时确认主怪兽区有空位，且墓地存在满足条件的同名怪兽；发动时选择其中1只作为对象。
function c45305419.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45305419.filter(chkc,e,tp) end
	-- 检查自己场上是否存在可用的主要怪兽区域，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件且能够成为效果对象的同名怪兽卡。
		and Duel.IsExistingTarget(c45305419.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1张满足条件的同名怪兽，并将其设定为本效果的对象。
	local g=Duel.SelectTarget(tp,c45305419.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息：本次效果将进行1只怪兽的特殊召唤，对象为选定的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置连锁处理信息：本次效果会将这张“继承之印”装备给特殊召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义装备限制条件：这张装备卡只能装备给通过本效果特殊召唤的那只怪兽（效果所有者即为该怪兽），防止装备对象转移。
function c45305419.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：若发动卡和对象怪兽仍与效果相关，则将对象怪兽特殊召唤；成功后把“继承之印”装备给它，并设置装备限制效果。
function c45305419.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将对象怪兽表侧表示特殊召唤到己方场上；若特殊召唤失败则终止后续处理。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 将这张“继承之印”作为装备卡装备给特殊召唤成功的那只怪兽。
		Duel.Equip(tp,c,tc)
		-- 对应效果原文“并装备这张卡”，通过给装备卡设置装备限制效果，确保此卡只能装备给当前特殊召唤的怪兽。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c45305419.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 离场触发处理：当这张卡因破坏而离场时，若它当前装备的怪兽仍在场上，则将该装备怪兽破坏。
function c45305419.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if c:IsReason(REASON_DESTROY) and tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果破坏的方式将装备怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
