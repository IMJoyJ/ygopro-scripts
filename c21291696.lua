--電極獣カチオン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤的场合才能发动。从自己的卡组·墓地把1只「电极兽 阴离子」加入手卡。那之后，可以进行1只4星以下的雷族怪兽的召唤。这个效果的发动后，直到回合结束时自己不是光属性超量怪兽不能从额外卡组特殊召唤。
-- ②：以自己场上1只其他的雷族怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽的等级相同。
function c21291696.initial_effect(c)
	-- 效果原文：①：这张卡召唤的场合才能发动。从自己的卡组·墓地把1只「电极兽 阴离子」加入手卡。那之后，可以进行1只4星以下的雷族怪兽的召唤。这个效果的发动后，直到回合结束时自己不是光属性超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21291696,0))  --"检索「电极兽 阴离子」并进行召唤"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,21291696)
	e1:SetTarget(c21291696.thtg)
	e1:SetOperation(c21291696.thop)
	c:RegisterEffect(e1)
	-- 效果原文：②：以自己场上1只其他的雷族怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽的等级相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21291696,1))  --"改变等级"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,21291696+1)
	e2:SetTarget(c21291696.lvtg)
	e2:SetOperation(c21291696.lvop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的「电极兽 阴离子」卡片
function c21291696.thfilter(c)
	return c:IsCode(58680635) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡片类型为「电极兽 阴离子」
function c21291696.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「电极兽 阴离子」
	if chk==0 then return Duel.IsExistingMatchingCard(c21291696.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理时要检索的卡片数量为1张
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索满足条件的4星以下雷族怪兽
function c21291696.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_THUNDER) and c:IsLevelBelow(4)
end
-- 执行效果处理：检索「电极兽 阴离子」并进行召唤
function c21291696.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「电极兽 阴离子」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c21291696.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「电极兽 阴离子」加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 检查手牌或场上的怪兽中是否存在满足条件的雷族怪兽
		if Duel.IsExistingMatchingCard(c21291696.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			-- 询问玩家是否进行召唤
			and Duel.SelectYesNo(tp,aux.Stringid(21291696,2)) then  --"是否进行召唤？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 选择满足条件的雷族怪兽
			local sg=Duel.SelectMatchingCard(tp,c21291696.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 进行通常召唤
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
	-- 设置效果处理时的限制：自己不是光属性超量怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c21291696.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果：禁止自己从额外卡组特殊召唤光属性超量怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：禁止光属性超量怪兽从额外卡组特殊召唤
function c21291696.splimit(e,c)
	return not (c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsLocation(LOCATION_EXTRA)
end
-- 判断目标怪兽是否为雷族且等级不同
function c21291696.lvfilter(c,lv)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER) and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- 设置效果处理时要选择的目标：场上的雷族怪兽
function c21291696.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lv=e:GetHandler():GetLevel()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21291696.lvfilter(chkc,lv) end
	-- 检查场上是否存在满足条件的雷族怪兽
	if chk==0 then return Duel.IsExistingTarget(c21291696.lvfilter,tp,LOCATION_MZONE,0,1,nil,lv) end
	-- 提示玩家选择表侧表示的雷族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的雷族怪兽
	Duel.SelectTarget(tp,c21291696.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,lv)
end
-- 执行效果处理：改变等级
function c21291696.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 设置效果处理时的等级变化：等级变为目标怪兽的等级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
