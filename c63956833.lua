--銀河天翔
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是「光子」怪兽以及「银河」怪兽不能召唤·特殊召唤。
-- ①：支付2000基本分，以自己墓地1只「光子」怪兽为对象才能发动。把持有和那只怪兽相同等级的卡组1只「银河」怪兽和作为对象的墓地的怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的攻击力变成2000，效果无效化。
function c63956833.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是「光子」怪兽以及「银河」怪兽不能召唤·特殊召唤。①：支付2000基本分，以自己墓地1只「光子」怪兽为对象才能发动。把持有和那只怪兽相同等级的卡组1只「银河」怪兽和作为对象的墓地的怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的攻击力变成2000，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,63956833+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c63956833.cost)
	e1:SetTarget(c63956833.target)
	e1:SetOperation(c63956833.activate)
	c:RegisterEffect(e1)
	-- 添加召唤「光子」或「银河」以外怪兽的自定义活动计数器（用于检测本回合是否进行过非「光子」或「银河」怪兽的召唤）
	Duel.AddCustomActivityCounter(63956833,ACTIVITY_SUMMON,c63956833.counterfilter)
	-- 添加特殊召唤「光子」或「银河」以外怪兽的自定义活动计数器（用于检测本回合是否进行过非「光子」或「银河」怪兽的特殊召唤）
	Duel.AddCustomActivityCounter(63956833,ACTIVITY_SPSUMMON,c63956833.counterfilter)
end
-- 过滤函数，判断卡片是否属于「光子」或「银河」系列
function c63956833.counterfilter(c)
	return c:IsSetCard(0x55,0x7b)
end
-- 效果发动的代价（Cost）与发动条件检测函数
function c63956833.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000)
		-- 检查本回合玩家是否未召唤过「光子」和「银河」以外的怪兽
		and Duel.GetCustomActivityCount(63956833,tp,ACTIVITY_SUMMON)==0
		-- 检查本回合玩家是否未特殊召唤过「光子」和「银河」以外的怪兽
		and Duel.GetCustomActivityCount(63956833,tp,ACTIVITY_SPSUMMON)==0 end
	-- 扣除玩家2000基本分作为发动代价
	Duel.PayLPCost(tp,2000)
	-- 这张卡发动的回合，自己不是「光子」怪兽以及「银河」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c63956833.splimit)
	-- 注册不能特殊召唤「光子」和「银河」以外怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 注册不能召唤「光子」和「银河」以外怪兽的玩家效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制不能召唤·特殊召唤不属于「光子」或「银河」系列的怪兽
function c63956833.splimit(e,c)
	return not c:IsSetCard(0x55,0x7b)
end
-- 过滤自己墓地中可以守备表示特殊召唤的「光子」怪兽，且卡组中存在与之相同等级、可守备表示特殊召唤的「银河」怪兽
function c63956833.filter1(c,e,tp)
	return c:IsSetCard(0x55) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查卡组中是否存在与该墓地怪兽相同等级的、可特殊召唤的「银河」怪兽
		and Duel.IsExistingMatchingCard(c63956833.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel())
end
-- 过滤卡组中等级为指定等级、可以守备表示特殊召唤的「银河」怪兽
function c63956833.filter2(c,e,tp,lv)
	return c:IsSetCard(0x7b) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的目标选择与合法性检测函数
function c63956833.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c63956833.filter1(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己墓地是否存在满足条件的「光子」怪兽作为效果对象
		and Duel.IsExistingTarget(c63956833.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择要特殊召唤的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「光子」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c63956833.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将从卡组和墓地特殊召唤共2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理的核心执行函数
function c63956833.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	-- 获取作为效果对象的墓地中的「光子」怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 向玩家发送选择要特殊召唤的卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只与作为对象的墓地怪兽相同等级的「银河」怪兽
		local g=Duel.SelectMatchingCard(tp,c63956833.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetLevel())
		if g:GetCount()>0 then
			g:AddCard(tc)
			-- 遍历需要特殊召唤的怪兽组（包含卡组的「银河」怪兽和墓地的「光子」怪兽）
			for tc2 in aux.Next(g) do
				-- 将怪兽以表侧守备表示逐步特殊召唤到场上
				Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
				-- 效果无效化。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc2:RegisterEffect(e1)
				-- 效果无效化。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc2:RegisterEffect(e2)
				-- 这个效果特殊召唤的怪兽的攻击力变成2000
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_SET_ATTACK_FINAL)
				e3:SetValue(2000)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc2:RegisterEffect(e3)
			end
			-- 完成所有怪兽的特殊召唤处理
			Duel.SpecialSummonComplete()
		end
	end
end
