--冥界流傀儡術
-- 效果：
-- 选择自己墓地的1只恶魔族怪兽。在自己场上选择合计等级和选择的那只怪兽的等级相同的怪兽从游戏中除外。之后，选择的那只怪兽特殊召唤。
function c40703393.initial_effect(c)
	-- 创建效果，设置效果分类为特殊召唤和除外，设置为取对象效果，类型为发动效果，时点为自由时点，设置效果处理函数和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c40703393.target)
	e1:SetOperation(c40703393.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的墓地恶魔族怪兽，确保其能被特殊召唤且场上怪兽等级和满足其等级要求
function c40703393.spfilter(c,e,tp,ft,rg)
	local lv=c:GetLevel()
	return lv>0 and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and rg:CheckWithSumEqual(Card.GetLevel,lv,ft,99)
end
-- 过滤场上正面表示且等级大于0的怪兽，确保其能被除外
function c40703393.rmfilter(c)
	return c:GetLevel()>0 and c:IsAbleToRemove() and c:IsFaceup()
end
-- 判断是否满足发动条件，若满足则选择目标怪兽并设置操作信息
function c40703393.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取玩家场上可用怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then ft=-ft+1 else ft=1 end
	if chk==0 then
		-- 获取玩家场上正面表示且等级大于0的怪兽组
		local rg=Duel.GetMatchingGroup(c40703393.rmfilter,tp,LOCATION_MZONE,0,nil)
		-- 判断场上是否存在满足条件的墓地恶魔族怪兽
		return Duel.IsExistingTarget(c40703393.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ft,rg)
	end
	-- 获取玩家场上正面表示且等级大于0的怪兽组
	local rg=Duel.GetMatchingGroup(c40703393.rmfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地恶魔族怪兽作为目标
	local g=Duel.SelectTarget(tp,c40703393.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft,rg)
	-- 设置操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，执行特殊召唤和除外操作
function c40703393.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取玩家场上可用怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then ft=-ft+1 else ft=1 end
	if not tc:IsRelateToEffect(e) or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 获取玩家场上正面表示且等级大于0的怪兽组
	local rg=Duel.GetMatchingGroup(c40703393.rmfilter,tp,LOCATION_MZONE,0,nil)
	local lv=tc:GetLevel()
	if rg:CheckWithSumEqual(Card.GetLevel,lv,ft,99) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rm=rg:SelectWithSumEqual(tp,Card.GetLevel,lv,ft,99)
		-- 将选择的怪兽除外
		Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
