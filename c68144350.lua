--BK スイッチヒッター
-- 效果：
-- 这张卡的效果发动的回合，自己不是「燃烧拳击手」怪兽不能特殊召唤。
-- ①：这张卡召唤时，以自己墓地1只「燃烧拳击手」怪兽为对象才能发动。那只怪兽特殊召唤。
function c68144350.initial_effect(c)
	-- ①：这张卡召唤时，以自己墓地1只「燃烧拳击手」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68144350,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(c68144350.spcost)
	e1:SetTarget(c68144350.sptg)
	e1:SetOperation(c68144350.spop)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于检测本回合是否特殊召唤过非「燃烧拳击手」怪兽
	Duel.AddCustomActivityCounter(68144350,ACTIVITY_SPSUMMON,c68144350.counterfilter)
end
-- 过滤函数，用于判定特殊召唤的怪兽是否为「燃烧拳击手」怪兽
function c68144350.counterfilter(c)
	return c:IsSetCard(0x1084)
end
-- 效果发动的Cost函数，用于检查并限制本回合只能特殊召唤「燃烧拳击手」怪兽
function c68144350.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查本回合在此效果发动前是否特殊召唤过非「燃烧拳击手」怪兽
	if chk==0 then return Duel.GetCustomActivityCount(68144350,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡的效果发动的回合，自己不是「燃烧拳击手」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c68144350.splimit)
	e1:SetLabelObject(e)
	-- 为玩家注册该限制效果，使其在本回合内生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数，使玩家不能特殊召唤非「燃烧拳击手」怪兽
function c68144350.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x1084)
end
-- 过滤函数，用于筛选墓地中可以特殊召唤的「燃烧拳击手」怪兽
function c68144350.filter(c,e,tp)
	return c:IsSetCard(0x1084) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的Target函数，用于检查发动条件并选择特殊召唤的对象
function c68144350.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c68144350.filter(chkc,e,tp) end
	-- 在发动时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 在发动时，检查自己墓地是否存在可以特殊召唤的「燃烧拳击手」怪兽
		Duel.IsExistingTarget(c68144350.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「燃烧拳击手」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68144350.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示此效果包含将选中的1张卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的Operation函数，执行将对象怪兽特殊召唤的操作
function c68144350.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
