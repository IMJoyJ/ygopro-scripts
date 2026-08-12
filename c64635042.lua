--デーモンの招来
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡只要在怪兽区域存在，卡名当作「恶魔召唤」使用。
-- ②：只要这张卡在怪兽区域存在，对方不能把自己场上的「恶魔召唤」作为效果的对象。
-- ③：同调召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「恶魔召唤」特殊召唤。
function c64635042.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤的手续：调整+调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- 设置这张卡在怪兽区域存在时，卡名当作「恶魔召唤」使用。
	aux.EnableChangeCode(c,70781052)
	-- ②：只要这张卡在怪兽区域存在，对方不能把自己场上的「恶魔召唤」作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤受该效果保护的对象为自己场上卡名当作「恶魔召唤」的怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,70781052))
	-- 限制不能成为对方卡片效果的对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ③：同调召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「恶魔召唤」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(c64635042.spcon)
	e3:SetTarget(c64635042.sptg)
	e3:SetOperation(c64635042.spop)
	c:RegisterEffect(e3)
end
-- 检查发动条件：此卡必须是同调召唤成功、在怪兽区被对方送去墓地。
function c64635042.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
		and rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤卡名为「恶魔召唤」且可以特殊召唤的怪兽。
function c64635042.spfilter(c,e,tp)
	return c:IsCode(70781052) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查：检查自己场上是否有空怪兽位，以及手卡、卡组、墓地是否存在可特殊召唤的「恶魔召唤」。
function c64635042.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、卡组、墓地是否存在至少1只满足条件的「恶魔召唤」。
		and Duel.IsExistingMatchingCard(c64635042.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为：从手卡、卡组、墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从手卡、卡组、墓地选择1只「恶魔召唤」特殊召唤。
function c64635042.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有空怪兽位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地（受王家之谷影响）选择1只「恶魔召唤」。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c64635042.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
