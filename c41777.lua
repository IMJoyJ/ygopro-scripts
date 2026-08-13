--ジェム・エンハンス
-- 效果：
-- 把自己场上存在的1只名字带有「宝石骑士」的怪兽解放，选择自己墓地存在的1只名字带有「宝石骑士」的怪兽发动。选择的怪兽从墓地特殊召唤。
function c41777.initial_effect(c)
	-- 把自己场上存在的1只名字带有「宝石骑士」的怪兽解放，选择自己墓地存在的1只名字带有「宝石骑士」的怪兽发动。选择的怪兽从墓地特殊召唤。
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
-- 效果发动代价函数：检查并执行解放自己场上1只名字带有「宝石骑士」的怪兽作为发动代价。
function c41777.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 代价检查阶段：确认自己场上是否存在至少1只可解放的名字带有「宝石骑士」的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x1047) end
	-- 弹出选择提示，提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从自己场上选择1只名字带有「宝石骑士」的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x1047)
	-- 将选择的怪兽解放，作为效果的发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 定义可供特殊召唤的墓地怪兽过滤条件：必须是名字带有「宝石骑士」的怪兽，且满足特殊召唤条件。
function c41777.filter(c,e,tp)
	return c:IsSetCard(0x1047) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查：选择自己墓地1只名字带有「宝石骑士」的怪兽为对象，并检查主怪兽区空位及操作信息。
function c41777.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c41777.filter(chkc,e,tp) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 若已进行过解放代价的预检查（label为1），则主怪兽区空位数量只需≥0，因为解放后会空出1个位置。
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
				-- 确认自己墓地存在至少1只满足过滤条件的名字带有「宝石骑士」的怪兽可以作为效果对象。
				and Duel.IsExistingTarget(c41777.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		else
			-- 若未进行过解放代价的预检查，则要求主怪兽区空位数量>0，以确保特殊召唤有足够空间。
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 确认自己墓地存在至少1只满足过滤条件的名字带有「宝石骑士」的怪兽可以作为效果对象。
				and Duel.IsExistingTarget(c41777.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		end
	end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只名字带有「宝石骑士」且满足特殊召唤条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c41777.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的特殊召唤操作信息，对象为所选怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	e:SetLabel(0)
end
-- 效果处理函数：在可行时将选择的墓地怪兽特殊召唤。
function c41777.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若主怪兽区没有空位，则无法特殊召唤，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得效果发动时选择的对象卡（墓地那只宝石骑士怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到持有者（tp）的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
