--ウイングトータス
-- 效果：
-- 自己场上表侧表示存在的鱼族·海龙族·水族怪兽从游戏中除外时，这张卡可以从手卡或者自己墓地特殊召唤。
function c10132124.initial_effect(c)
	-- 自己场上表侧表示存在的鱼族·海龙族·水族怪兽从游戏中除外时，这张卡可以从手卡或者自己墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10132124,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c10132124.spcon)
	e1:SetTarget(c10132124.sptg)
	e1:SetOperation(c10132124.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示存在的鱼族·海龙族·水族怪兽
function c10132124.spfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 判断除外的卡之中是否存在满足条件的卡
function c10132124.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c10132124.spfilter,1,nil,tp)
end
-- 检测是否可以把此卡特殊召唤
function c10132124.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有可用的主要怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前处理的连锁信息：包含特殊召唤自身的效果分类
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤此卡效果的处理
function c10132124.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
