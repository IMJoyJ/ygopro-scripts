--ドラグニティ－ピルム
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「龙骑兵团」的鸟兽族怪兽特殊召唤，把这张卡当作装备卡使用来装备。这张卡被卡的效果当作装备卡使用装备中的场合，装备怪兽可以直接攻击对方玩家。这个时候，装备怪兽给与对方基本分的战斗伤害变成一半数值。
function c52977572.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「龙骑兵团」的鸟兽族怪兽特殊召唤，把这张卡当作装备卡使用来装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52977572,0))  --"特殊召唤并装备"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c52977572.sptg)
	e1:SetOperation(c52977572.spop)
	c:RegisterEffect(e1)
	-- 这张卡被卡的效果当作装备卡使用装备中的场合，装备怪兽可以直接攻击对方玩家。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- 这个时候，装备怪兽给与对方基本分的战斗伤害变成一半数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(c52977572.rdcon)
	-- 设置效果值为将受到的战斗伤害减半。
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选手牌中名字带有「龙骑兵团」且种族为鸟兽族、可以特殊召唤的怪兽。
function c52977572.filter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsRace(RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在空位且手卡中有符合条件的怪兽。
function c52977572.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断手牌中是否存在符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c52977572.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：将要特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：将此卡装备给目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 处理效果发动时的操作：若场上主要怪兽区有空位，则选择并特殊召唤一只符合条件的怪兽。
function c52977572.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上主要怪兽区是否有空位，若无则不执行后续操作。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择一只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c52977572.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的怪兽特殊召唤到场上。
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp)
		-- 判断装备区是否有空位，若无则不执行后续操作。
		or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 中断当前效果处理流程。
	Duel.BreakEffect()
	-- 尝试将此卡装备给已特殊召唤的怪兽。
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 设置装备限制效果：只有被装备的怪兽才能装备此卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c52977572.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 判断是否为被装备的怪兽。
function c52977572.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- 判断装备怪兽是否可以发动直接攻击的效果。
function c52977572.rdcon(e)
	local c=e:GetHandler():GetEquipTarget()
	local tp=e:GetHandlerPlayer()
	-- 判断当前是否有攻击目标。
	return Duel.GetAttackTarget()==nil
		-- 判断装备怪兽获得的直接攻击效果数量未超过两次且己方场上有怪兽。
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
