--三賢者の書
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：只要这张卡在魔法与陷阱区域存在，有装备卡装备的「大贤者」怪兽在1回合各有1次不会被战斗破坏。
-- ②：自己主要阶段才能发动。从手卡把1只4星魔法师族怪兽特殊召唤。
-- ③：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。从手卡把「大贤者」怪兽任意数量特殊召唤（同名卡最多1张）。
function c61159609.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在魔法与陷阱区域存在，有装备卡装备的「大贤者」怪兽在1回合各有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c61159609.indtg)
	e1:SetValue(c61159609.indct)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从手卡把1只4星魔法师族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61159609,0))  --"从手卡把1只4星魔法师族怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,61159609)
	e2:SetTarget(c61159609.sptg)
	e2:SetOperation(c61159609.spop)
	c:RegisterEffect(e2)
	-- ③：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。从手卡把「大贤者」怪兽任意数量特殊召唤（同名卡最多1张）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61159609,1))  --"从手卡把「大贤者」怪兽任意数量特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,61159609)
	e3:SetCost(c61159609.spcost2)
	e3:SetTarget(c61159609.sptg2)
	e3:SetOperation(c61159609.spop2)
	c:RegisterEffect(e3)
end
-- 过滤出有装备卡装备的「大贤者」怪兽作为战斗不被破坏效果的对象
function c61159609.indtg(e,c)
	return c:IsSetCard(0x150) and c:GetEquipCount()>0
end
-- 设置因战斗破坏时，1回合各有1次不被破坏
function c61159609.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 过滤手卡中可以特殊召唤的4星魔法师族怪兽
function c61159609.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检测函数
function c61159609.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足条件的4星魔法师族怪兽
		and Duel.IsExistingMatchingCard(c61159609.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理函数（从手卡特殊召唤1只4星魔法师族怪兽）
function c61159609.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若无空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的4星魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,c61159609.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的发动代价（Cost）检测与执行函数
function c61159609.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为发动代价的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤手卡中可以特殊召唤的「大贤者」怪兽
function c61159609.spfilter2(c,e,tp)
	return c:IsSetCard(0x150) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备与合法性检测函数
function c61159609.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足条件的「大贤者」怪兽
		and Duel.IsExistingMatchingCard(c61159609.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从手卡特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果③的效果处理函数（从手卡特殊召唤任意数量的「大贤者」怪兽）
function c61159609.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取手卡中所有满足特殊召唤条件的「大贤者」怪兽
	local g=Duel.GetMatchingGroup(c61159609.spfilter2,tp,LOCATION_HAND,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1到ft张卡名互不相同的「大贤者」怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	if sg and #sg>0 then
		-- 将选中的「大贤者」怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
