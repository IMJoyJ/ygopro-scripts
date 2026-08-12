--デーモンの降臨
-- 效果：
-- 「与奈落的契约」降临。
-- ①：这张卡只要在怪兽区域存在，卡名当作「恶魔召唤」使用。
-- ②：场上的这张卡不会被和仪式怪兽以外的怪兽的战斗破坏，不会被仪式怪兽以外的怪兽的效果破坏。
-- ③：仪式召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「恶魔召唤」特殊召唤。
function c95825679.initial_effect(c)
	-- 在卡片关联代码列表中添加「与奈落的契约」的卡片密码
	aux.AddCodeList(c,69035382)
	c:EnableReviveLimit()
	-- ①：这张卡只要在怪兽区域存在，卡名当作「恶魔召唤」使用。
	aux.EnableChangeCode(c,70781052)
	-- ②：场上的这张卡不会被和仪式怪兽以外的怪兽的战斗破坏
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
	-- ③：仪式召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「恶魔召唤」特殊召唤。
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
-- 效果②中不会被战斗破坏的条件：对方怪兽不是仪式怪兽
function c95825679.indval(e,c)
	return not c:IsType(TYPE_RITUAL)
end
-- 效果②中不会被效果破坏的条件：由仪式怪兽以外的怪兽发动的效果
function c95825679.indeval(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and not re:IsActiveType(TYPE_RITUAL)
end
-- 效果③的发动条件判定函数：原本由自己控制且处于仪式召唤状态的这张卡被对方送去墓地的场合
function c95825679.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
		and rp==1-tp and c:IsPreviousControler(tp)
end
-- 效果③特殊召唤对象的过滤条件（手卡、卡组、墓地中的「恶魔召唤」）
function c95825679.spfilter(c,e,tp)
	return c:IsCode(70781052) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备与目标选择（Target）函数
function c95825679.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动的可行性检测：检测自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己手卡、卡组或墓地是否存在至少1只满足特殊召唤条件的「恶魔召唤」
		and Duel.IsExistingMatchingCard(c95825679.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁信息：包含从手卡、卡组或墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果③的效果处理（Operation）函数
function c95825679.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无可用怪兽区，则效果不予处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡、卡组或墓地选择1只满足特殊召唤条件的「恶魔召唤」（受王家长眠之谷限制）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c95825679.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
