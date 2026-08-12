--魔轟神獣ノズチ
-- 效果：
-- ①：这张卡在手卡存在的场合才能发动。从手卡选1只「魔轰神」怪兽丢弃，这张卡特殊召唤。
-- ②：这张卡的①的效果特殊召唤时才能发动。从手卡把1只2星以下的「魔轰神」怪兽特殊召唤。
function c55277252.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。从手卡选1只「魔轰神」怪兽丢弃，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55277252,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c55277252.tg)
	e1:SetOperation(c55277252.op)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤时才能发动。从手卡把1只2星以下的「魔轰神」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55277252,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(c55277252.con2)
	e2:SetTarget(c55277252.tg2)
	e2:SetOperation(c55277252.op2)
	c:RegisterEffect(e2)
end
-- 过滤条件：手牌中的「魔轰神」怪兽
function c55277252.filter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域空位、手牌中是否存在其他「魔轰神」怪兽、自身是否能特殊召唤）
function c55277252.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在除这张卡以外的「魔轰神」怪兽
		and Duel.IsExistingMatchingCard(c55277252.filter,tp,LOCATION_HAND,0,1,e:GetHandler())
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置连锁信息，表示该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：从手牌丢弃1只「魔轰神」怪兽，并将这张卡特殊召唤
function c55277252.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果处理时仍存在于原本位置的这张卡（若已离开手牌则返回nil）
	local ec=aux.ExceptThisCard(e)
	-- 获取手牌中除这张卡以外的所有「魔轰神」怪兽
	local g=Duel.GetMatchingGroup(c55277252.filter,tp,LOCATION_HAND,0,ec)
	if #g==0 and ec then
		g:AddCard(ec)
	end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将选中的怪兽因效果丢弃送去墓地，并确认其成功送入墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)>0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToEffect(e) then
		-- 将这张卡以自身效果在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：这张卡是通过自身效果特殊召唤成功时
function c55277252.con2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤条件：手牌中等级2以下且可以特殊召唤的「魔轰神」怪兽
function c55277252.filter2(c,e,tp)
	return c:IsLevelBelow(2) and c:IsSetCard(0x35) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检测（检查怪兽区域空位、手牌中是否存在满足条件的怪兽）
function c55277252.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足过滤条件的「魔轰神」怪兽
		and Duel.IsExistingMatchingCard(c55277252.filter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的处理：从手牌选择1只2星以下的「魔轰神」怪兽特殊召唤
function c55277252.op2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足过滤条件的「魔轰神」怪兽
	local g=Duel.SelectMatchingCard(tp,c55277252.filter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
