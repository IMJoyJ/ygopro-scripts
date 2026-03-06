--サシカエル
-- 效果：
-- 把自己场上存在的1只水族怪兽解放，选择自己墓地存在的1只名字带有「青蛙」的怪兽发动。选择的怪兽从墓地特殊召唤。这个效果1回合只能使用1次。
function c23408872.initial_effect(c)
	-- 效果原文内容：把自己场上存在的1只水族怪兽解放，选择自己墓地存在的1只名字带有「青蛙」的怪兽发动。选择的怪兽从墓地特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23408872,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c23408872.cost)
	e1:SetTarget(c23408872.target)
	e1:SetOperation(c23408872.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查场上是否满足解放条件的水族怪兽
function c23408872.cfilter(c,ft,tp)
	return c:IsRace(RACE_AQUA)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 规则层面作用：支付效果的解放代价
function c23408872.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 规则层面作用：判断是否满足解放条件
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c23408872.cfilter,1,nil,ft,tp) end
	-- 规则层面作用：选择满足条件的1只怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c23408872.cfilter,1,1,nil,ft,tp)
	-- 规则层面作用：执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 规则层面作用：过滤墓地中的青蛙族怪兽
function c23408872.filter(c,e,tp)
	return c:IsSetCard(0x12) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置效果的目标选择逻辑
function c23408872.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23408872.filter(chkc,e,tp) end
	-- 规则层面作用：判断场上是否存在满足条件的墓地目标
	if chk==0 then return Duel.IsExistingTarget(c23408872.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c23408872.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置效果处理时的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面作用：执行效果的处理逻辑，将目标怪兽特殊召唤
function c23408872.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
