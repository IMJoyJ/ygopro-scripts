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
	-- 为这张卡添加灵摆怪兽属性，使其能够作为灵摆卡放置在灵摆区并参与灵摆召唤等规则处理。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己怪兽被选择作为攻击对象时，从自己墓地的怪兽以及除外的自己怪兽之中以1只「玄化」怪兽为对象才能发动。这张卡除外，作为对象的怪兽攻击表示特殊召唤。
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
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。②：这张卡被除外的下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
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
-- 发动条件判定函数：我方怪兽被选择为攻击对象时满足条件。
function c12196873.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前存在攻击对象且该攻击对象由我方控制。
	return Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(tp)
end
-- 目标过滤函数：可选择的对象须为墓地或除外区的表侧「玄化」怪兽，且能被效果特殊召唤为表侧攻击表示。
function c12196873.spfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x105) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- ①效果的发动时处理：确认自身可除外、除外后有空怪兽区，且存在符合条件的「玄化」怪兽可选择；随后选择1只目标并设置除外和特殊召唤的操作信息。
function c12196873.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c12196873.spfilter(chkc,e,tp) end
	if chk==0 then return c:IsAbleToRemove()
		-- 检查这张卡除外后己方场上是否仍有可用的怪兽区用来特殊召唤对象。
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查自己墓地或除外区是否存在至少1只满足过滤条件且可作为效果对象的「玄化」怪兽。
		and Duel.IsExistingTarget(c12196873.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示，用于选择特殊召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 由己方玩家从自己墓地/除外区选择1只符合条件的「玄化」怪兽，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c12196873.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：本连锁包含除外这张卡（1张），供需要检测除外行为的效果参考（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
	-- 设置操作信息：本连锁包含特殊召唤所选对象（1张），供需要检测特殊召唤行为的效果参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其表侧除外；若除外成功且对象仍关联，则将对象特殊召唤为表侧攻击表示。
function c12196873.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象卡（要特殊召唤的「玄化」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查这张卡是否仍与效果关联，并以表侧表示将其除外（成功除外才继续处理）。
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_REMOVED) and tc:IsRelateToEffect(e) then
		-- 将选择的对象怪兽以表侧攻击表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- ②效果的发动条件判定：当前为这张卡被除外的下个回合的准备阶段。
function c12196873.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合数等于这张卡被除外的回合数加1（即除外后的下一次准备阶段）。
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()+1
end
-- ②效果的发动时处理：确认己方怪兽区有空位且这张卡可以特殊召唤，然后设置特殊召唤自己的操作信息。
function c12196873.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查己方场上是否有可用的怪兽区域用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本连锁包含特殊召唤这张卡（1张），供需要检测特殊召唤行为的效果参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：若这张卡仍在除外区且与效果关联，则将其特殊召唤。
function c12196873.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到己方场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
