--コピーキャット
-- 效果：
-- 「复制猫」在1回合只能发动1张。
-- ①：自己场上有「卡通世界」以及卡通怪兽存在的场合，以对方墓地1张卡为对象才能发动。那张卡是怪兽的场合，那只怪兽在自己场上特殊召唤。那张卡是魔法·陷阱卡的场合，那张卡在自己场上盖放。
function c88032456.initial_effect(c)
	-- 记录这张卡的效果文本中记载了「卡通世界」的卡名。
	aux.AddCodeList(c,15259703)
	-- 「复制猫」在1回合只能发动1张。①：自己场上有「卡通世界」以及卡通怪兽存在的场合，以对方墓地1张卡为对象才能发动。那张卡是怪兽的场合，那只怪兽在自己场上特殊召唤。那张卡是魔法·陷阱卡的场合，那张卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,88032456+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c88032456.condition)
	e1:SetTarget(c88032456.target)
	e1:SetOperation(c88032456.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「卡通世界」。
function c88032456.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤条件：自己场上表侧表示的卡通怪兽。
function c88032456.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 发动条件：自己场上有「卡通世界」以及卡通怪兽存在。
function c88032456.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「卡通世界」。
	return Duel.IsExistingMatchingCard(c88032456.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查自己场上是否存在表侧表示的卡通怪兽。
		and Duel.IsExistingMatchingCard(c88032456.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：对方墓地中可以特殊召唤的怪兽，或者可以盖放的魔法·陷阱卡。
function c88032456.filter(c,e,tp)
	if c:IsType(TYPE_MONSTER) then
		-- 检查该怪兽是否可以特殊召唤，且自己场上有空余的怪兽区域。
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	else
		-- 获取自己场上可用的魔法与陷阱区域数量。
		local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
		return c:IsSSetable(true) and (c:IsType(TYPE_FIELD) or ct>0)
	end
end
-- 效果发动时的对象选择与操作信息注册。
function c88032456.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c88032456.filter(chkc,e,tp) end
	-- 检查对方墓地是否存在满足条件的卡作为对象。
	if chk==0 then return Duel.IsExistingTarget(c88032456.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方墓地1张满足条件的卡作为对象。
	local g=Duel.SelectTarget(tp,c88032456.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置效果处理信息为特殊召唤该卡。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SSET)
		-- 设置效果处理信息为该卡离开墓地（盖放）。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 效果处理的执行函数。
function c88032456.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	-- 如果目标是场地魔法卡，或者自己场上有空余的魔法与陷阱区域。
	elseif (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then
		-- 将目标魔法·陷阱卡在自己场上盖放。
		Duel.SSet(tp,tc)
	end
end
