--スクラップ・ゴーレム
-- 效果：
-- 1回合1次，可以选择自己墓地存在的1只4星以下的名字带有「废铁」的怪兽在自己或者对方场上特殊召唤。
function c82012319.initial_effect(c)
	-- 1回合1次，可以选择自己墓地存在的1只4星以下的名字带有「废铁」的怪兽在自己或者对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82012319,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c82012319.sptg)
	e1:SetOperation(c82012319.spop)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中等级4以下、名字带有「废铁」且可以特殊召唤到自己或对方场上的怪兽
function c82012319.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x24) and (c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- 效果发动的目标选择与判定，支持取对象判定，并确认双方场上是否有可用的怪兽区域
function c82012319.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c82012319.filter(chkc,e,tp) end
	-- 在发动判定时，检查自己或对方场上是否有可用的怪兽区域
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0)
		-- 在发动判定时，检查自己墓地是否存在至少1只满足条件的怪兽
		and Duel.IsExistingTarget(c82012319.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c82012319.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理，获取目标怪兽，并根据双方场上的空位情况让玩家选择特殊召唤到哪一方场上
function c82012319.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 检查自己场上是否有空位且目标怪兽是否可以特殊召唤到自己场上
	local s1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 检查对方场上是否有空位且目标怪兽是否可以特殊召唤到对方场上
	local s2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	local op=0
	-- 提示玩家选择特殊召唤的目标场地
	Duel.Hint(HINT_SELECTMSG,tp,0)
	-- 如果自己和对方场上都可以特殊召唤，则让玩家选择在自己场上或对方场上特殊召唤
	if s1 and s2 then op=Duel.SelectOption(tp,aux.Stringid(82012319,1),aux.Stringid(82012319,2))  --"在自己场上特殊召唤/在对方场上特殊召唤"
	-- 如果只能特殊召唤到自己场上，则强制选择在自己场上特殊召唤
	elseif s1 then op=Duel.SelectOption(tp,aux.Stringid(82012319,1))  --"在自己场上特殊召唤"
	-- 如果只能特殊召唤到对方场上，则强制选择在对方场上特殊召唤
	elseif s2 then op=Duel.SelectOption(tp,aux.Stringid(82012319,2))+1  --"在对方场上特殊召唤"
	else return end
	-- 如果玩家选择在自己场上特殊召唤，则将目标怪兽以表侧表示特殊召唤到自己场上
	if op==0 then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	-- 如果玩家选择在对方场上特殊召唤，则将目标怪兽以表侧表示特殊召唤到对方场上
	else Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP) end
end
