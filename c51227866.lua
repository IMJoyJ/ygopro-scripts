--閃刀機－シャークキャノン
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合，以对方墓地1只怪兽为对象才能发动。那只怪兽除外。自己墓地有魔法卡3张以上存在的场合，可以不除外而把那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽不能攻击。
function c51227866.initial_effect(c)
	-- ①：自己的主要怪兽区域没有怪兽存在的场合，以对方墓地1只怪兽为对象才能发动。那只怪兽除外。自己墓地有魔法卡3张以上存在的场合，可以不除外而把那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c51227866.condition)
	e1:SetTarget(c51227866.target)
	e1:SetOperation(c51227866.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于判断怪兽是否在主要怪兽区域
function c51227866.cfilter(c)
	return c:GetSequence()<5
end
-- 效果发动条件判定函数
function c51227866.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的主要怪兽区域是否没有怪兽存在
	return not Duel.IsExistingMatchingCard(c51227866.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：用于筛选对方墓地中可以被除外或可以被特殊召唤的怪兽
function c51227866.filter(c,e,tp,spchk)
	return c:IsType(TYPE_MONSTER) and (c:IsAbleToRemove() or (spchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果的目标选择与合法性检查函数
function c51227866.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否有可用的主要怪兽区域
	local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中魔法卡的数量是否在3张以上
		and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c51227866.filter(chkc,e,tp,spchk) end
	-- 检查对方墓地是否存在符合条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c51227866.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp,spchk) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c51227866.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,spchk)
end
-- 效果处理函数
function c51227866.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 检查是否受到“王家长眠之谷”的影响，若受影响则使涉及墓地的效果无效
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 检查自己墓地中魔法卡的数量是否在3张以上
		if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
			-- 检查自己场上是否有空位，且对象怪兽是否可以特殊召唤
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查对象怪兽是否无法除外，或者询问玩家是否选择特殊召唤
			and (not tc:IsAbleToRemove() or Duel.SelectYesNo(tp,aux.Stringid(51227866,0))) then  --"是否特殊召唤？"
			-- 将对象怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽不能攻击。/那只怪兽除外。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		else
			-- 将对象怪兽表侧表示除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
