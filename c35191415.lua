--マジシャン・オブ・ブラック・イリュージョン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己在对方回合把魔法·陷阱卡的效果发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡只要在怪兽区域存在，卡名当作「黑魔术师」使用。
-- ③：只在这张卡在场上表侧表示存在才有1次，自己把魔法·陷阱卡的效果发动的场合以自己墓地1只「黑魔术师」为对象才能发动。那只怪兽特殊召唤。
function c35191415.initial_effect(c)
	-- 使此卡在手牌区域时视为黑魔术师（卡号46986414）
	aux.EnableChangeCode(c,46986414)
	-- ①：自己在对方回合把魔法·陷阱卡的效果发动的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35191415,0))  --"这张卡从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,35191415)
	e2:SetCondition(c35191415.condition1)
	e2:SetTarget(c35191415.target1)
	e2:SetOperation(c35191415.operation1)
	c:RegisterEffect(e2)
	-- ③：只在这张卡在场上表侧表示存在才有1次，自己把魔法·陷阱卡的效果发动的场合以自己墓地1只「黑魔术师」为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(35191415,1))  --"自己墓地1只「黑魔术师」特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,35191416)
	e4:SetCondition(c35191415.condition2)
	e4:SetTarget(c35191415.target2)
	e4:SetOperation(c35191415.operation2)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件判断函数
function c35191415.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 对方回合自己发动魔法或陷阱卡时才能发动
	return Duel.GetTurnPlayer()~=tp and rp==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的发动时点处理函数
function c35191415.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果①的处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理函数
function c35191415.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的发动条件判断函数
function c35191415.condition2(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 用于筛选墓地中的黑魔术师卡片
function c35191415.filter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动时点处理函数
function c35191415.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35191415.filter(chkc,e,tp) end
	-- 判断场上是否有特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在黑魔术师卡片
		and Duel.IsExistingTarget(c35191415.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的黑魔术师卡片作为对象
	local g=Duel.SelectTarget(tp,c35191415.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果③的处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的发动处理函数
function c35191415.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果③选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
