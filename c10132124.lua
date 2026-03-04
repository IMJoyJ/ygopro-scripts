--ウイングトータス
-- 效果：
-- 自己场上表侧表示存在的鱼族·海龙族·水族怪兽从游戏中除外时，这张卡可以从手卡或者自己墓地特殊召唤。
function c10132124.initial_effect(c)
	-- 自己场上表侧表示存在的鱼族·海龙族·水族怪兽从游戏中除外时，这张卡可以从手卡或者自己墓地特殊召唤
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
-- 定义过滤器函数，检查被除外的卡是否满足条件：之前在场上表侧表示、之前在主要怪兽区、之前由自己控制、且为鱼族或海龙族或水族
function c10132124.spfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 定义触发条件函数，检查除外的卡组中是否存在满足spfilter条件的卡（即自己场上表侧表示的鱼族·海龙族·水族怪兽被除外）
function c10132124.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c10132124.spfilter,1,nil,tp)
end
-- 定义目标函数，设置特殊召唤所需的操作信息
function c10132124.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用位置以及这张卡是否能被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明此效果要特殊召唤e1的处理卡（即翼龟本身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义执行函数，处理特殊召唤的具体操作
function c10132124.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以正面表示形式特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
