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
	-- 添加自定义活动计数器，用于监测特殊召唤非「燃烧拳击手」怪兽的操作
	Duel.AddCustomActivityCounter(68144350,ACTIVITY_SPSUMMON,c68144350.counterfilter)
end
-- 自定义活动计数器的过滤函数，判断特殊召唤的怪兽是否为表侧表示的「燃烧拳击手」怪兽
function c68144350.counterfilter(c)
	return c:IsSetCard(0x1084) and c:IsFaceup()
end
-- 效果的启动Cost，检查本回合是否特殊召唤过非「燃烧拳击手」怪兽，并注册本回合不能特殊召唤非「燃烧拳击手」怪兽的誓约限制
function c68144350.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时检查本回合特殊召唤非「燃烧拳击手」怪兽的次数是否为0
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
	-- 向玩家注册不能特殊召唤非「燃烧拳击手」怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制效果的过滤函数，判断被特殊召唤的怪兽是否非「燃烧拳击手」怪兽
function c68144350.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x1084)
end
-- 过滤自己墓地中可以特殊召唤的「燃烧拳击手」怪兽
function c68144350.filter(c,e,tp)
	return c:IsSetCard(0x1084) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的Target，检查自己场上的怪兽区域是否有空位及墓地是否有可特殊召唤的「燃烧拳击手」怪兽，并在符合条件时选择对象
function c68144350.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c68144350.filter(chkc,e,tp) end
	-- 在chk为0时检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 检查自己墓地中是否存在可以作为对象的「燃烧拳击手」怪兽
		Duel.IsExistingTarget(c68144350.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「燃烧拳击手」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c68144350.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，确定特殊召唤的对象和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果的Operation，获取对象怪兽并在其仍符合条件时将其特殊召唤
function c68144350.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
