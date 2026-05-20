--光と闇の洗礼
-- 效果：
-- ①：把自己场上1只「黑魔术师」解放才能发动。从自己的手卡·卡组·墓地选1只「混沌之黑魔术师」特殊召唤。
function c69542930.initial_effect(c)
	-- 在卡片中注册记载了「黑魔术师」卡名的信息
	aux.AddCodeList(c,46986414)
	-- ①：把自己场上1只「黑魔术师」解放才能发动。从自己的手卡·卡组·墓地选1只「混沌之黑魔术师」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c69542930.cost)
	e1:SetTarget(c69542930.target)
	e1:SetOperation(c69542930.activate)
	c:RegisterEffect(e1)
end
-- 发动代价处理：解放自己场上的1只「黑魔术师」
function c69542930.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放自己场上的「黑魔术师」
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,46986414) end
	-- 选择自己场上1只可解放的「黑魔术师」
	local g=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,nil,46986414)
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：手卡·卡组·墓地中可以特殊召唤的「混沌之黑魔术师」
function c69542930.filter(c,e,tp)
	return c:IsCode(40737112) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标检查与处理
function c69542930.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域空位数（由于解放了1只怪兽，空位数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡·卡组·墓地是否存在可以特殊召唤的「混沌之黑魔术师」
		and Duel.IsExistingMatchingCard(c69542930.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡·卡组·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 效果处理：从手卡·卡组·墓地特殊召唤1只「混沌之黑魔术师」
function c69542930.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择1只「混沌之黑魔术师」（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c69542930.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
