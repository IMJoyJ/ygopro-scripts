--電極獣カチオン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤的场合才能发动。从自己的卡组·墓地把1只「电极兽 阴离子」加入手卡。那之后，可以进行1只4星以下的雷族怪兽的召唤。这个效果的发动后，直到回合结束时自己不是光属性超量怪兽不能从额外卡组特殊召唤。
-- ②：以自己场上1只其他的雷族怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽的等级相同。
function c21291696.initial_effect(c)
	-- ①：这张卡召唤的场合才能发动。从自己的卡组·墓地把1只「电极兽 阴离子」加入手卡。那之后，可以进行1只4星以下的雷族怪兽的召唤。这个效果的发动后，直到回合结束时自己不是光属性超量怪兽不能从额外卡组特殊召唤。
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
	-- ②：以自己场上1只其他的雷族怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽的等级相同。
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
-- 筛选「电极兽 阴离子」（卡号58680635）且可以被加入手卡的卡，作为检索候选。
function c21291696.thfilter(c)
	return c:IsCode(58680635) and c:IsAbleToHand()
end
-- ①效果的发动条件与操作信息设定：先检查卡组·墓地是否存在1只「电极兽 阴离子」；若可发动，则将本次处理登记为“从卡组·墓地加入手卡”1张卡。
function c21291696.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点确认卡组·墓地存在至少1只满足thfilter的「电极兽 阴离子」，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c21291696.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 将本次效果的处理信息设置为“从卡组·墓地取1张卡加入手卡”，供系统检测效果类型，并向对方展示可能移动的卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 筛选当前手牌·场上中可以进行通常召唤的、等级4以下的雷族怪兽，用于检索后追加召唤。
function c21291696.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_THUNDER) and c:IsLevelBelow(4)
end
-- ①效果的实际处理：从卡组·墓地选1张「电极兽 阴离子」加入手卡并展示、洗牌；之后可选择手牌·场上1只4星以下雷族怪兽进行通常召唤（无视召唤次数）；处理完后给自己附加“只能特殊召唤光属性超量怪兽”的自肃直到回合结束。
function c21291696.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示“请选择要加入手牌的卡”的提示，并让玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组·墓地的候选（不受王家长眠之谷影响的「电极兽 阴离子」）中选择1张加入手牌。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c21291696.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切手卡，以隐藏检索到的卡的位置。
		Duel.ShuffleHand(tp)
		-- 判断手牌·场上是否存在1只满足sumfilter的4星以下雷族怪兽，以决定是否提供追加召唤的选项。
		if Duel.IsExistingMatchingCard(c21291696.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			-- 询问玩家是否进行追加的通常召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(21291696,2)) then  --"是否进行召唤？"
			-- 中断当前效果链，使后续的召唤处理在时点上与前面的检索处理分开，避免错过时点。
			Duel.BreakEffect()
			-- 显示“请选择要召唤的卡”的提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 从手牌·场上选择1只满足sumfilter的4星以下雷族怪兽作为追加召唤对象。
			local sg=Duel.SelectMatchingCard(tp,c21291696.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 以无视通常召唤次数限制的方式，用效果（无解放）进行1只怪兽的通常召唤。
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是光属性超量怪兽不能从额外卡组特殊召唤。②：以自己场上1只其他的雷族怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽的等级相同。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c21291696.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述自肃效果作为场地型效果注册到当前玩家（tp），持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的判定函数：从额外卡组特殊召唤的怪兽必须为光属性超量怪兽；即不能特殊召唤非光属性超量怪兽。
function c21291696.splimit(e,c)
	return not (c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果选择对象的过滤器：对象必须是表侧表示、雷族、等级与自身当前等级不同且等级不低于1的怪兽。
function c21291696.lvfilter(c,lv)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER) and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- ②效果的发动目标处理：以自己场上1只其他表侧表示的雷族怪兽为对象（等级不能与自身相同），选择后设为效果对象。
function c21291696.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lv=e:GetHandler():GetLevel()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21291696.lvfilter(chkc,lv) end
	-- 在发动时点确认自己场上存在至少1只符合条件的雷族表侧怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c21291696.lvfilter,tp,LOCATION_MZONE,0,1,nil,lv) end
	-- 显示“请选择表侧表示的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只符合条件的雷族怪兽作为效果对象（取对象）。
	Duel.SelectTarget(tp,c21291696.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,lv)
end
-- ②效果的实际处理：取得对象怪兽，若本卡与对象仍与效果关联且均为表侧表示，则给本卡施加等级变成对象怪兽等级的持续效果（到回合结束）。
function c21291696.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这张卡的等级直到回合结束时变成和那只怪兽的等级相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
