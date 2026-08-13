--電脳堺豸－豸々
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。这个回合的结束阶段，可以从自己墓地选「电脑堺豸-豸豸」以外的1只「电脑堺」怪兽加入手卡。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
function c12571621.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。这个回合的结束阶段，可以从自己墓地选「电脑堺豸-豸豸」以外的1只「电脑堺」怪兽加入手卡。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12571621,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,12571621)
	e1:SetTarget(c12571621.sptg)
	e1:SetOperation(c12571621.spop)
	c:RegisterEffect(e1)
end
-- 定义对象过滤函数：检查自己场上表侧表示的「电脑堺」卡能否作为发动对象，同时卡组中存在至少1张与其种类（怪兽/魔法/陷阱）不同的「电脑堺」卡可送去墓地。
function c12571621.tfilter(c,tp)
	local type1=c:GetType()&0x7
	-- 判断该卡是表侧表示的「电脑堺」卡，且卡组中存在1张与它种类不同的「电脑堺」卡可送去墓地。
	return c:IsSetCard(0x14e) and c:IsFaceup() and Duel.IsExistingMatchingCard(c12571621.tgfilter,tp,LOCATION_DECK,0,1,nil,type1)
end
-- 定义卡组送墓候选的过滤函数：要求不是对象卡的种类（怪兽/魔法/陷阱）、是「电脑堺」卡且能被效果送去墓地。
function c12571621.tgfilter(c,type1)
	return not c:IsType(type1) and c:IsSetCard(0x14e) and c:IsAbleToGrave()
end
-- 定义发动时的目标处理函数：在连锁确认对象时验证对象合法性；在发动时检查主要怪兽区空格、此卡能否特殊召唤，以及场上是否存在可取对象的表侧「电脑堺」卡。
function c12571621.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c12571621.tfilter(chkc,tp) end
	-- 检查自己主要怪兽区是否有空位，用于让此卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在1张表侧表示的「电脑堺」卡可以作为取对象目标，并且卡组存在可送墓的对应卡。
		and Duel.IsExistingTarget(c12571621.tfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 显示“请选择表侧表示的卡”的提示信息，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上表侧表示的「电脑堺」卡中选择1张作为效果的对象（取对象）。
	local g=Duel.SelectTarget(tp,c12571621.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置操作信息：本次效果会从卡组把1张卡送去墓地，所属玩家为tp，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本次效果会特殊召唤这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果处理函数：若对象仍与效果关联，从卡组选择1张与对象种类不同的「电脑堺」卡送去墓地；送墓成功且此卡仍关联时，将此卡特殊召唤，并注册结束阶段回收效果；之后注册本回合的自肃效果。
function c12571621.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动者（手卡中的这张卡）以及取对象选择的目标卡。
	local c,tc=e:GetHandler(),Duel.GetFirstTarget()
	local type1=tc:GetType()&0x7
	if tc:IsRelateToEffect(e) then
		-- 显示“请选择要送去墓地的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1张与对象种类不同的「电脑堺」卡送去墓地（不取对象，效果处理时选择）。
		local g=Duel.SelectMatchingCard(tp,c12571621.tgfilter,tp,LOCATION_DECK,0,1,1,nil,type1)
		local tgc=g:GetFirst()
		-- 判定卡组送墓成功、送墓的卡仍在墓地，且此卡仍与效果关联。
		if tgc and Duel.SendtoGrave(tgc,REASON_EFFECT)~=0 and tgc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e)
			-- 并且此卡成功特殊召唤，作为后续注册结束阶段回收效果的前提条件。
			and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 这个回合的结束阶段，可以从自己墓地选「电脑堺豸-豸豸」以外的1只「电脑堺」怪兽加入手卡。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetCondition(c12571621.thcon)
			e1:SetOperation(c12571621.thop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将结束阶段回收效果注册给当前回合玩家，使该效果在结束阶段触发。
			Duel.RegisterEffect(e1,tp)
		end
	end
	-- 这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c12571621.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给当前回合玩家，该效果在结束阶段重置。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃判定函数：不允许特殊召唤等级和阶级都未满3的怪兽，即“非等级或阶级3以上的怪兽”不能特殊召唤。
function c12571621.splimit(e,c)
	return not (c:IsLevelAbove(3) or c:IsRankAbove(3))
end
-- 定义墓地回收候选的过滤函数：是「电脑堺」怪兽、卡名不是「电脑堺豸-豸豸」、且能加入手卡。
function c12571621.thfilter(c)
	return c:IsSetCard(0x14e) and c:IsType(TYPE_MONSTER) and not c:IsCode(12571621) and c:IsAbleToHand()
end
-- 定义结束阶段回收效果的发动条件：自己墓地存在满足回收条件的「电脑堺」怪兽（且不受王家长眠之谷影响）。
function c12571621.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1只满足回收条件的「电脑堺」怪兽（不受王家长眠之谷影响）。
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c12571621.thfilter),tp,LOCATION_GRAVE,0,1,nil)
end
-- 定义回收效果处理函数：在结束阶段询问玩家是否发动，选择后从墓地选1只符合条件的「电脑堺」怪兽加入手卡，并让对方确认。
function c12571621.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否发动从墓地加入手卡的回收效果，选择“是”才继续处理。
	if Duel.SelectYesNo(tp,aux.Stringid(12571621,1)) then  --"是否从墓地把怪兽加入手卡？"
		-- 显示此卡的卡图动画，作为不入连锁的处理提示。
		Duel.Hint(HINT_CARD,0,12571621)
		-- 显示“请选择要加入手牌的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己墓地选择1只满足回收条件的「电脑堺」怪兽（不受王家长眠之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c12571621.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手卡的怪兽。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
