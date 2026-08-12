--キノの蟲惑魔
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有「虫惑魔」怪兽存在的场合，自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是昆虫族·植物族怪兽不能从额外卡组特殊召唤。
-- ②：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
-- ③：自己的魔法与陷阱区域盖放的卡在1回合各有1次不会被效果破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特召、不受落穴/洞通常陷阱影响、魔陷区盖卡一回合一次不被破坏三个效果
function s.initial_effect(c)
	-- ①：自己场上有「虫惑魔」怪兽存在的场合，自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	-- ③：自己的魔法与陷阱区域盖放的卡在1回合各有1次不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.indtg)
	e3:SetValue(s.indct)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「虫惑魔」怪兽
function s.cfilter(c)
	return c:IsSetCard(0x108a) and c:IsFaceup()
end
-- 效果①的发动条件：自己或对方的主要阶段，且自己场上有表侧表示的「虫惑魔」怪兽存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2
	if not (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) then return false end
	-- 检查自己场上是否存在表侧表示的「虫惑魔」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备：检查怪兽区域空位以及自身是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：特殊召唤自身，并适用直到回合结束时只能从额外卡组特殊召唤昆虫族·植物族怪兽的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从手卡往自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是昆虫族·植物族怪兽不能从额外卡组特殊召唤。不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。自己的魔法与陷阱区域盖放的卡在1回合各有1次不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能从额外卡组特殊召唤昆虫族·植物族以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能特殊召唤非昆虫族且非植物族的额外卡组怪兽
function s.splimit(e,c)
	return not c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsLocation(LOCATION_EXTRA)
end
-- 免疫效果过滤器：判断来源卡片是否为「洞」或「落穴」通常陷阱卡
function s.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 破坏保护目标：自己魔法与陷阱区域（不含场地区）的里侧表示盖卡
function s.indtg(e,c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- 破坏保护次数：因效果破坏时，提供1次免于破坏的次数
function s.indct(e,re,r,rp)
	if bit.band(r,REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
