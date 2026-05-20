--アマゾネスペット虎獅王
-- 效果：
-- 5星以上的「亚马逊」怪兽＋「亚马逊」怪兽
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，对方怪兽不能向这张卡以外的怪兽攻击。
-- ②：以自己场上1张「亚马逊」卡和自己墓地1只战士族「亚马逊」怪兽为对象才能发动。作为对象的场上的卡破坏，作为对象的墓地的怪兽特殊召唤。这个效果发动的回合，这张卡不能攻击。
function c59353647.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为：5星以上的「亚马逊」怪兽＋「亚马逊」怪兽。
	aux.AddFusionProcFun2(c,c59353647.matfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0x4),true)
	-- ①：只要这张卡在怪兽区域存在，对方怪兽不能向这张卡以外的怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c59353647.atlimit)
	c:RegisterEffect(e1)
	-- ②：以自己场上1张「亚马逊」卡和自己墓地1只战士族「亚马逊」怪兽为对象才能发动。作为对象的场上的卡破坏，作为对象的墓地的怪兽特殊召唤。这个效果发动的回合，这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,59353647)
	e2:SetCost(c59353647.cost)
	e2:SetTarget(c59353647.target)
	e2:SetOperation(c59353647.operation)
	c:RegisterEffect(e2)
end
-- 过滤融合素材中5星以上的「亚马逊」怪兽。
function c59353647.matfilter(c)
	return c:IsLevelAbove(5) and c:IsFusionSetCard(0x4)
end
-- 限制对方不能选择此卡以外的怪兽作为攻击对象。
function c59353647.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 检查本回合是否未攻击，并给自身添加本回合不能攻击的限制。
function c59353647.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- ②：以自己场上1张「亚马逊」卡和自己墓地1只战士族「亚马逊」怪兽为对象才能发动。作为对象的场上的卡破坏，作为对象的墓地的怪兽特殊召唤。这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1,true)
end
-- 过滤自己场上表侧表示的「亚马逊」卡，且该卡离开场上后有可用的怪兽区域。
function c59353647.desfilter(c,tp)
	-- 判断卡片是否为表侧表示的「亚马逊」卡，且该卡离开场上后自己场上有可用于特殊召唤的怪兽区域。
	return c:IsFaceup() and c:IsSetCard(0x4) and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤自己墓地中可以特殊召唤的战士族「亚马逊」怪兽。
function c59353647.spfilter(c,e,tp)
	return c:IsSetCard(0x4) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向选择，在场上和墓地分别选择1张合法的卡作为对象。
function c59353647.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	-- 检查自己场上是否存在可作为破坏对象的表侧表示「亚马逊」卡。
	if chk==0 then return Duel.IsExistingTarget(c59353647.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		-- 检查自己墓地是否存在可作为特殊召唤对象的战士族「亚马逊」怪兽。
		and Duel.IsExistingTarget(c59353647.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的「亚马逊」卡作为破坏对象。
	local g1=Duel.SelectTarget(tp,c59353647.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只战士族「亚马逊」怪兽作为特殊召唤对象。
	local g2=Duel.SelectTarget(tp,c59353647.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置破坏操作的连锁信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置特殊召唤操作的连锁信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	e:SetLabelObject(g1:GetFirst())
end
-- 效果②的处理，破坏作为对象的场上的卡，并特殊召唤作为对象的墓地的怪兽。
function c59353647.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的两个对象卡。
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 若场上的对象卡成功破坏，且墓地的对象卡仍合法，则进行特殊召唤的处理。
	if tc1:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)>0 and tc2:IsRelateToEffect(e) then
		-- 将作为对象的墓地怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
