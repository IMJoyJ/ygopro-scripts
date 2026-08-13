--マジシャン・オブ・ブラック・イリュージョン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己在对方回合把魔法·陷阱卡的效果发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡只要在怪兽区域存在，卡名当作「黑魔术师」使用。
-- ③：只在这张卡在场上表侧表示存在才有1次，自己把魔法·陷阱卡的效果发动的场合以自己墓地1只「黑魔术师」为对象才能发动。那只怪兽特殊召唤。
function c35191415.initial_effect(c)
	-- 为这张卡注册卡名变更效果：此卡在怪兽区域存在期间，卡名当作「黑魔术师」（46986414）使用。
	aux.EnableChangeCode(c,46986414)
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己在对方回合把魔法·陷阱卡的效果发动的场合才能发动。这张卡从手卡特殊召唤。
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
-- ①效果的发动条件判定函数：检查当前连锁是否符合“自己在对方回合把魔法·陷阱卡的效果发动”的时机。
function c35191415.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：当前为对方回合（Duel.GetTurnPlayer()~=tp），且连锁效果的控制者是自己（rp==tp），且发动的效果为魔法·陷阱卡效果（re:IsActiveType(TYPE_SPELL+TYPE_TRAP)）。
	return Duel.GetTurnPlayer()~=tp and rp==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果发动时的目标处理函数：由于是从手牌特殊召唤自己，无需选择对象，只检查能否特殊召唤并登记相关信息。
function c35191415.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：自己场上主要怪兽区是否有可用空格（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁将执行的“特殊召唤此卡”操作信息写入连锁处理（category为CATEGORY_SPECIAL_SUMMON，对象为此卡，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果实际处理函数：若此卡仍与发动时的效果保持关联，就将此卡从手牌特殊召唤。
function c35191415.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧表示（正面表示）将此卡从手牌特殊召唤到己方场上（sumtype=0表示普通特殊召唤，不检查召唤条件/苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的发动条件判定函数：检查自己是否发动了魔法·陷阱卡的效果（rp==tp且re:IsActiveType(TYPE_SPELL+TYPE_TRAP)）。
function c35191415.condition2(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义选择对象的过滤条件：卡名必须是「黑魔术师」（46986414），且可以被特殊召唤。
function c35191415.filter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果发动时的目标处理函数：检查场上是否有空位以及墓地中是否存在符合条件的「黑魔术师」，若满足则让玩家选择1只作为对象。
function c35191415.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35191415.filter(chkc,e,tp) end
	-- 合法性检查：自己场上主要怪兽区是否有可用空格（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件且能够特殊召唤的「黑魔术师」可作为效果对象。
		and Duel.IsExistingTarget(c35191415.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方玩家从自己墓地选择1只符合条件的「黑魔术师」，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c35191415.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁将执行的“特殊召唤对象怪兽”操作信息写入连锁处理（对象为g，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果实际处理函数：取得之前选择的对象卡，若对象仍与效果关联，则将其从墓地特殊召唤。
function c35191415.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果选中作为连锁对象的墓地「黑魔术师」。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象怪兽以表侧表示从墓地特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
