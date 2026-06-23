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
-- 特殊召唤发动条件的过滤条件：是场上表侧表示存在且持有超量素材的怪兽
function c10275411.cfilter(c)
	return c:IsFaceup() and c:GetOverlayCount()>0
end
-- 发动条件：对方场上有持有超量素材的超量怪兽存在
function c10275411.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只满足过滤条件的怪兽并返回结果
	return Duel.IsExistingMatchingCard(c10275411.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 特殊召唤目标的过滤条件：是超量怪兽且可以被特殊召唤
function c10275411.filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 靶指向与发动检测：选择自己墓地1只超量怪兽为对象，并设置连锁操作信息为特殊召唤该怪兽
function c10275411.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10275411.filter(chkc,e,tp) end
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地是否存在可以特殊召唤的超量怪兽并返回结果
		and Duel.IsExistingTarget(c10275411.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向发动效果的玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择墓地中1只满足条件的卡片作为效果的对象
	local g=Duel.SelectTarget(tp,c10275411.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息为特殊召唤选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将作为对象的超量怪兽特殊召唤，若成功特殊召唤，则选择对方场上1个超量素材在该怪兽下面重叠作为超量素材
function c10275411.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若该对象卡仍关联当前连锁，将其表侧表示特殊召唤，若特殊召唤成功则执行后续处理
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取对方场上所有叠放的超量素材
		local g1=Duel.GetOverlayGroup(tp,0,1)
		if g1:GetCount()==0 then return end
		-- 中断当前效果处理，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 向发动效果的玩家提示选择要转移的素材
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(10275411,0))  --"请选择要转移的素材"
		local mg=g1:Select(tp,1,1,nil)
		local oc=mg:GetFirst():GetOverlayTarget()
		-- 将被选中的卡片重叠在已特殊召唤的怪兽下面作为超量素材
		Duel.Overlay(tc,mg)
		-- 为此超量素材原本所重叠的怪兽触发“去除超量素材时”的单体事件时点
		Duel.RaiseSingleEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		-- 为此超量素材原本所重叠的怪兽触发“去除超量素材时”的事件时点
		Duel.RaiseEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
end
