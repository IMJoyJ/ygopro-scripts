--炎星侯－ホウシン
-- 效果：
-- 炎属性调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤成功时才能发动。从卡组把1只炎属性·3星怪兽特殊召唤。
-- ②：这张卡同调召唤成功的回合，自己不能把5星以上的怪兽特殊召唤。
function c74168099.initial_effect(c)
	-- 设置同调召唤手续：炎属性调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功时才能发动。从卡组把1只炎属性·3星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74168099,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c74168099.spcon)
	e1:SetTarget(c74168099.sptg)
	e1:SetOperation(c74168099.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡同调召唤成功的回合，自己不能把5星以上的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c74168099.spcon)
	e2:SetOperation(c74168099.regop)
	c:RegisterEffect(e2)
end
-- 检查发动条件：这张卡是否同调召唤成功
function c74168099.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤卡组中满足条件的卡：炎属性、3星且可以特殊召唤的怪兽
function c74168099.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标：检查怪兽区域是否有空位，以及卡组中是否存在满足条件的怪兽
function c74168099.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上是否有可以特殊召唤怪兽的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c74168099.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的怪兽特殊召唤
function c74168099.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c74168099.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 注册限制效果：在同调召唤成功的回合，给玩家施加不能特殊召唤5星以上怪兽的限制
function c74168099.regop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：这张卡同调召唤成功的回合，自己不能把5星以上的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c74168099.splimit)
	e1:SetLabelObject(e)
	-- 将不能特殊召唤5星以上怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的怪兽过滤：等级在5星以上的怪兽
function c74168099.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLevelAbove(5)
end
