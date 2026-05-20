--オイリーゼミ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。自己场上的全部昆虫族怪兽的等级下降1星。
-- ②：这张卡的表示形式变更的场合才能发动。从自己的手卡·卡组·墓地选1只「油油蝉」特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册，包含召唤·特殊召唤成功时发动降低等级的效果，以及表示形式变更时发动特殊召唤的效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡的表示形式变更的场合才能发动。从自己的手卡·卡组·墓地选1只「油油蝉」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示、等级2以上且是昆虫族的怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(2) and c:IsRace(RACE_INSECT)
end
-- 效果①的发动准备（检查是否存在符合条件的怪兽）
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示且等级2以上的昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果①的效果处理（使自己场上全部昆虫族怪兽等级下降1星）
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有符合条件的昆虫族怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	-- 遍历这些昆虫族怪兽
	for tc in aux.Next(g) do
		-- 自己场上的全部昆虫族怪兽的等级下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：手卡·卡组·墓地的同名卡「油油蝉」且可以特殊召唤
function s.sfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（检查怪兽区域空位及是否存在可特殊召唤的卡，并设置操作信息）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、卡组、墓地是否存在可以特殊召唤的「油油蝉」
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从手卡·卡组·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的效果处理（从手卡·卡组·墓地选1只「油油蝉」特殊召唤）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空格，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡、卡组、墓地中选择1只「油油蝉」（受王家之谷影响）
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #sg>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
