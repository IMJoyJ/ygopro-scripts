--エクシーズ・リベンジ
-- 效果：
-- 对方场上有持有超量素材的超量怪兽存在的场合，选择自己墓地1只超量怪兽才能发动。选择的怪兽特殊召唤，把对方场上1个超量素材在选择的怪兽下面重叠作为超量素材。「超量复仇」在1回合只能发动1张。
function c10275411.initial_effect(c)
	-- 对方场上有持有超量素材的超量怪兽存在的场合，选择自己墓地1只超量怪兽才能发动。选择的怪兽特殊召唤，把对方场上1个超量素材在选择的怪兽下面重叠作为超量素材。「超量复仇」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,10275411+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c10275411.condition)
	e1:SetTarget(c10275411.target)
	e1:SetOperation(c10275411.activate)
	c:RegisterEffect(e1)
end
-- 过滤对方场上持有超量素材的怪兽。
function c10275411.cfilter(c)
	return c:IsFaceup() and c:GetOverlayCount()>0
end
-- 发动条件判定函数。
function c10275411.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在持有超量素材的怪兽。
	return Duel.IsExistingMatchingCard(c10275411.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 过滤自己墓地可以特殊召唤的超量怪兽。
function c10275411.filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标选择与合法性检查函数。
function c10275411.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10275411.filter(chkc,e,tp) end
	-- 检查发动者场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的超量怪兽作为效果对象。
		and Duel.IsExistingTarget(c10275411.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置选择特殊召唤卡片时的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择自己墓地1只超量怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c10275411.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，用于后续处理判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理执行函数。
function c10275411.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的超量怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 若对象合法则将其特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取对方场上怪兽持有的所有超量素材。
		local g1=Duel.GetOverlayGroup(tp,0,1)
		if g1:GetCount()==0 then return end
		-- 中断当前处理，使后续重叠素材的操作不与特殊召唤视为同时处理。
		Duel.BreakEffect()
		-- 提示玩家选择要转移的超量素材。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(10275411,0))  --"请选择要转移的素材"
		local mg=g1:Select(tp,1,1,nil)
		local oc=mg:GetFirst():GetOverlayTarget()
		-- 将选取的素材重叠至特殊召唤的怪兽下作为超量素材。
		Duel.Overlay(tc,mg)
		-- 触发该怪兽失去超量素材的单体事件。
		Duel.RaiseSingleEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		-- 触发该怪兽失去超量素材的全局事件。
		Duel.RaiseEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
end
