--スクラップ・サーチャー
-- 效果：
-- 这张卡在墓地存在，自己场上存在的「废铁搜索鸟」以外的名字带有「废铁」的怪兽被破坏送去墓地时，这张卡可以从墓地特殊召唤。这张卡特殊召唤成功时，名字带有「废铁」的怪兽以外的自己场上表侧表示存在的怪兽全部破坏。
function c92901944.initial_effect(c)
	-- 这张卡在墓地存在，自己场上存在的「废铁搜索鸟」以外的名字带有「废铁」的怪兽被破坏送去墓地时，这张卡可以从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92901944,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c92901944.spcon)
	e1:SetTarget(c92901944.sptg)
	e1:SetOperation(c92901944.spop)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功时，名字带有「废铁」的怪兽以外的自己场上表侧表示存在的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92901944,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c92901944.destg)
	e2:SetOperation(c92901944.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示存在的「废铁搜索鸟」以外的名字带有「废铁」的怪兽被破坏送去墓地
function c92901944.cfilter(c,tp)
	return c:IsSetCard(0x24) and not c:IsCode(92901944) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 特殊召唤效果的发动条件：检查送去墓地的卡中是否存在满足过滤条件的怪兽，且不包含自身
function c92901944.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c92901944.cfilter,1,e:GetHandler(),tp) and not eg:IsContains(e:GetHandler())
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位及自身是否能特殊召唤
function c92901944.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的实际处理：将自身特殊召唤
function c92901944.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示存在的「废铁」怪兽以外的怪兽
function c92901944.desfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x24)
end
-- 破坏效果的发动准备：获取需要破坏的怪兽并设置操作信息
function c92901944.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上所有满足过滤条件的怪兽（表侧表示且非「废铁」怪兽）
	local g=Duel.GetMatchingGroup(c92901944.desfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置连锁处理的操作信息：破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的实际处理：破坏自己场上所有非「废铁」的表侧表示怪兽
function c92901944.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取当前自己场上所有满足过滤条件的怪兽
	local g=Duel.GetMatchingGroup(c92901944.desfilter,tp,LOCATION_MZONE,0,nil)
	-- 因效果破坏这些怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
