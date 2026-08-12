--スパイダー・スパイダー
-- 效果：
-- 这张卡战斗破坏对方场上守备表示存在的怪兽的场合，可以选择自己墓地存在的1只4星以下的昆虫族怪兽特殊召唤。
function c80637190.initial_effect(c)
	-- 这张卡战斗破坏对方场上守备表示存在的怪兽的场合，可以选择自己墓地存在的1只4星以下的昆虫族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80637190,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c80637190.spcon)
	e2:SetTarget(c80637190.sptg)
	e2:SetOperation(c80637190.spop)
	c:RegisterEffect(e2)
end
-- 判定被战斗破坏的对方怪兽在战斗时是否为守备表示
function c80637190.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return bit.band(tc:GetBattlePosition(),POS_DEFENSE)~=0
end
-- 过滤自己墓地中等级4以下且可以特殊召唤的昆虫族怪兽
function c80637190.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与合法性检测，确认自身怪兽区域有空位且墓地有符合条件的怪兽
function c80637190.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c80637190.filter(chkc,e,tp) end
	-- 检查当前玩家的怪兽区域是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只符合条件的昆虫族怪兽作为效果对象
		and Duel.IsExistingTarget(c80637190.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的昆虫族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c80637190.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含特殊召唤1只目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理，将选择的目标怪兽特殊召唤到场上
function c80637190.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_INSECT) then
		-- 将目标怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
