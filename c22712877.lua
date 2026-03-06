--シビレルダケ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：原本种族是雷族的怪兽从自己的手卡·场上送去墓地的场合才能发动（伤害步骤也能发动）。这张卡从手卡特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，雷族怪兽的效果在手卡发动的场合才能发动。在自己场上把1只「电麻衍生物」（雷族·暗·1星·攻/守0）特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：原本种族是雷族的怪兽从自己的手卡·场上送去墓地的场合才能发动（伤害步骤也能发动）。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，雷族怪兽的效果在手卡发动的场合才能发动。在自己场上把1只「电麻衍生物」（雷族·暗·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tkcon)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end
-- 用于判断送去墓地的怪兽是否满足条件：原本种族为雷族且为怪兽
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_HAND) and c:GetOriginalRace()&RACE_THUNDER==RACE_THUNDER and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
end
-- 判断是否有满足条件的怪兽送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 设置特殊召唤的处理目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足召唤衍生物的条件
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发动时的种族和位置信息
	local race,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE,CHAININFO_TRIGGERING_LOCATION)
	return re:IsActiveType(TYPE_MONSTER) and bit.band(race,RACE_THUNDER)~=0 and bit.band(LOCATION_HAND,loc)~=0
end
-- 设置召唤衍生物的处理目标
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足召唤衍生物的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_THUNDER,ATTRIBUTE_DARK) end
	-- 设置召唤衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行召唤衍生物的操作
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 判断玩家是否可以特殊召唤衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_THUNDER,ATTRIBUTE_DARK) then return end
	-- 创建衍生物卡片
	local token=Duel.CreateToken(tp,id+o)
	-- 将衍生物特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
