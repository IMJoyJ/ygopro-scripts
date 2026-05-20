--トイ・タンク
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：魔法与陷阱区域盖放的这张卡被送去墓地的场合才能发动。这张卡特殊召唤。
-- ③：把这张卡解放才能发动。从手卡把1只6星以下的怪兽特殊召唤。自己场上有「玩具箱子」存在的场合，也能作为代替从自己墓地把除「玩具坦克」外的1只6星以下的怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化并注册卡片效果
function s.initial_effect(c)
	-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- ②：魔法与陷阱区域盖放的这张卡被送去墓地的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69925461,0))  --"从手卡·墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：把这张卡解放才能发动。从手卡把1只6星以下的怪兽特殊召唤。自己场上有「玩具箱子」存在的场合，也能作为代替从自己墓地把除「玩具坦克」外的1只6星以下的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69925461,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg1)
	e3:SetOperation(s.spop1)
	c:RegisterEffect(e3)
end
s.set_as_spell=true
-- 效果②的发动条件：检查这张卡此前是否在魔陷区且为背面表示
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 效果②的靶向/发动检测：检查怪兽区域是否有空位，以及自身是否能特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的代价：将自身解放
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果③的怪兽过滤条件：手卡中6星以下的怪兽，或者（若满足代替条件）墓地中除「玩具坦克」外6星以下的怪兽
function s.spfilter(c,e,tp,check)
	return c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and (c:IsLocation(LOCATION_HAND) or (check and not c:IsCode(69925461)))
end
-- 过滤条件：自己场上表侧表示的「玩具箱子」
function s.checkfilter(c)
	return c:IsFaceup() and c:IsCode(24878656)
end
-- 效果③的靶向/发动检测：检查解放自身后是否有可用怪兽区域，以及是否存在可特殊召唤的怪兽
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否存在表侧表示的「玩具箱子」
		local check=Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查这张卡离开场上后，自己场上是否有可用的怪兽区域
		return Duel.GetMZoneCount(tp,e:GetHandler())>0
			-- 检查手卡或墓地中是否存在满足特殊召唤条件的怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,check)
	end
	-- 设置连锁处理中的操作信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果③的效果处理：从手卡或墓地选择1只怪兽特殊召唤
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 检查自己场上是否存在表侧表示的「玩具箱子」
	local check=Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_ONFIELD,0,1,nil)
	-- 从手卡或墓地选择1只满足条件的怪兽（受「王家长眠之谷」影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,check)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
