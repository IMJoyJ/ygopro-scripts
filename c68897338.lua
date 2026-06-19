--魔轟神獣ベヒルモス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。从手卡选包含这张卡的「魔轰神」怪兽2只以上丢弃，把持有和丢弃的怪兽的原本等级合计相同等级的1只「魔轰神」同调怪兽当作同调召唤从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，从自己手卡有卡被送去墓地的场合，把这张卡除外才能发动。从手卡把1只「魔轰神」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡起动效果，丢弃手卡魔轰神怪兽当作同调召唤特殊召唤额外魔轰神同调怪兽）和②效果（墓地诱发效果，手卡送墓时除外自身特殊召唤手卡魔轰神怪兽）。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。从手卡选包含这张卡的「魔轰神」怪兽2只以上丢弃，把持有和丢弃的怪兽的原本等级合计相同等级的1只「魔轰神」同调怪兽当作同调召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_SELF|CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.syntg)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，从自己手卡有卡被送去墓地的场合，把这张卡除外才能发动。从手卡把1只「魔轰神」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以因效果丢弃的「魔轰神」怪兽。
function s.dfilter(c,g,e,tp)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and c:IsDiscardable(REASON_EFFECT+REASON_DISCARD)
end
-- 检查选出的手卡怪兽组是否包含这张卡，且其原本等级合计是否对应额外卡组中某只可特殊召唤的「魔轰神」同调怪兽。
function s.fselect(g,e,tp)
	local lv=g:GetSum(Card.GetOriginalLevel)
	-- 检查选出的卡片组是否包含这张卡本身，且额外卡组中是否存在等级与该卡片组原本等级合计相同、且可以特殊召唤的「魔轰神」同调怪兽。
	return g:IsContains(e:GetHandler()) and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv)
end
-- 过滤额外卡组中等级与丢弃怪兽原本等级合计相同、且可以当作同调召唤特殊召唤的「魔轰神」同调怪兽。
function s.synfilter(c,e,tp,lv)
	return c:IsSetCard(0x35) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and c:IsType(TYPE_SYNCHRO)
		-- 检查额外怪兽区域或可用的主怪兽区域是否有空位用于特殊召唤该额外卡组怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ①效果的发动准备与合法性检测函数（Target）。
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡中所有满足条件的「魔轰神」怪兽。
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_HAND,0,nil)
	-- 检查是否存在必须作为同调素材的限制，并检查手卡中是否存在包含这张卡在内的2张以上可以丢弃的「魔轰神」怪兽，且其原本等级合计有对应的额外卡组同调怪兽。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) and g:CheckSubGroup(s.fselect,2,99,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的实际处理函数（Operation）。
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡中所有满足条件的「魔轰神」怪兽。
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_HAND,0,nil)
	-- 在效果处理时再次检查是否满足发动条件，若不满足则直接结束处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) or not g:CheckSubGroup(s.fselect,2,99,e,tp) then return end
	-- 提示玩家选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 强制设定后续的选择必须包含这张卡本身。
	Duel.SetSelectedCard(e:GetHandler())
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,99,e,tp)
	if sg and sg:GetCount()>=2 then
		local lv=sg:GetSum(Card.GetOriginalLevel)
		-- 将选中的手卡怪兽因效果丢弃送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		-- 从额外卡组选择1只等级与丢弃怪兽原本等级合计相同的「魔轰神」同调怪兽。
		local sc=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv):GetFirst()
		if not sc then return end
		sc:SetMaterial(nil)
		-- 将选中的「魔轰神」同调怪兽当作同调召唤特殊召唤到场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 过滤从自己手卡送去墓地的卡片。
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND) and c:IsPreviousControler(tp)
end
-- ②效果的发动条件检查：自己手卡有卡送去墓地，且不包含这张卡本身（因为这张卡必须已经在墓地存在）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤手卡中可以特殊召唤的「魔轰神」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x35) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备与合法性检测函数（Target）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查怪兽区域是否有空位，且手卡中是否存在可以特殊召唤的「魔轰神」怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
end
-- ②效果的实际处理函数（Operation）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只可以特殊召唤的「魔轰神」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「魔轰神」怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
