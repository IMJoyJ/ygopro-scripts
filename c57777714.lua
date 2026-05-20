--英霊獣使い－セフィラムピリカ
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「灵兽」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 自己对「英灵兽使-神数心皮莉佳」1回合只能有1次特殊召唤。
-- ①：这张卡召唤·灵摆召唤时，以「英灵兽使-神数心皮莉佳」以外的自己墓地1只「灵兽」怪兽或「神数」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c57777714.initial_effect(c)
	c:SetSPSummonOnce(57777714)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「灵兽」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c57777714.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·灵摆召唤时，以「英灵兽使-神数心皮莉佳」以外的自己墓地1只「灵兽」怪兽或「神数」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c57777714.target)
	e3:SetOperation(c57777714.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c57777714.condition)
	c:RegisterEffect(e4)
end
-- 限制自身只能灵摆召唤「灵兽」怪兽以及「神数」怪兽
function c57777714.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0xb5,0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 判定这张卡是否是通过灵摆召唤成功
function c57777714.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤自己墓地中「英灵兽使-神数心皮莉佳」以外的、可以特殊召唤的「灵兽」或「神数」怪兽
function c57777714.filter(c,e,tp)
	return c:IsSetCard(0xb5,0xc4) and not c:IsCode(57777714) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 召唤·灵摆召唤成功时效果的靶向处理（检查可行性并选择对象）
function c57777714.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c57777714.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c57777714.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c57777714.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤1只怪兽的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 召唤·灵摆召唤成功时效果的执行处理（特殊召唤目标怪兽，并注册结束阶段破坏的延迟效果）
function c57777714.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关联，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(57777714,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c57777714.descon)
		e1:SetOperation(c57777714.desop)
		-- 注册在结束阶段破坏该怪兽的全局时点效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段破坏效果的条件判定，检查目标怪兽是否仍带有对应的标记（若离场或状态重置则重置该效果）
function c57777714.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(57777714)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏效果的执行函数
function c57777714.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将目标怪兽破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
