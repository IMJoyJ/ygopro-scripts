--先史遺産ウィングス・スフィンクス
-- 效果：
-- 这张卡召唤成功时，可以从自己墓地选择1只名字带有「先史遗产」的5星怪兽特殊召唤。这个效果发动的回合，自己不能把名字带有「先史遗产」的怪兽以外的怪兽特殊召唤。
function c65591858.initial_effect(c)
	-- 这张卡召唤成功时，可以从自己墓地选择1只名字带有「先史遗产」的5星怪兽特殊召唤。这个效果发动的回合，自己不能把名字带有「先史遗产」的怪兽以外的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65591858,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c65591858.spcost)
	e1:SetTarget(c65591858.sptg)
	e1:SetOperation(c65591858.spop)
	c:RegisterEffect(e1)
	-- 设定特殊召唤活动计数器，用于检测本回合是否特殊召唤过「先史遗产」以外的怪兽
	Duel.AddCustomActivityCounter(65591858,ACTIVITY_SPSUMMON,c65591858.counterfilter)
end
-- 计数器过滤函数：名字带有「先史遗产」的怪兽
function c65591858.counterfilter(c)
	return c:IsSetCard(0x70)
end
-- 效果发动代价（Cost）函数：检查并添加不能特殊召唤「先史遗产」以外怪兽的誓约限制
function c65591858.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前，检查本回合是否特殊召唤过「先史遗产」以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(65591858,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不能把名字带有「先史遗产」的怪兽以外的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c65591858.splimit)
	-- 将不能特殊召唤「先史遗产」以外怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤：不能特殊召唤非「先史遗产」怪兽
function c65591858.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x70)
end
-- 特殊召唤目标过滤：墓地中等级5且名字带有「先史遗产」的可以特殊召唤的怪兽
function c65591858.filter(c,e,tp)
	return c:IsLevel(5) and c:IsSetCard(0x70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标（Target）函数：检查场地和墓地状态，并选择要特殊召唤的怪兽
function c65591858.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c65591858.filter(chkc,e,tp) end
	-- 在发动前，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在满足条件的「先史遗产」怪兽
		and Duel.IsExistingTarget(c65591858.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「先史遗产」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c65591858.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理（Operation）函数：将选中的怪兽特殊召唤
function c65591858.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
