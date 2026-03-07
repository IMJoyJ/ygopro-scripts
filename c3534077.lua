--熱血獣士ウルフバーク
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己墓地1只兽战士族·炎属性·4星怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c3534077.initial_effect(c)
	-- 创建效果1，用于发动①效果，该效果为起动效果，只能在主要怪兽区使用，一回合只能发动一次，且需要选择墓地的怪兽作为对象
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3534077,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,3534077)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c3534077.sptg)
	e1:SetOperation(c3534077.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断墓地中的怪兽是否满足兽战士族、炎属性、4星且可以守备表示特殊召唤的条件
function c3534077.filter(c,e,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动条件判断函数，用于确认是否可以发动该效果，包括是否有符合条件的墓地怪兽以及场上是否有空位
function c3534077.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3534077.filter(chkc,e,tp) end
	-- 检查是否有满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c3534077.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查场上是否有足够的空间进行特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c3534077.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，表示将要特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理函数，用于执行特殊召唤并使召唤出的怪兽效果无效
function c3534077.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然存在于场上，并尝试将其特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 使特殊召唤出的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤出的怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
