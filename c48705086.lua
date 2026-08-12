--玲瓏竜クンツァイド
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡在手卡存在的场合才能发动。从手卡·卡组把1只7星以上的通常怪兽送去墓地，这张卡特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只通常怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化函数：注册①手卡起动效果（送去墓地＋特殊召唤）和②墓地起动效果（取对象的特殊召唤，cost为把这张卡除外），两效果共用同一计数限制实现「这个卡名的①②的效果1回合只能有1次使用其中任意1个」
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。从手卡·卡组把1只7星以上的通常怪兽送去墓地，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只通常怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置②效果的cost：把墓地的这张卡除外（「把墓地的这张卡除外……才能发动」）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件函数：满足「7星以上的通常怪兽且可以被送去墓地」的卡
function s.tgfilter(c)
	return c:IsLevelAbove(7) and c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
-- ①效果的目标函数：发动条件确认——自己主要怪兽区有空位、这张卡可以从手卡特殊召唤，且手卡·卡组存在除这张卡外满足条件的7星以上通常怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认自己的主要怪兽区有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认自己的手卡·卡组存在除这张卡外1只7星以上且可以送去墓地的通常怪兽
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c) end
	-- 设置操作信息：将从卡组·手卡把1张卡送去墓地（「从手卡·卡组把1只7星以上的通常怪兽送去墓地」）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
	-- 设置操作信息：将这张卡特殊召唤（「这张卡特殊召唤」）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：让自己从手卡·卡组选1只满足条件的通常怪兽送去墓地，确认其成功送去墓地且这张卡仍与效果关联后，把这张卡从手卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让玩家从自己的手卡·卡组选择1只除这张卡外满足条件的7星以上通常怪兽
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,aux.ExceptThisCard(e)):GetFirst()
	-- 确认选出的卡以效果被送去墓地、确实位于墓地，且这张卡仍与该效果关联（未被离场等情况打断）
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
		-- 把这张卡从手卡以表侧表示特殊召唤到自己场上（「这张卡特殊召唤」）
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件函数：满足「通常怪兽且可以以表侧守备表示特殊召唤」的卡
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的目标函数：取对象有效性检查（对象须在自己墓地且满足特殊召唤条件），发动条件确认——主要怪兽区有空位且自己墓地存在可特殊召唤的通常怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 确认自己的主要怪兽区有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在1只除这张卡外、可以作为对象且能以表侧守备表示特殊召唤的通常怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向玩家发送选择提示：「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家以自己墓地1只满足条件的通常怪兽为对象（「以自己墓地1只通常怪兽为对象」）
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将作为对象的那只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：取得作为对象的怪兽，确认其仍与效果关联且不受王家长眠之谷的影响后，将其以表侧守备表示特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的对象卡
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与该效果关联且不受王家长眠之谷的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 把作为对象的那只怪兽以表侧守备表示特殊召唤到自己场上（「那只怪兽守备表示特殊召唤」）
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
