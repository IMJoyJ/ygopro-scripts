--シビレルダケ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：原本种族是雷族的怪兽从自己的手卡·场上送去墓地的场合才能发动（伤害步骤也能发动）。这张卡从手卡特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，雷族怪兽的效果在手卡发动的场合才能发动。在自己场上把1只「电麻衍生物」（雷族·暗·1星·攻/守0）特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数：为此卡注册两个诱发效果，①为从手牌特殊召唤自身（触发条件：原本雷族怪兽从自己的手卡·场上送去墓地），②为特殊召唤「电麻衍生物」（触发条件：此卡在怪兽区存在且雷族怪兽效果在手牌发动）；两个效果1回合各能使用1次。
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
-- 过滤函数：判断送往墓地的卡片是否之前由本玩家控制、之前位于手牌或主要怪兽区、原本种族是雷族且原本类型是怪兽。
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_HAND) and c:GetOriginalRace()&RACE_THUNDER==RACE_THUNDER and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
end
-- ①效果的发动条件：存在至少1张原本种族为雷族的怪兽从自己的手卡·场上送去墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ①效果发动时的合法性检测：确认自己场上有可用的主要怪兽区空格，且这张卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本连锁处理的特殊召唤对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与当前效果关联，则将其从手牌表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧表示将这张卡特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：此卡在怪兽区域存在，且连锁中发动的效果是雷族怪兽在手牌发动的效果。
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中发动效果的种族和发动位置，以判断是否为雷族手牌效果。
	local race,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE,CHAININFO_TRIGGERING_LOCATION)
	return re:IsActiveType(TYPE_MONSTER) and bit.band(race,RACE_THUNDER)~=0 and bit.band(LOCATION_HAND,loc)~=0
end
-- ②效果发动时的合法性检测：确认自己场上有可用的主要怪兽区空格，且能够特殊召唤「电麻衍生物」。
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否能够特殊召唤「电麻衍生物」（雷族·暗·1星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_THUNDER,ATTRIBUTE_DARK) end
	-- 设置操作信息：本次连锁将生成1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次连锁将特殊召唤1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果处理：若仍可特殊召唤衍生物（有主怪兽区空格且召唤条件允许），则生成并特殊召唤衍生物；否则不处理。
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在可用的主要怪兽区域空格（若没有则终止处理）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查是否仍能特殊召唤衍生物；若不能则终止处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_THUNDER,ATTRIBUTE_DARK) then return end
	-- 生成1只「电麻衍生物」衍生物（token）卡牌对象，供后续特殊召唤使用。
	local token=Duel.CreateToken(tp,id+o)
	-- 将生成的「电麻衍生物」以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
