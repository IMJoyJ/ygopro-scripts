--黒魔術のヴェール
-- 效果：
-- ①：支付1000基本分才能发动。从自己的手卡·墓地选1只魔法师族·暗属性怪兽特殊召唤。
function c82404868.initial_effect(c)
	-- ①：支付1000基本分才能发动。从自己的手卡·墓地选1只魔法师族·暗属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c82404868.cost)
	e1:SetTarget(c82404868.target)
	e1:SetOperation(c82404868.activate)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理函数：检查并支付1000基本分
function c82404868.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查玩家是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 过滤条件：手卡·墓地的魔法师族·暗属性且可以特殊召唤的怪兽
function c82404868.filter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的合法性检查（Target）函数
function c82404868.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时检查自己的手卡或墓地是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c82404868.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表明该效果包含从手卡·墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理（Operation）函数：执行特殊召唤
function c82404868.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或墓地选择1只满足条件的怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c82404868.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
