--デュアル・ソルジャー
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡1回合只有1次不会被战斗破坏。这张卡进行战斗的场合，那次伤害计算后可以从自己卡组把「二重士兵」以外的1只4星以下的二重怪兽在自己场上特殊召唤。
function c68366996.initial_effect(c)
	-- 为卡片添加二重怪兽的通用属性和再度召唤规则
	aux.EnableDualAttribute(c)
	-- ●这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	-- 设置效果在再度召唤状态（当作效果怪兽）时才有效
	e1:SetCondition(aux.IsDualState)
	e1:SetCountLimit(1)
	e1:SetValue(c68366996.valcon)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的场合，那次伤害计算后可以从自己卡组把「二重士兵」以外的1只4星以下的二重怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68366996,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	-- 设置效果在再度召唤状态（当作效果怪兽）时才能发动
	e2:SetCondition(aux.IsDualState)
	e2:SetTarget(c68366996.target)
	e2:SetOperation(c68366996.operation)
	c:RegisterEffect(e2)
end
-- 过滤破坏原因为战斗破坏
function c68366996.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 过滤卡组中「二重士兵」以外的4星以下的二重怪兽，且该怪兽可以被特殊召唤
function c68366996.filter(c,e,tp)
	return not c:IsCode(68366996) and c:IsLevelBelow(4) and c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的可行性检测（Target阶段），检查怪兽区域空位和卡组中是否存在可特召的怪兽，并声明特殊召唤的操作信息
function c68366996.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1张满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c68366996.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（Operation阶段），从卡组选择1只满足条件的二重怪兽特殊召唤到场上
function c68366996.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c68366996.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
