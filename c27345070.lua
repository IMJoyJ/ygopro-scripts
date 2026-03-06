--VS コンティニュー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：支付500基本分，以自己墓地1只「征服斗魂」怪兽为对象才能发动。那只怪兽加入手卡或守备表示特殊召唤。
function c27345070.initial_effect(c)
	-- 创建效果对象，设置效果类别为回手牌、特殊召唤、墓地动作及墓地特殊召唤，效果类型为发动，具有取对象效果，触发时点为自由连锁，设置发动次数限制为1次，设置费用为支付500基本分，设置目标函数为c27345070.target，设置发动效果为c27345070.activate
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
-- 支付500基本分的费用处理函数
function c27345070.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤函数，筛选满足条件的「征服斗魂」怪兽，可加入手卡或可特殊召唤
function c27345070.filter(c,e,tp,ft)
	return c:IsSetCard(0x195) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
end
-- 设置效果目标，选择自己墓地符合条件的怪兽作为对象
function c27345070.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27345070.filter(chkc,e,tp,ft) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c27345070.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ft) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的墓地怪兽作为效果对象
	Duel.SelectTarget(tp,c27345070.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft)
end
-- 发动效果的处理函数，根据选择的怪兽进行回手或特殊召唤
function c27345070.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查目标怪兽是否受王家长眠之谷影响，若受则无效处理
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 检查目标怪兽是否受王家长眠之谷保护，若受则无效处理
		if not aux.NecroValleyFilter()(tc) then return end
		-- 检查玩家场上是否有可用区域，且目标怪兽可特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
			-- 若目标怪兽不能回手或玩家选择特殊召唤，则进行特殊召唤
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将目标怪兽以守备表示特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		else
			-- 将目标怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
