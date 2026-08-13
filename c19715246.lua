--サイバー・ヨルムンガンド
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，从卡组选1只「电子龙」特殊召唤或当作装备魔法卡使用给这张卡装备。这个回合，自己不是机械族怪兽不能特殊召唤。
-- ②：让自己场上1张「电子龙」回到手卡才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
local s,id,o=GetID()
-- 注册此卡的全部效果：特殊召唤限制（不能用通常召唤）、①效果（手卡特殊召唤并处理电子龙）、②效果（回电子龙检索融合），并设置同名卡①效果1回合1次、②效果1回合1次。
function s.initial_effect(c)
	-- 在规则上登记此卡效果中记载的卡名：「电子龙」（70095154）和「融合」（24094653）。
	aux.AddCodeList(c,70095154,24094653)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，从卡组选1只「电子龙」特殊召唤或当作装备魔法卡使用给这张卡装备。这个回合，自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：让自己场上1张「电子龙」回到手卡才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 特殊召唤条件判定：作为特殊召唤手续的效果必须具有“效果”类型，即不能通过通常召唤/规则召唤等无效果来源的方式出场。
function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- ①效果的发动条件：对方场上有怪兽存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测到对方场上至少有1只怪兽（以tp为视角的对方主要怪兽区）。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 检索「电子龙」的过滤器：卡名是「电子龙」，且要么能被特殊召唤（同时检查己方怪兽区空位和召唤次数），要么能作为装备卡装备（魔陷区有空位且场上无同名卡且不是禁止卡）。
function s.eqfilter(c,e,tp,chk)
	return c:IsCode(70095154)
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and
			-- 非发动时点（chk=false）：若选择特殊召唤电子龙，需要己方主要怪兽区有空格。
			(not chk and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 发动时点（chk=true）：若选择特殊召唤电子龙，需要己方本回合还能进行2次特殊召唤（本卡+电子龙），且主要怪兽区空位大于1。
			or chk and Duel.IsPlayerCanSpecialSummonCount(tp,2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1)
		-- 若选择装备：需要己方魔陷区有空位、电子龙在场上没有同名卡限制且不是禁止卡。
		or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp) and not c:IsForbidden())
end
-- ①效果发动时选择目标的判定：本卡自身可以特殊召唤，且卡组中存在可用的「电子龙」（以chk=true检查后续处理条件）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 本卡需要能够从手卡特殊召唤，且己方主要怪兽区有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 卡组中存在满足后续处理条件的「电子龙」；用chk=true保证在发动时就能确认处理可行。
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,e,tp,true) end
	-- 设置操作信息：本次效果将把本卡特殊召唤（1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果实际处理：先特殊召唤本卡；成功后在卡组选1只「电子龙」，由玩家选择特殊召唤或装备给本卡；最后给己方附加本回合只能特殊召唤机械族怪兽的自肃。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡仍与连锁相关，且成功特殊召唤到己方场上，才继续处理电子龙的部分。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 提示玩家从卡组中选择要操作的卡（用于后续的电子龙选择）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从卡组选择1只满足条件的「电子龙」作为处理对象。
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,false)
		local tc=g:GetFirst()
		if tc then
			-- 判断能否把选中的电子龙特殊召唤：需要己方主要怪兽区有空位且电子龙本身满足特殊召唤条件。
			local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断能否把选中的电子龙作为装备卡：需要己方魔陷区有空位、电子龙在场上不违反同名卡限制且不属于禁止卡。
			local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:CheckUniqueOnField(tp) and not tc:IsForbidden()
			local op=0
			if b1 and not b2 then op=1 end
			if b2 and not b1 then op=2 end
			if b1 and b2 then
				-- 当电子龙既能特殊召唤又能装备时，弹出选项让玩家选择其中一种处理方式。
				op=aux.SelectFromOptions(tp,
					{b1,1152,1},
					{b2,1068,2})
			end
			-- 中断当前连锁的效果处理，使之后（电子龙的特殊召唤或装备）被视为另一次处理，保证时点判定正确。
			Duel.BreakEffect()
			if op==1 then
				-- 将选中的电子龙以表侧表示特殊召唤到己方场上。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			elseif op==2 then
				-- 将选中的电子龙作为装备魔法卡，装备给本卡（效果所有者）。
				Duel.Equip(tp,tc,c)
				-- 当作装备魔法卡使用给这张卡装备。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				tc:RegisterEffect(e1)
			end
		end
	end
	-- 这个回合，自己不是机械族怪兽不能特殊召唤。②：让自己场上1张「电子龙」回到手卡才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把自肃效果注册到场上：本回合内，发动效果的一方不能特殊召唤非机械族怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定：若怪兽种族不是机械族，则禁止特殊召唤。
function s.splimit2(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- 装备限制判定：装备卡只能装备给效果拥有者（即本卡）。
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果的费用素材过滤器：表侧表示、卡名为「电子龙」且能作为代价返回手卡。
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(70095154) and c:IsAbleToHandAsCost()
end
-- ②效果发动代价：从己方场上选择1张表侧表示的「电子龙」返回手卡作为发动COST。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在可作为费用的「电子龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要返回手卡作为代价的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 实际选择1张「电子龙」作为代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 显示被选为代价的卡的动画，并在规则上记录该卡被选择。
	Duel.HintSelection(g)
	-- 将选中的「电子龙」送入手卡，完成COST支付（reason为COST）。
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- ②效果检索目标过滤器：卡名为「融合」（24094653）且可以加入手卡。
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- ②效果发动时判定：卡组·墓地存在「融合」，并设置操作信息为将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组·墓地是否存在符合条件的「融合」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：效果处理时将把1张来自卡组·墓地的卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：从卡组·墓地选择1张「融合」加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的「融合」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组·墓地选择「融合」，过滤时同时适用王家长眠之谷对墓地的限制（受王谷影响的墓地卡不能作为对象）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「融合」加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的「融合」。
		Duel.ConfirmCards(1-tp,g)
	end
end
