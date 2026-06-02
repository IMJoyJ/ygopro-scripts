--デーモンの降臨
-- 效果：
-- 「与奈落的契约」降临。
-- ①：这张卡只要在怪兽区域存在，卡名当作「恶魔召唤」使用。
-- ②：场上的这张卡不会被和仪式怪兽以外的怪兽的战斗破坏，不会被仪式怪兽以外的怪兽的效果破坏。
-- ③：仪式召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「恶魔召唤」特殊召唤。
function c95825679.initial_effect(c)
	aux.AddCodeList(c,69035382)
	c:EnableReviveLimit()
	-- 注册卡名变更效果，使这张卡在怪兽区域存在时卡名当作「恶魔召唤」使用
	aux.EnableChangeCode(c,70781052)
	-- 场上的这张卡不会被和仪式怪兽以外的怪兽的战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c95825679.indval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(c95825679.indeval)
	c:RegisterEffect(e3)
	-- 仪式召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「恶魔召唤」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c95825679.spcon)
	e4:SetTarget(c95825679.sptg)
	e4:SetOperation(c95825679.spop)
	c:RegisterEffect(e4)
end
-- 战斗破坏抗性的判定函数，过滤非仪式怪兽
function c95825679.indval(e,c)
	return not c:IsType(TYPE_RITUAL)
end
-- 效果破坏抗性的判定函数，过滤非仪式怪兽的怪兽效果
function c95825679.indeval(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and not re:IsActiveType(TYPE_RITUAL)
end
-- 检查自身是否为仪式召唤且在怪兽区域被对方送去墓地，作为效果③的发动条件
function c95825679.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
		and rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤卡名为「恶魔召唤」且可以特殊召唤的怪兽
function c95825679.spfilter(c,e,tp)
	return c:IsCode(70781052) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备与合法性检测（Target函数）
function c95825679.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查自己的手卡、卡组、墓地是否存在至少1只可以特殊召唤的「恶魔召唤」
		and Duel.IsExistingMatchingCard(c95825679.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，用于后续连锁处理的检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果③的效果处理函数（Operation函数），执行特殊召唤
function c95825679.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地中选择1只「恶魔召唤」（适用「王家长眠之谷」的过滤效果）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c95825679.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
