--ドラグニティ－ブラックスピア
-- 效果：
-- ①：1回合1次，把自己场上1只龙族「龙骑兵团」怪兽解放，以自己墓地1只4星以下的鸟兽族怪兽为对象才能发动。那只鸟兽族怪兽特殊召唤。
function c13361027.initial_effect(c)
	-- ①：1回合1次，把自己场上1只龙族「龙骑兵团」怪兽解放，以自己墓地1只4星以下的鸟兽族怪兽为对象才能发动。那只鸟兽族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13361027,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c13361027.cost)
	e1:SetTarget(c13361027.target)
	e1:SetOperation(c13361027.operation)
	c:RegisterEffect(e1)
end
-- 解放素材的筛选函数：判定怪兽是否为带有「龙骑兵团」字段的龙族怪兽，且解放该怪兽后己方场上仍有可用怪兽区域，同时该怪兽的控制者为己方或为表侧表示。
function c13361027.cfilter(c,tp)
	return c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON)
		-- 额外要求：解放该怪兽后自己的主要怪兽区仍有空格（供后续特殊召唤使用），且该怪兽是自己控制的或是表侧表示的怪兽。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 发动代价的处理函数：先检查能否解放，然后选择1只符合条件的龙族「龙骑兵团」怪兽，将其解放作为发动COST。
function c13361027.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段（chk==0），检查自己场上是否存在至少1只满足解放条件的龙族「龙骑兵团」怪兽，若不存在则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c13361027.cfilter,1,nil,tp) end
	-- 让玩家从满足条件的龙族「龙骑兵团」怪兽中选择1只作为解放代价。
	local rg=Duel.SelectReleaseGroup(tp,c13361027.cfilter,1,1,nil,tp)
	-- 将选择的那只怪兽以“代价（REASON_COST）”原因解放。
	Duel.Release(rg,REASON_COST)
end
-- 特殊召唤对象的筛选函数：怪兽必须是4星以下的鸟兽族，并且满足特殊召唤条件（能够被此效果特殊召唤）。
function c13361027.filter(c,e,sp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动时的目标选择与合法性判定：从自己墓地选择1只4星以下的鸟兽族怪兽作为对象；若选择阶段处理则提示玩家选择并设定特殊召唤的操作信息。
function c13361027.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13361027.filter(chkc,e,tp) end
	-- 在目标检测阶段（chk==0），检查自己墓地是否存在至少1只满足条件的鸟兽族怪兽可作为效果对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c13361027.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家发送“请选择要特殊召唤的卡”的提示信息（用于选择卡片时的显示文字）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的符合条件的鸟兽族怪兽中选择1只，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c13361027.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁的操作信息登记为“特殊召唤1只对象怪兽”，供后续效果处理及相关卡片（如星尘龙等）进行发动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数：取回效果对象，若该对象仍与此效果关联且仍为鸟兽族，则将其以表侧表示特殊召唤到己方场上。
function c13361027.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的第一个（也是唯一一个）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_WINDBEAST) then
		-- 将目标怪兽以表侧表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
