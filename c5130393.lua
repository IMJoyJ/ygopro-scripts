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
-- ①效果的发动条件判定：伤害来源为自己，伤害值在1000以上，且伤害类型为战斗或效果伤害时条件成立。
function c5130393.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>=1000 and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- ①效果的发动时点检查：自己场上主要怪兽区有空位，且这张手卡可以进行特殊召唤。
function c5130393.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在空闲区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁将进行特殊召唤，对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其特殊召唤到自己场上。
function c5130393.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果取对象过滤器：选择对方墓地中攻击力不为'?'且可以被自己特殊召唤的怪兽。
function c5130393.filter(c,e,tp)
	return c:GetTextAttack()>=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 对方卡组中用于选择的过滤器：怪兽卡、攻击力不为'?'、且可以被加入手卡。
function c5130393.thfilter(c)
	return c:GetTextAttack()>=0 and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动目标函数：指定对象时必须位于对方墓地且满足取对象过滤器；发动时需自己主要怪兽区有空位，且对方墓地存在至少1只可取对象。
function c5130393.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c5130393.filter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否有空位，以准备特殊召唤对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在至少1只满足取对象过滤器的怪兽。
		and Duel.IsExistingTarget(c5130393.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向本方玩家显示提示信息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让对方墓地中选择1只满足条件的怪兽作为效果对象（并记录为连锁对象）。
	local g=Duel.SelectTarget(tp,c5130393.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将要特殊召唤的对象为所选怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取得对象怪兽，询问对方是否从卡组选1只怪兽，根据攻击力比较或选择情况，决定将对象怪兽特殊召唤还是将选的卡加入对方手卡。
function c5130393.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时连锁上的对象卡（即取对象选择的怪兽）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local vc=tc:GetTextAttack()
	local sel=1
	-- 取得对方卡组中所有满足条件的怪兽（攻击力不为'?'且可加入手卡），作为可选择的集合。
	local g=Duel.GetMatchingGroup(c5130393.thfilter,tp,0,LOCATION_DECK,nil)
	-- 向对方玩家弹出选择提示：是否从卡组选1只怪兽？
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(5130393,2))  --"是否从卡组选1只怪兽？"
	if g:GetCount()>0 then
		-- 若对方卡组有可选怪兽，让对方法选择“选”或“不选”，选项序号存入sel（0表示选，1表示不选）。
		sel=Duel.SelectOption(1-tp,1213,1214)
	else
		-- 若对方卡组没有可选怪兽，强制对方选择“不选”，sel设为1。
		sel=Duel.SelectOption(1-tp,1214)+1
	end
	if sel==0 then
		-- 向对方玩家发送提示，要求选择一张卡给对方确认。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 让对方从卡组中选出1只满足条件的怪兽（用于给对方确认）。
		local sg=Duel.SelectMatchingCard(1-tp,c5130393.thfilter,tp,0,LOCATION_DECK,1,1,nil)
		-- 将对方选出的卡展示给本方玩家确认。
		Duel.ConfirmCards(tp,sg)
		if sg:GetFirst():GetTextAttack()<vc then
			-- 因从卡组选卡并可能送回卡组，洗切对方的卡组。
			Duel.ShuffleDeck(1-tp)
			-- 对方选的怪兽攻击力低于对象怪兽时，将对象怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将对方选中的卡加入其持有者的手卡（即对方手卡）。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 将加入对方手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,sg)
		end
	else
		-- 对方未选择卡组怪兽时，将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
