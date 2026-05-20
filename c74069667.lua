--DDD壊薙王アビス・ラグナロク
-- 效果：
-- ←5 【灵摆】 5→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己把「DD」怪兽特殊召唤的场合，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤，自己受到1000伤害。这个回合，对方受到的战斗伤害变成一半。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以自己墓地1只「DDD」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：1回合1次，把自己场上1只其他的「DD」怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
function c74069667.initial_effect(c)
	-- 注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己把「DD」怪兽特殊召唤的场合，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤，自己受到1000伤害。这个回合，对方受到的战斗伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,74069667)
	e2:SetCondition(c74069667.spcon1)
	e2:SetTarget(c74069667.sptg1)
	e2:SetOperation(c74069667.spop1)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤的场合，以自己墓地1只「DDD」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,74069668)
	e3:SetTarget(c74069667.sptg2)
	e3:SetOperation(c74069667.spop2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ②：1回合1次，把自己场上1只其他的「DD」怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c74069667.rmcost)
	e5:SetTarget(c74069667.rmtg)
	e5:SetOperation(c74069667.rmop)
	c:RegisterEffect(e5)
end
-- 过滤条件：自己场上表侧表示的「DD」怪兽
function c74069667.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsSummonPlayer(tp)
end
-- 检查是否特殊召唤了「DD」怪兽以满足灵摆效果①的发动条件
function c74069667.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c74069667.cfilter,1,nil,tp)
end
-- 过滤条件：自己墓地可以特殊召唤的「DD」怪兽
function c74069667.spfilter1(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 灵摆效果①的靶向：以自己墓地1只「DD」怪兽为对象
function c74069667.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74069667.spfilter1(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「DD」怪兽
		and Duel.IsExistingTarget(c74069667.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「DD」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c74069667.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置连锁信息：包含对自己造成1000伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
-- 灵摆效果①的效果处理：特殊召唤对象怪兽，自己受到1000伤害，且本回合对方受到的战斗伤害减半
function c74069667.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则将其以表侧表示特殊召唤（分步处理）
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 给予自己1000点效果伤害
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
	-- 这个回合，对方受到的战斗伤害变成一半。/①：这张卡召唤·特殊召唤的场合，以自己墓地1只「DDD」怪兽为对象才能发动。那只怪兽特殊召唤。/②：1回合1次，把自己场上1只其他的「DD」怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(HALF_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：本回合对方受到的战斗伤害变成一半
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：自己墓地可以特殊召唤的「DDD」怪兽
function c74069667.spfilter2(c,e,tp)
	return c:IsSetCard(0x10af) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果①的靶向：以自己墓地1只「DDD」怪兽为对象
function c74069667.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74069667.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「DDD」怪兽
		and Duel.IsExistingTarget(c74069667.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「DDD」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c74069667.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 怪兽效果①的效果处理：特殊召唤对象怪兽
function c74069667.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 怪兽效果②的发动代价：解放自己场上1只其他的「DD」怪兽
function c74069667.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外可解放的「DD」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0xaf) end
	-- 选择自己场上1只除这张卡以外的「DD」怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0xaf)
	-- 解放选定的怪兽
	Duel.Release(g,REASON_COST)
end
-- 怪兽效果②的靶向：以对方场上1只怪兽为对象
function c74069667.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在可以除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息：包含除外选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 怪兽效果②的效果处理：除外对象怪兽
function c74069667.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
