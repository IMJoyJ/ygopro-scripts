--カブトロン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1张表侧表示的魔法·陷阱卡送去墓地，以自己墓地1只4星以下的昆虫族怪兽为对象才能发动。那只昆虫族怪兽守备表示特殊召唤。
function c30587695.initial_effect(c)
	-- 效果原文内容：这个卡名的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30587695,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,30587695)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c30587695.spcost)
	e1:SetTarget(c30587695.sptg)
	e1:SetOperation(c30587695.spop)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否存在满足条件的魔法·陷阱卡
function c30587695.cfilter(c,tp)
	-- 效果作用：卡牌必须表侧表示、是魔法或陷阱类型、有可用怪兽区、可以作为费用送去墓地
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
end
-- 效果原文内容：①：把自己场上1张表侧表示的魔法·陷阱卡送去墓地，以自己墓地1只4星以下的昆虫族怪兽为对象才能发动。
function c30587695.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即场上是否存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c30587695.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 效果作用：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果作用：选择场上满足条件的1张魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c30587695.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 效果作用：将选中的魔法·陷阱卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果作用：过滤墓地中的昆虫族4星以下怪兽
function c30587695.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果原文内容：那只昆虫族怪兽守备表示特殊召唤。
function c30587695.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30587695.filter(chkc,e,tp) end
	-- 效果作用：判断是否满足发动条件，即墓地是否存在满足条件的昆虫族怪兽
	if chk==0 then return Duel.IsExistingTarget(c30587695.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择墓地满足条件的1只昆虫族怪兽
	local g=Duel.SelectTarget(tp,c30587695.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置连锁操作信息，标记将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：处理特殊召唤效果
function c30587695.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_INSECT) then
		-- 效果作用：将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
