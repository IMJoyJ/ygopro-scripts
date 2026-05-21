--剛鬼闘魂
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从手卡把1只4星以下而战士族·恐龙族·电子界族的地属性怪兽守备表示特殊召唤。
-- ②：把自己场上1只连接3以上的「刚鬼」怪兽解放才能发动。从卡组·额外卡组把1只「恐龙摔跤手」怪兽或「G石人」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从手卡把1只4星以下而战士族·恐龙族·电子界族的地属性怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只连接3以上的「刚鬼」怪兽解放才能发动。从卡组·额外卡组把1只「恐龙摔跤手」怪兽或「G石人」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从额外卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中满足4星以下、地属性、战士族/恐龙族/电子界族且可以守备表示特殊召唤的怪兽
function s.spfilter(c,e,sp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsRace(RACE_WARRIOR+RACE_DINOSAUR+RACE_CYBERSE)
		and c:IsCanBeSpecialSummoned(e,0,sp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手牌中满足特殊召唤条件的怪兽组
	local cg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 判断手牌中是否存在满足条件的怪兽，且自己场上有可用的怪兽区域
	if #cg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否选择进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=cg:Select(tp,1,1,nil)
		-- 将选中的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤场上可解放的、连接3以上的「刚鬼」怪兽，且卡组或额外卡组有可特殊召唤的「恐龙摔跤手」或「G石人」怪兽
function s.costfilter(c,e,tp)
	return c:IsSetCard(0xfc) and c:IsLinkAbove(3)
		-- 检查卡组或额外卡组是否存在至少1只满足特殊召唤条件的「恐龙摔跤手」或「G石人」怪兽（考虑该怪兽解放后释放的格子）
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤卡组或额外卡组中可特殊召唤的「恐龙摔跤手」或「G石人」怪兽，并判断是否有足够的怪兽区域
function s.spfilter2(c,e,tp,ec)
	return c:IsSetCard(0x11a,0x186) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若在卡组，检查解放该怪兽后主怪兽区是否有空位
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp,ec)>0
		-- 若在额外卡组，检查解放该怪兽后额外怪兽区或连接端是否有空位
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0)
end
-- ②效果的发动Cost处理函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：判断场上是否存在可解放的满足条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,e,tp) end
	-- 让玩家选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,e,tp)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- ②效果的发动Target处理函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置特殊召唤的操作信息，表示从卡组或额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或额外卡组选择1只满足条件的「恐龙摔跤手」或「G石人」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
