--電脳堺悟－老々
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。那之后，可以从自己墓地选和送去墓地的卡卡名不同的1只「电脑堺」怪兽效果无效守备表示特殊召唤。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
function c86483512.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。那之后，可以从自己墓地选和送去墓地的卡卡名不同的1只「电脑堺」怪兽效果无效守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86483512,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_GRAVE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,86483512)
	e1:SetTarget(c86483512.sptg)
	e1:SetOperation(c86483512.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「电脑堺」卡，且卡组中存在与其种类（怪兽·魔法·陷阱）不同的「电脑堺」卡
function c86483512.tfilter(c,tp)
	local type1=c:GetType()&0x7
	-- 检查该卡是否为表侧表示的「电脑堺」卡，且卡组中是否存在至少1张与其种类不同的可送去墓地的「电脑堺」卡
	return c:IsSetCard(0x14e) and c:IsFaceup() and Duel.IsExistingMatchingCard(c86483512.tgfilter,tp,LOCATION_DECK,0,1,nil,type1)
end
-- 过滤条件：卡组中与指定种类不同、且能送去墓地的「电脑堺」卡
function c86483512.tgfilter(c,type1)
	return not c:IsType(type1) and c:IsSetCard(0x14e) and c:IsAbleToGrave()
end
-- 过滤条件：墓地中与送去墓地的卡卡名不同、且能以守备表示特殊召唤的「电脑堺」怪兽
function c86483512.spfilter(c,e,tp,code1)
	return c:IsSetCard(0x14e) and not c:IsCode(code1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与合法性检查（包括检查怪兽区域空位、自身特殊召唤可能、以及场上是否存在合法的「电脑堺」卡作为对象）
function c86483512.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c86483512.tfilter(chkc,tp) end
	-- 在发动效果的准备阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在可以作为效果对象的「电脑堺」卡
		and Duel.IsExistingTarget(c86483512.tfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1张表侧表示的「电脑堺」卡作为效果对象
	local g=Duel.SelectTarget(tp,c86483512.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置效果处理信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理信息：特殊召唤手牌中的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（送墓、自身特召、以及后续可选的墓地特召和誓约效果注册）
function c86483512.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果源卡（手牌中的这张卡）以及发动的对象卡
	local c,tc=e:GetHandler(),Duel.GetFirstTarget()
	local type1=tc:GetType()&0x7
	if tc:IsRelateToEffect(e) then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1张与对象卡种类不同的「电脑堺」卡
		local g=Duel.SelectMatchingCard(tp,c86483512.tgfilter,tp,LOCATION_DECK,0,1,1,nil,type1)
		local tgc=g:GetFirst()
		-- 若成功将选择的卡送去墓地，且该卡确实到达墓地，同时手牌中的这张卡仍能适用效果
		if tgc and Duel.SendtoGrave(tgc,REASON_EFFECT)~=0 and tgc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e)
			-- 将手牌中的这张卡特殊召唤，并判断是否特殊召唤成功
			and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local code1=tgc:GetCode()
			-- 获取自己墓地中满足特召条件（不受王家之谷影响、与送墓卡卡名不同）的「电脑堺」怪兽
			local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c86483512.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,code1)
			-- 若墓地存在合法的「电脑堺」怪兽、且自己场上有空位，询问玩家是否进行追加特殊召唤
			if #sg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(86483512,1)) then  --"是否从墓地把怪兽特殊召唤？"
				-- 中断当前效果处理，使后续的特殊召唤处理在时点上不视为与前面同时进行
				Duel.BreakEffect()
				-- 提示玩家选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sc=sg:Select(tp,1,1,nil):GetFirst()
				-- 将选择的墓地怪兽以表侧守备表示特殊召唤（单步处理，用于后续注册效果）
				Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
				-- 效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				-- 效果无效
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
				-- 完成特殊召唤的最终处理
				Duel.SpecialSummonComplete()
			end
		end
	end
	-- 这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c86483512.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能特殊召唤等级或阶级小于3的怪兽的限制效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制条件：不能特殊召唤等级和阶级都小于3的怪兽（即只能特殊召唤等级或者阶级是3以上的怪兽）
function c86483512.splimit(e,c)
	return not (c:IsLevelAbove(3) or c:IsRankAbove(3))
end
