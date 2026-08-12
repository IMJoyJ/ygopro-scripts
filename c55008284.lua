--同姓同名同盟
-- 效果：
-- 选择自己场上表侧表示存在的1只2星以下的通常怪兽发动。从自己卡组把和选择的卡同名的卡尽可能在自己场上特殊召唤。
function c55008284.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只2星以下的通常怪兽发动。从自己卡组把和选择的卡同名的卡尽可能在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c55008284.target)
	e1:SetOperation(c55008284.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中与目标卡同名且可以特殊召唤的怪兽
function c55008284.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤自己场上表侧表示的2星以下通常怪兽，且卡组中存在至少1张同名卡
function c55008284.filter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(2) and c:IsType(TYPE_NORMAL)
		-- 检查卡组中是否存在至少1张与该怪兽同名且可以特殊召唤的卡
		and Duel.IsExistingMatchingCard(c55008284.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 效果发动时的目标选择与合法性检测
function c55008284.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c55008284.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c55008284.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c55008284.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示此效果包含从卡组特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组尽可能特殊召唤同名怪兽
function c55008284.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 从卡组中获取所有与目标怪兽同名且可以特殊召唤的卡
	local g=Duel.GetMatchingGroup(c55008284.spfilter,tp,LOCATION_DECK,0,nil,e,tp,tc:GetCode())
	local sc=g:GetFirst()
	while ft>0 and sc do
		-- 将同名怪兽以表侧表示特殊召唤的单步处理
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		ft=ft-1
		sc=g:GetNext()
	end
	-- 完成特殊召唤的流程处理
	Duel.SpecialSummonComplete()
end
