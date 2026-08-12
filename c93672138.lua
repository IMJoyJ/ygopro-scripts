--Evil★Twin’s トラブル・サニー
-- 效果：
-- 包含「邪恶★双子」怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡解放才能发动。从自己墓地把「姬丝基勒」怪兽和「璃拉」怪兽各最多1只特殊召唤。
-- ②：把墓地的这张卡除外，从自己的手卡·卡组·场上（表侧表示）把1只「邪恶★双子」怪兽送去墓地才能发动。场上1张卡送去墓地。
function c93672138.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：需要2到4只怪兽作为素材，且必须满足lcheck过滤条件
	aux.AddLinkProcedure(c,nil,2,4,c93672138.lcheck)
	-- ①：自己·对方回合，把这张卡解放才能发动。从自己墓地把「姬丝基勒」怪兽和「璃拉」怪兽各最多1只特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93672138,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,93672138)
	e1:SetCost(c93672138.spcost)
	e1:SetTarget(c93672138.sptg)
	e1:SetOperation(c93672138.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，从自己的手卡·卡组·场上（表侧表示）把1只「邪恶★双子」怪兽送去墓地才能发动。场上1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93672138,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,93672139)
	e2:SetCost(c93672138.tgcost)
	e2:SetTarget(c93672138.tgtg)
	e2:SetOperation(c93672138.tgop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤条件：素材中必须包含至少1只「邪恶★双子」怪兽
function c93672138.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x2151)
end
-- 效果①的启动代价（Cost）检查与执行函数
function c93672138.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤墓地中可以特殊召唤的「姬丝基勒」或「璃拉」怪兽
function c93672138.spfilter(c,e,tp)
	return c:IsSetCard(0x153,0x152) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（Target）函数，检查怪兽区域空位及墓地是否存在可特召的怪兽
function c93672138.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查这张卡解放后，自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查自己墓地是否存在至少1只满足特召条件的「姬丝基勒」或「璃拉」怪兽
		and Duel.IsExistingMatchingCard(c93672138.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 检查选中的怪兽组合是否合法（若选2张，必须是一张「姬丝基勒」和一张「璃拉」）
function c93672138.gcheck(g)
	if #g==1 then return true end
	-- 检查选中的2张卡是否分别属于「姬丝基勒」和「璃拉」系列
	return aux.gfcheck(g,Card.IsSetCard,0x153,0x152)
end
-- 效果①的效果处理（Operation）函数，执行特殊召唤
function c93672138.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中不受「王家之谷」影响且满足特召条件的「姬丝基勒」和「璃拉」怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c93672138.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 and #g>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,c93672138.gcheck,false,1,math.min(2,ft))
		if sg then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤可以作为效果②代价送去墓地的「邪恶★双子」怪兽（手卡、卡组或场上表侧表示），且场上必须有其他卡可以送去墓地
function c93672138.costfilter(c,tp)
	return c:IsSetCard(0x2151) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsFaceup())
		and c:IsAbleToGraveAsCost()
		-- 检查场上是否存在除该代价卡以外的、可以送去墓地的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 效果②的启动代价（Cost）检查与执行函数
function c93672138.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己手卡、卡组、场上（表侧表示）是否存在可作为代价送去墓地的「邪恶★双子」怪兽
		and Duel.IsExistingMatchingCard(c93672138.costfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡（作为代价）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡、卡组、场上（表侧表示）选择1只「邪恶★双子」怪兽
	local g=Duel.SelectMatchingCard(tp,c93672138.costfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,1,1,nil,tp)
	-- 将墓地的这张卡除外作为发动的代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 将选中的「邪恶★双子」怪兽送去墓地作为发动的代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的发动准备（Target）函数，检查场上是否有可以送去墓地的卡
function c93672138.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有可以送去墓地的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果②的效果处理（Operation）函数，将场上1张卡送去墓地
function c93672138.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡（效果处理时）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择场上1张可以送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 选中卡片的视觉提示（使选中的卡在场上闪烁）
		Duel.HintSelection(g)
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
