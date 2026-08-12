--E・HERO Core
-- 效果：
-- 「元素英雄」怪兽×3
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：1回合1次，这张卡成为攻击对象时才能发动。这张卡的攻击力直到那次伤害步骤结束时变成2倍。
-- ②：这张卡进行战斗的战斗阶段结束时，以场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ③：这张卡被战斗·效果破坏时，以自己墓地1只8星以下的「元素英雄」融合怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。
function c95486586.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为3只「元素英雄」怪兽
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x3008),3,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过融合召唤的方式特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，这张卡成为攻击对象时才能发动。这张卡的攻击力直到那次伤害步骤结束时变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95486586,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCountLimit(1)
	e2:SetOperation(c95486586.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡进行战斗的战斗阶段结束时，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95486586,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c95486586.descon)
	e3:SetTarget(c95486586.destg)
	e3:SetOperation(c95486586.desop)
	c:RegisterEffect(e3)
	-- ③：这张卡被战斗·效果破坏时，以自己墓地1只8星以下的「元素英雄」融合怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(95486586,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetTarget(c95486586.sptg)
	e4:SetOperation(c95486586.spop)
	c:RegisterEffect(e4)
end
c95486586.material_setcode=0x8
-- ①号效果（攻击力翻倍）的效果处理函数
function c95486586.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到那次伤害步骤结束时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
-- 检查这张卡在当前回合是否进行过战斗，作为②号效果的发动条件
function c95486586.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- ②号效果（破坏怪兽）的靶向选择与发动准备函数
function c95486586.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在至少1只可以作为破坏对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表明该效果的操作分类为破坏，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②号效果（破坏怪兽）的效果处理函数
function c95486586.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的破坏对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤自己墓地中满足“8星以下”、“元素英雄”、“融合怪兽”且能特殊召唤的卡片
function c95486586.spfilter(c,e,tp)
	return c:IsLevelBelow(8) and c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ③号效果（特殊召唤墓地融合怪兽）的靶向选择与发动准备函数
function c95486586.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c95486586.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c95486586.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c95486586.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明该效果的操作分类为特殊召唤，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③号效果（特殊召唤墓地融合怪兽）的效果处理函数
function c95486586.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的特殊召唤对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽无视召唤条件以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
