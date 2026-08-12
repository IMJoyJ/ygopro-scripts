--千年の血族
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己因战斗·效果受到1000以上的伤害时才能发动。这张卡从手卡特殊召唤。
-- ②：以对方墓地1只攻击力是?以外的怪兽为对象才能发动。对方可以从卡组选1只攻击力是?以外的怪兽。没选的场合或者作为对象的怪兽攻击力更高的场合，作为对象的怪兽在自己场上特殊召唤。选的怪兽回到卡组。那以外的场合，对方把选的怪兽加入手卡。
function c5130393.initial_effect(c)
	-- ①：自己因战斗·效果受到1000以上的伤害时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5130393,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCountLimit(1,5130393)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c5130393.spcon)
	e1:SetTarget(c5130393.sptg)
	e1:SetOperation(c5130393.spop)
	c:RegisterEffect(e1)
	-- ②：以对方墓地1只攻击力是?以外的怪兽为对象才能发动。对方可以从卡组选1只攻击力是?以外的怪兽。没选的场合或者作为对象的怪兽攻击力更高的场合，作为对象的怪兽在自己场上特殊召唤。选的怪兽回到卡组。那以外的场合，对方把选的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5130393,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,5130394)
	e2:SetTarget(c5130393.tdtg)
	e2:SetOperation(c5130393.tdop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：伤害来源是自己，伤害值大于等于1000，且伤害原因包含战斗或效果。
function c5130393.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>=1000 and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 效果处理准备阶段：判断是否满足特殊召唤条件（场上是否有空位，自身是否能被特殊召唤）。
function c5130393.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位可用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：将此卡加入特殊召唤的处理列表中。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理执行阶段：若此卡在连锁中且满足条件，则将其特殊召唤到场上。
function c5130393.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，将此卡以正面表示形式特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断目标怪兽是否具有攻击力且能被特殊召唤。
function c5130393.filter(c,e,tp)
	return c:GetTextAttack()>=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检索过滤函数：判断卡是否为怪兽卡、有攻击力且能加入手牌。
function c5130393.thfilter(c)
	return c:GetTextAttack()>=0 and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理准备阶段：判断是否满足选择墓地怪兽并特殊召唤的条件（场上是否有空位，墓地是否存在符合条件的目标）。
function c5130393.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c5130393.filter(chkc,e,tp) end
	-- 判断场上是否有空位可用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断对方墓地中是否存在符合条件的怪兽。
		and Duel.IsExistingTarget(c5130393.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从对方墓地中选择一只符合条件的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c5130393.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置连锁操作信息：将选中的怪兽加入特殊召唤的处理列表中。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理执行阶段：根据选择结果决定后续处理方式（特殊召唤或送回手牌）。
function c5130393.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local vc=tc:GetTextAttack()
	local sel=1
	-- 获取对方卡组中符合条件的怪兽集合。
	local g=Duel.GetMatchingGroup(c5130393.thfilter,tp,0,LOCATION_DECK,nil)
	-- 提示对方玩家是否从卡组选1只怪兽。
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(5130393,2))  --"是否从卡组选1只怪兽？"
	if g:GetCount()>0 then
		-- 对方选择是否从卡组选1只怪兽（选项0为选，选项1为不选）。
		sel=Duel.SelectOption(1-tp,1213,1214)
	else
		-- 若无可用怪兽，则默认选择不选。
		sel=Duel.SelectOption(1-tp,1214)+1
	end
	if sel==0 then
		-- 提示对方玩家选择要确认的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从对方卡组中选择一张符合条件的怪兽作为选中的卡。
		local sg=Duel.SelectMatchingCard(1-tp,c5130393.thfilter,tp,0,LOCATION_DECK,1,1,nil)
		-- 向玩家展示所选的卡。
		Duel.ConfirmCards(tp,sg)
		if sg:GetFirst():GetTextAttack()<vc then
			-- 将对方卡组洗牌。
			Duel.ShuffleDeck(1-tp)
			-- 将目标怪兽特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选中的怪兽加入对方手牌。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认所选的卡。
			Duel.ConfirmCards(1-tp,sg)
		end
	else
		-- 将目标怪兽特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
