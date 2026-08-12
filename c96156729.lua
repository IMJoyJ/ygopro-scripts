--WWの鈴音
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是风属性怪兽不能特殊召唤。
-- ①：以自己场上1只「风魔女」怪兽为对象才能发动。和那只怪兽卡名不同的1只「风魔女」怪兽从卡组守备表示特殊召唤。
function c96156729.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是风属性怪兽不能特殊召唤。①：以自己场上1只「风魔女」怪兽为对象才能发动。和那只怪兽卡名不同的1只「风魔女」怪兽从卡组守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,96156729+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c96156729.cost)
	e1:SetTarget(c96156729.target)
	e1:SetOperation(c96156729.activate)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于记录本回合特殊召唤过非风属性怪兽的次数
	Duel.AddCustomActivityCounter(96156729,ACTIVITY_SPSUMMON,c96156729.counterfilter)
end
-- 计数器过滤函数：判断卡片是否为风属性（用于检测是否特殊召唤了非风属性怪兽）
function c96156729.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
-- 效果发动代价（Cost）函数：检查本回合是否未特殊召唤过非风属性怪兽，并注册本回合不能特殊召唤非风属性怪兽的限制
function c96156729.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合玩家是否未特殊召唤过非风属性怪兽
	if chk==0 then return Duel.GetCustomActivityCount(96156729,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是风属性怪兽不能特殊召唤。①：以自己场上1只「风魔女」怪兽为对象才能发动。和那只怪兽卡名不同的1只「风魔女」怪兽从卡组守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c96156729.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中为玩家注册该限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制函数：限制不能特殊召唤非风属性怪兽
function c96156729.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 目标怪兽过滤函数：筛选自己场上表侧表示的「风魔女」怪兽，且卡组中存在与其卡名不同的「风魔女」怪兽
function c96156729.filter(c,e,tp)
	-- 判断卡片是否为表侧表示的「风魔女」怪兽，且卡组中存在至少1只与其卡名不同、可守备表示特殊召唤的「风魔女」怪兽
	return c:IsFaceup() and c:IsSetCard(0xf0) and Duel.IsExistingMatchingCard(c96156729.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 特殊召唤怪兽过滤函数：筛选卡组中与目标怪兽卡名不同、且可以守备表示特殊召唤的「风魔女」怪兽
function c96156729.spfilter(c,e,tp,code)
	return c:IsSetCard(0xf0) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动准备（Target）函数：进行发动条件检查、选择对象并设置特殊召唤的操作信息
function c96156729.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c96156729.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域，以及是否存在符合条件的可作为对象的「风魔女」怪兽
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(c96156729.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只符合条件的「风魔女」怪兽作为对象
	Duel.SelectTarget(tp,c96156729.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（Operation）函数：将与对象怪兽卡名不同的1只「风魔女」怪兽从卡组守备表示特殊召唤
function c96156729.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍在该效果的影响下且表侧表示存在，并确认自己场上仍有可用的怪兽区域
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetMZoneCount(tp)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只与对象怪兽卡名不同的「风魔女」怪兽
		local g=Duel.SelectMatchingCard(tp,c96156729.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
		local sc=g:GetFirst()
		if sc then
			-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
