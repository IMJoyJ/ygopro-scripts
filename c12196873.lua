--メタファイズ・デコイドラゴン
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己怪兽被选择作为攻击对象时，从自己墓地的怪兽以及除外的自己怪兽之中以1只「玄化」怪兽为对象才能发动。这张卡除外，作为对象的怪兽攻击表示特殊召唤。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己怪兽被选择作为攻击对象时，从自己墓地的怪兽以及除外的自己怪兽之中以1只「玄化」怪兽为对象才能发动。场上的这张卡除外，作为对象的怪兽攻击表示特殊召唤。
-- ②：这张卡被除外的下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
function c12196873.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：自己怪兽被选择作为攻击对象时，从自己墓地的怪兽以及除外的自己怪兽之中以1只「玄化」怪兽为对象才能发动。这张卡除外，作为对象的怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12196873,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,12196873)
	e1:SetCondition(c12196873.spcon1)
	e1:SetTarget(c12196873.sptg1)
	e1:SetOperation(c12196873.spop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,12196874)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12196873,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1,12196875)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCondition(c12196873.spcon2)
	e3:SetTarget(c12196873.sptg2)
	e3:SetOperation(c12196873.spop2)
	c:RegisterEffect(e3)
end
-- 判断是否满足效果发动条件：攻击对象为己方怪兽
function c12196873.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果发动条件：攻击对象为己方怪兽
	return Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(tp)
end
-- 定义用于筛选满足条件的「玄化」怪兽的过滤器函数
function c12196873.spfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x105) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 定义效果发动时的选择目标处理函数
function c12196873.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c12196873.spfilter(chkc,e,tp) end
	if chk==0 then return c:IsAbleToRemove()
		-- 检查己方场上是否有足够的怪兽区域用于特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查己方墓地或除外区是否存在符合条件的「玄化」怪兽
		and Duel.IsExistingTarget(c12196873.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择符合条件的「玄化」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c12196873.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：将该卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
	-- 设置操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果处理时的执行函数
function c12196873.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认该卡在连锁中仍然存在并成功除外
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_REMOVED) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以攻击表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- 判断是否满足效果发动条件：回合数满足要求
function c12196873.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果发动条件：回合数满足要求
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()+1
end
-- 定义效果发动时的选择目标处理函数
function c12196873.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查己方场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义效果处理时的执行函数
function c12196873.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡以正面表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
