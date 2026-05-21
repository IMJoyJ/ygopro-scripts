--ネフティスの導き手
-- 效果：
-- ①：把自己场上1只怪兽和这张卡解放才能发动。从手卡·卡组把1只「奈芙提斯之凤凰神」特殊召唤。
function c98446407.initial_effect(c)
	-- ①：把自己场上1只怪兽和这张卡解放才能发动。从手卡·卡组把1只「奈芙提斯之凤凰神」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98446407,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c98446407.spcost)
	e1:SetTarget(c98446407.sptg)
	e1:SetOperation(c98446407.spop)
	c:RegisterEffect(e1)
end
-- 过滤自己场上主要怪兽区域（非额外怪兽区域）怪兽的过滤函数
function c98446407.mzfilter(c,tp)
	return c:IsControler(tp) and c:GetSequence()<5
end
-- 效果发动代价（解放自身和场上1只怪兽）的检测与处理
function c98446407.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取玩家场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:GetSequence()<5 then ft=ft+1 end
	-- 检查自身是否可解放，以及场上是否存在除自身以外至少1只可解放的怪兽
	if chk==0 then return ft>-1 and c:IsReleasable() and Duel.CheckReleaseGroup(tp,nil,1,c)
		-- 若解放自身后没有空余怪兽区域，则要求另一只被解放的怪兽必须是自己主要怪兽区域的怪兽
		and (ft>0 or Duel.CheckReleaseGroup(tp,c98446407.mzfilter,1,c,tp)) end
	local rg=nil
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	if ft>0 then
		-- 场上有空余怪兽区域时，自由选择除自身以外的1只可解放的怪兽
		rg=Duel.SelectReleaseGroup(tp,nil,1,1,c)
	else
		-- 场上没有空余怪兽区域时，必须选择自己主要怪兽区域的1只可解放的怪兽
		rg=Duel.SelectReleaseGroup(tp,c98446407.mzfilter,1,1,c,tp)
	end
	rg:AddCard(c)
	-- 将选中的怪兽（包含自身和另一只怪兽）作为代价解放
	Duel.Release(rg,REASON_COST)
end
-- 过滤手卡或卡组中可以特殊召唤的「奈芙提斯之凤凰神」的过滤函数
function c98446407.filter(c,e,tp)
	return c:IsCode(61441708) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查与操作信息设置
function c98446407.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组中是否存在至少1只可以特殊召唤的「奈芙提斯之凤凰神」
	if chk==0 then return Duel.IsExistingMatchingCard(c98446407.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理的执行函数（特殊召唤「奈芙提斯之凤凰神」）
function c98446407.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只「奈芙提斯之凤凰神」
	local g=Duel.SelectMatchingCard(tp,c98446407.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「奈芙提斯之凤凰神」以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
