--VS コンティニュー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付500基本分，以自己墓地1只「征服斗魂」怪兽为对象才能发动。那只怪兽加入手卡或守备表示特殊召唤。
function c27345070.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：支付500基本分，以自己墓地1只「征服斗魂」怪兽为对象才能发动。那只怪兽加入手卡或守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,27345070+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c27345070.cost)
	e1:SetTarget(c27345070.target)
	e1:SetOperation(c27345070.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动代价函数：确认阶段检查能否支付500基本分，实际发动时支付500基本分。
function c27345070.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：若处于合法性确认阶段（chk==0），返回玩家能否支付500LP。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 筛选条件：选择自己墓地的「征服斗魂」怪兽，要求为怪兽卡，且能够加入手牌，或己方怪兽区有空位并能以表侧守备表示特殊召唤。
function c27345070.filter(c,e,tp,ft)
	return c:IsSetCard(0x195) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
end
-- 目标选择函数：根据当前怪兽区空位判断是否可选，并选择1只符合条件的墓地「征服斗魂」怪兽作为对象；没有可选对象则不能发动。
function c27345070.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取己方主要怪兽区的空位数量，用于判断是否能够特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27345070.filter(chkc,e,tp,ft) end
	-- 目标检查阶段：确认墓地存在至少1只满足条件且能成为效果对象的「征服斗魂」怪兽，作为发动条件。
	if chk==0 then return Duel.IsExistingTarget(c27345070.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ft) end
	-- 显示选择对象提示消息，提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地选择1只符合条件的「征服斗魂」怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c27345070.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft)
end
-- 效果处理函数：取得对象后先处理王家长眠之谷等限制，再根据玩家选择或条件将对象以表侧守备表示特殊召唤或加入手牌。
function c27345070.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 如果对象受王家长眠之谷影响且当前连锁可被无效，则无效并终止效果处理。
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 若对象仍处于王家长眠之谷影响范围内（不能被墓地效果移动），则终止处理。
		if not aux.NecroValleyFilter()(tc) then return end
		-- 判断能否特殊召唤：己方主要怪兽区有空位，且对象可以被表侧守备表示特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
			-- 若对象不能加入手牌则必然选择特殊召唤；若能加入手牌，则弹出选项（加入手牌/守备特殊召唤），当玩家选择特殊召唤（选项1）时进入特殊召唤分支。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将对象怪兽以表侧守备表示特殊召唤到己方场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		else
			-- 将对象怪兽加入其持有者的手牌，处理原因为效果。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
