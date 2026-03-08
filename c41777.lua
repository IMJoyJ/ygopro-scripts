--ジェム・エンハンス
-- 效果：
-- 把自己场上存在的1只名字带有「宝石骑士」的怪兽解放，选择自己墓地存在的1只名字带有「宝石骑士」的怪兽发动。选择的怪兽从墓地特殊召唤。
function c41777.initial_effect(c)
	-- 效果原文内容：把自己场上存在的1只名字带有「宝石骑士」的怪兽解放，选择自己墓地存在的1只名字带有「宝石骑士」的怪兽发动。选择的怪兽从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK,TIMING_ATTACK)
	e1:SetCost(c41777.cost)
	e1:SetTarget(c41777.target)
	e1:SetOperation(c41777.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否可以解放场上1只名字带有「宝石骑士」的怪兽作为发动代价
function c41777.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 效果作用：检查场上是否存在至少1张满足条件的可解放的卡
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x1047) end
	-- 效果作用：向玩家提示选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 效果作用：选择场上1张满足条件的可解放的卡
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x1047)
	-- 效果作用：将选择的卡以REASON_COST原因解放
	Duel.Release(g,REASON_COST)
end
-- 效果作用：定义过滤函数，用于判断墓地中的卡是否为名字带有「宝石骑士」且可以特殊召唤
function c41777.filter(c,e,tp)
	return c:IsSetCard(0x1047) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置效果的目标选择逻辑，检查墓地是否存在满足条件的卡并选择
function c41777.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c41777.filter(chkc,e,tp) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 效果作用：检查玩家场上是否有足够的怪兽区域用于特殊召唤
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
				-- 效果作用：检查墓地是否存在至少1张满足条件的卡
				and Duel.IsExistingTarget(c41777.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		else
			-- 效果作用：检查玩家场上是否有足够的怪兽区域用于特殊召唤
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 效果作用：检查墓地是否存在至少1张满足条件的卡
				and Duel.IsExistingTarget(c41777.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		end
	end
	-- 效果作用：向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：从墓地中选择1张满足条件的卡作为目标
	local g=Duel.SelectTarget(tp,c41777.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置连锁操作信息，表明将要特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	e:SetLabel(0)
end
-- 效果作用：执行效果的处理逻辑，将目标卡从墓地特殊召唤到场上
function c41777.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 效果作用：将目标卡以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
