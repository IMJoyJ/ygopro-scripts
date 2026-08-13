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
	-- 设置效果值为将装备怪兽给予对方玩家的战斗伤害变为一半（HALF_DAMAGE）。
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡中满足「龙骑兵团」字段、鸟兽族且能被当前效果特殊召唤的怪兽。
function c52977572.filter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsRace(RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的合法性判定：主怪兽区和魔陷区均有空位，且手牌存在符合条件的「龙骑兵团」鸟兽族怪兽时才可发动。
function c52977572.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查我方主怪兽区与魔陷区都有空位，否则无法发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 同时要求手牌中至少存在1只满足过滤条件的「龙骑兵团」鸟兽族怪兽。
		and Duel.IsExistingMatchingCard(c52977572.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将从手卡特殊召唤1只怪兽（具体怪兽待处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 登记操作信息：本次效果将把这张卡作为装备卡装备（装备对象为本卡）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：从手牌选择1只符合条件的「龙骑兵团」鸟兽族怪兽特殊召唤；随后检查本卡是否仍具备装备条件（表侧、与效果关联、控制权未变、魔陷区有空位），不满足则结束处理。
function c52977572.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若主怪兽区无空位，则不能特殊召唤，效果直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只满足过滤条件（龙骑兵团鸟兽族且可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c52977572.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选择的怪兽以表侧表示特殊召唤到我方场上。
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp)
		-- 若魔陷区无空位，则无法将这张卡装备，效果处理到此结束。
		or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 中断当前效果的处理，使后续装备动作作为独立处理，避免错过时点。
	Duel.BreakEffect()
	-- 把这张卡作为装备卡装备给特殊召唤的怪兽；装备失败则结束处理。
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 把这张卡当作装备卡使用来装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c52977572.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制判定：只有被本效果特殊召唤的那只怪兽才能作为这张卡的装备对象。
function c52977572.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- 条件函数：判断是否处于本效果赋予的直接攻击中，即当前攻击对象为空（直接攻击）、装备怪兽身上的直接攻击效果数量少于2、且对方场上有怪兽存在。
function c52977572.rdcon(e)
	local c=e:GetHandler():GetEquipTarget()
	local tp=e:GetHandlerPlayer()
	-- 当前攻击对象为空，表示装备怪兽正在直接攻击对方玩家。
	return Duel.GetAttackTarget()==nil
		-- 并且装备怪兽的直接攻击效果数量小于2，且对方场上有怪兽（说明是依靠本效果进行的直接攻击）。
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
