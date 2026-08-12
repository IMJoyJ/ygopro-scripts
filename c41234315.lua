--フェイク・エクスプロージョン・ペンタ
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。怪兽不会被那次战斗破坏，伤害计算后从自己的手卡或者墓地把1只「召唤反应机·大式」特殊召唤。
function c41234315.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c41234315.condition)
	e1:SetOperation(c41234315.activate)
	c:RegisterEffect(e1)
end
-- 检查攻击方是否为对方玩家。
function c41234315.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(1-tp)
end
-- 设置效果，在攻击宣言时使攻击怪兽和防守怪兽不会被那次战斗破坏，并注册一个在伤害计算后触发的效果用于特殊召唤。
function c41234315.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取此次战斗的防守怪兽。
	local d=Duel.GetAttackTarget()
	if a then
		-- 使攻击怪兽不会被那次战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
	end
	if d then
		-- 使防守怪兽不会被那次战斗破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		d:RegisterEffect(e2)
	end
	-- 注册一个在伤害计算后触发的效果，用于从手卡或墓地特殊召唤「召唤反应机·大式」。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetDescription(aux.Stringid(41234315,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(c41234315.spop)
	e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将效果e3注册给玩家tp。
	Duel.RegisterEffect(e3,tp)
end
-- 过滤函数，用于筛选「召唤反应机·大式」且可以特殊召唤的卡。
function c41234315.spfilter(c,e,tp)
	return c:IsCode(89493368) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 当伤害计算后，选择并特殊召唤一只「召唤反应机·大式」。
function c41234315.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地选择一张「召唤反应机·大式」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41234315.spfilter),tp,0x12,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
	end
end
