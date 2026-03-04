--ドラグニティ－ブラックスピア
-- 效果：
-- ①：1回合1次，把自己场上1只龙族「龙骑兵团」怪兽解放，以自己墓地1只4星以下的鸟兽族怪兽为对象才能发动。那只鸟兽族怪兽特殊召唤。
function c13361027.initial_effect(c)
	-- 效果原文内容：①：1回合1次，把自己场上1只龙族「龙骑兵团」怪兽解放，以自己墓地1只4星以下的鸟兽族怪兽为对象才能发动。那只鸟兽族怪兽特殊召唤。
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
-- 检查场上是否满足解放条件的龙族「龙骑兵团」怪兽
function c13361027.cfilter(c,tp)
	return c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON)
		-- 确保该怪兽处于可解放状态（在自己场上或正面表示）
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 支付效果代价时的处理函数
function c13361027.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足解放条件的龙族「龙骑兵团」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c13361027.cfilter,1,nil,tp) end
	-- 选择满足条件的1只龙族「龙骑兵团」怪兽进行解放
	local rg=Duel.SelectReleaseGroup(tp,c13361027.cfilter,1,1,nil,tp)
	-- 将选中的怪兽从场上解放作为效果的代价
	Duel.Release(rg,REASON_COST)
end
-- 筛选可特殊召唤的墓地鸟兽族怪兽的过滤函数
function c13361027.filter(c,e,sp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 设置效果对象选择时的处理函数
function c13361027.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13361027.filter(chkc,e,tp) end
	-- 判断场上是否存在满足条件的墓地鸟兽族怪兽
	if chk==0 then return Duel.IsExistingTarget(c13361027.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的鸟兽族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的1只墓地鸟兽族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c13361027.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果发动时的处理函数
function c13361027.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_WINDBEAST) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
