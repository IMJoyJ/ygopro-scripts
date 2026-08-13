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
-- 过滤出满足条件的卡：手卡中卡名含有「龙骑兵团」、种族为鸟兽族且可以特殊召唤的怪兽。
function c25988873.filter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsRace(RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 该效果发动条件的判定：己方主要怪兽区和魔陷区均有空位，且手卡存在符合条件的龙骑兵团鸟兽族怪兽。
function c25988873.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区和魔陷区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手卡中是否存在1只以上满足filter条件的怪兽（可特殊召唤的龙骑兵团鸟兽族）。
		and Duel.IsExistingMatchingCard(c25988873.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果涉及从手卡特殊召唤1只怪兽（处理时确定具体卡牌）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：本次效果涉及将效果发动者（这张卡）作为装备卡装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若主要怪兽区有空位，则从手卡选1只符合条件的龙骑兵团鸟兽族怪兽特殊召唤，然后检查这张卡仍能装备时将其装备给那只怪兽，并附加装备对象限制。
function c25988873.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方主要怪兽区没有空位，则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足filter条件的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c25988873.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp)
		-- 若这张卡已里侧、与效果失去联系、控制权改变或己方魔陷区没有空位，则不再进行装备。
		or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 中断当前效果链，使后续装备处理视为另开时点处理（避免错过时点）。
	Duel.BreakEffect()
	-- 将这张卡作为装备卡装备给特殊召唤的怪兽；若装备失败则终止后续处理。
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 把这张卡当作装备卡使用来装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c25988873.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制函数：仅允许装备给被特殊召唤的那只怪兽（LabelObject记录的对象）。
function c25988873.eqlimit(e,c)
	return e:GetLabelObject()==c
end
