--ドラグニティ－パルチザン
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「龙骑兵团」的鸟兽族怪兽特殊召唤，把这张卡当作装备卡使用来装备。这张卡被卡的效果当作装备卡使用装备中的场合，装备怪兽当作调整使用。
function c25988873.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「龙骑兵团」的鸟兽族怪兽特殊召唤，把这张卡当作装备卡使用来装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25988873,0))  --"特殊召唤并装备"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c25988873.sptg)
	e1:SetOperation(c25988873.spop)
	c:RegisterEffect(e1)
	-- 这张卡被卡的效果当作装备卡使用装备中的场合，装备怪兽当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetValue(TYPE_TUNER)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选手卡中满足条件的「龙骑兵团」鸟兽族怪兽，可特殊召唤。
function c25988873.filter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsRace(RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在空位且手卡存在符合条件的怪兽。
function c25988873.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足发动条件：手卡存在符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c25988873.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：将要特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：将要装备1张卡。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 处理效果发动：检查是否有足够的怪兽区和魔陷区空位，选择并特殊召唤符合条件的怪兽。
function c25988873.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区空位，若无则不执行效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c25988873.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的怪兽特殊召唤到场上。
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp)
		-- 检查是否有足够的魔陷区空位，若无则不执行效果。
		or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 中断当前效果，使之后的效果处理视为不同时处理。
	Duel.BreakEffect()
	-- 将装备卡装备给特殊召唤的怪兽。
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 设置装备对象限制，确保只有被装备的怪兽可以作为装备对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c25988873.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 判断装备对象是否为指定的怪兽。
function c25988873.eqlimit(e,c)
	return e:GetLabelObject()==c
end
