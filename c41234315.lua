--フェイク・エクスプロージョン・ペンタ
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。怪兽不会被那次战斗破坏，伤害计算后从自己的手卡或者墓地把1只「召唤反应机·大式」特殊召唤。
function c41234315.initial_effect(c)
	-- 对应效果原文：‘对方怪兽的攻击宣言时才能发动。怪兽不会被那次战斗破坏，伤害计算后从自己的手卡或者墓地把1只「召唤反应机·大式」特殊召唤。’
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c41234315.condition)
	e1:SetOperation(c41234315.activate)
	c:RegisterEffect(e1)
end
-- 检查攻击宣言的怪兽是否由对方控制，即确认发动条件“对方怪兽的攻击宣言时”成立。
function c41234315.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(1-tp)
end
-- 发动后的处理：给攻击怪兽和被攻击怪兽赋予不会被那次战斗破坏的效果，并注册一个在伤害计算后（EVENT_BATTLED）触发的特殊召唤效果。
function c41234315.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽（可能为nil，例如直接攻击时）。
	local d=Duel.GetAttackTarget()
	if a then
		-- 对应效果原文：‘怪兽不会被那次战斗破坏’
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
	end
	if d then
		-- 对应效果原文：‘怪兽不会被那次战斗破坏’
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		d:RegisterEffect(e2)
	end
	-- 对应效果原文：‘伤害计算后从自己的手卡或者墓地把1只「召唤反应机·大式」特殊召唤。’
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetDescription(aux.Stringid(41234315,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(c41234315.spop)
	e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将伤害计算后触发特殊召唤的效果e3注册到当前操作玩家tp，使其在战斗伤害计算后（EVENT_BATTLED）由该玩家发动。
	Duel.RegisterEffect(e3,tp)
end
-- 定义特殊召唤的筛选条件：卡片必须是「召唤反应机·大式」（卡号89493368），且可以被当前效果特殊召唤。
function c41234315.spfilter(c,e,tp)
	return c:IsCode(89493368) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行特殊召唤处理：先确认主怪兽区有空位，再提示玩家选择一张符合条件的「召唤反应机·大式」，最后将其特殊召唤。
function c41234315.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方场上是否有可用的主怪兽区空格，若没有则无法特殊召唤，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家显示选择提示，提示文字为“请选择要特殊召唤的卡”（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡或墓地（位置0x12）中，选择1张满足spfilter且不受王家长眠之谷影响的「召唤反应机·大式」；0x12表示手卡或墓地。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41234315.spfilter),tp,0x12,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「召唤反应机·大式」以表侧表示特殊召唤到当前玩家场上；参数true/true表示不检查苏生限制和召唤条件。
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
	end
end
