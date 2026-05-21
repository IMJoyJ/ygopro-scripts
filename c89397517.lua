--レジェンド・オブ・ハート
-- 效果：
-- 「传说之心」在1回合只能发动1张。
-- ①：支付2000基本分，把自己场上1只战士族怪兽解放才能发动。自己的手卡·墓地的「传说之龙」魔法卡最多3种类除外，从自己的手卡·卡组·墓地选除外的种类数量的「传说的骑士」怪兽特殊召唤（同名卡最多1张）。
function c89397517.initial_effect(c)
	-- 「传说之心」在1回合只能发动1张。①：支付2000基本分，把自己场上1只战士族怪兽解放才能发动。自己的手卡·墓地的「传说之龙」魔法卡最多3种类除外，从自己的手卡·卡组·墓地选除外的种类数量的「传说的骑士」怪兽特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,89397517+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c89397517.cost)
	e1:SetTarget(c89397517.target)
	e1:SetOperation(c89397517.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上的战士族怪兽
function c89397517.costfilter(c,tp)
	return c:IsRace(RACE_WARRIOR)
		-- 检查该怪兽解放后是否能让出可用的怪兽区域，且该怪兽必须由自己控制或是表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果发动代价的处理函数
function c89397517.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查是否能支付2000基本分，以及场上是否存在至少1只满足条件的战士族怪兽可供解放
	if chk==0 then return Duel.CheckLPCost(tp,2000) and Duel.CheckReleaseGroup(tp,c89397517.costfilter,1,nil,tp) end
	-- 支付2000基本分
	Duel.PayLPCost(tp,2000)
	-- 选择自己场上1只满足条件的战士族怪兽
	local sg=Duel.SelectReleaseGroup(tp,c89397517.costfilter,1,1,nil,tp)
	-- 将选中的怪兽解放
	Duel.Release(sg,REASON_COST)
end
-- 过滤条件：手卡·墓地中可以除外的「传说之龙」魔法卡
function c89397517.rmfilter(c)
	return c:IsSetCard(0xa1) and c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
-- 过滤条件：手卡·卡组·墓地中可以特殊召唤的「传说的骑士」怪兽
function c89397517.spfilter(c,e,tp)
	return c:IsSetCard(0xa0) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 效果发动时的目标检查与操作信息注册函数
function c89397517.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（若在cost阶段已解放怪兽，则通过Label标记跳过此检查）
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查手卡·墓地是否存在至少1张可除外的「传说之龙」魔法卡
		return res and Duel.IsExistingMatchingCard(c89397517.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
			-- 检查手卡·卡组·墓地是否存在至少1只可特殊召唤的「传说的骑士」怪兽
			and Duel.IsExistingMatchingCard(c89397517.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置除外操作的信息，涉及手卡·墓地的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	-- 设置特殊召唤操作的信息，涉及手卡·卡组·墓地的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果处理函数：除外「传说之龙」魔法卡，并特殊召唤对应数量的「传说的骑士」怪兽
function c89397517.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取手卡·墓地中不受「王家长眠之谷」影响且满足条件的「传说之龙」魔法卡组
	local rmg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c89397517.rmfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	local rmct=rmg:GetClassCount(Card.GetCode)
	-- 获取手卡·卡组·墓地中不受「王家长眠之谷」影响且满足条件的「传说的骑士」怪兽组
	local spg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c89397517.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,nil,e,tp)
	local spct=spg:GetClassCount(Card.GetCode)
	local ct=math.min(3,ft,spct,rmct)
	if ct==0 then return end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1到ct张卡名不同的「传说之龙」魔法卡
	local g=rmg:SelectSubGroup(tp,aux.dncheck,false,1,ct)
	-- 将选中的卡片表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	ct=g:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择ct张卡名不同的「传说的骑士」怪兽
	local sg=spg:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	-- 遍历选中的要特殊召唤的怪兽集合
	for tc in aux.Next(sg) do
		-- 逐步将怪兽以表侧表示特殊召唤（无视召唤条件）
		Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	-- 完成特殊召唤的流程处理
	Duel.SpecialSummonComplete()
end
