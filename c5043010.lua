--ファイアウォール・ドラゴン
-- 效果：
-- 怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：只在这张卡在场上表侧表示存在才有1次，自己·对方回合，以最多有这张卡所互相连接区的怪兽数量的自己·对方的场上·墓地的怪兽为对象才能发动。那些怪兽回到手卡。
-- ②：这张卡所连接区的怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。从手卡把1只电子界族怪兽特殊召唤。
function c5043010.initial_effect(c)
	-- 为防火龙添加连接召唤手续：连接素材为2只以上的怪兽（无种族/属性等限制），对应“怪兽2只以上”的召唤条件。
	aux.AddLinkProcedure(c,nil,2)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：只在这张卡在场上表侧表示存在才有1次，自己·对方回合，以最多有这张卡所互相连接区的怪兽数量的自己·对方的场上·墓地的怪兽为对象才能发动。那些怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5043010,0))  --"回到持有者手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,5043010)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c5043010.thtg)
	e1:SetOperation(c5043010.thop)
	c:RegisterEffect(e1)
	-- 这张卡所连接区的怪兽被战斗破坏的场合（②效果触发条件之一）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c5043010.regcon)
	e2:SetOperation(c5043010.regop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c5043010.regcon2)
	c:RegisterEffect(e3)
	-- ②：这张卡所连接区的怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。从手卡把1只电子界族怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5043010,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_CUSTOM+5043010)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,5043011)
	e4:SetTarget(c5043010.sptg)
	e4:SetOperation(c5043010.spop)
	c:RegisterEffect(e4)
end
-- 定义①效果的对象筛选条件：对象必须是怪兽，并且“可以加入手卡”（不受“不能加入手卡”效果限制）。
function c5043010.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动处理：取本卡的互相连接区怪兽数量作为可选取对象数量上限；选择卡片时必须位于场上或墓地且满足thfilter；在效果发动时从双方场上·墓地选择1～ct只怪兽作为对象；记录回手牌的操作信息，并给本卡标记“已发动过效果”。
function c5043010.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ct=c:GetMutualLinkedGroupCount()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c5043010.thfilter(chkc) end
	-- ①效果的发动合法性检查：本卡有互相连接区怪兽（ct>0），并且双方场上·墓地存在至少1只满足thfilter且能成为对象的怪兽。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c5043010.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 向玩家显示“请选择要返回手牌的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己的场上·墓地及对方的场上·墓地选择1～ct只满足thfilter的怪兽作为对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c5043010.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,ct,nil)
	-- 设置当前连锁的操作信息：本次效果包含回手牌（CATEGORY_TOHAND），可能影响的卡为g，数量为g:GetCount()，用于后续相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(5043010,2))  --"已发动过效果"
end
-- ①效果处理时：取得本连锁的对象卡，过滤出仍与效果相关的卡，并以效果原因将其送回持有者手卡。
function c5043010.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出发动时选择的对象卡组，并用Card.IsRelateToEffect过滤掉因离场等原因已与效果失去联系的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将过滤后的对象卡以REASON_EFFECT（效果原因）送回其持有者的手卡。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
-- 判断某张怪兽卡在离场前是否原本处于本卡的连接区：取它离场前的区域序号，若其之前由对方控制则序号加16以映射到对方区域位；要求其之前在主要怪兽区且该序号包含在本卡的连接区掩码zone中。
function c5043010.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
-- e2（战斗破坏检测）的触发条件：本次被战斗破坏并送去墓地的怪兽组中，存在至少1只原本位于本卡连接区的怪兽。
function c5043010.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5043010.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 用于e3（送去墓地检测）的额外过滤：排除战斗破坏送入墓地的情况（避免与e2重复），其余要求与cfilter相同，即非战斗原因从场上送去墓地且原本位于本卡连接区。
function c5043010.cfilter2(c,tp,zone)
	return not c:IsReason(REASON_BATTLE) and c5043010.cfilter(c,tp,zone)
end
-- e3（送去墓地检测）的触发条件：本次送去墓地的怪兽组中，存在至少1只因非战斗原因从场上送去墓地且原本位于本卡连接区的怪兽。
function c5043010.regcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5043010.cfilter2,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- e2/e3的处理操作：当满足触发条件时，以本卡为对象引发一个自定义事件EVENT_CUSTOM+5043010，用于触发②效果。
function c5043010.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 以本卡（e:GetHandler()）作为事件卡片，引发自定义时点EVENT_CUSTOM+5043010，使e4这个诱发效果能够响应发动。
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+5043010,e,0,tp,0,0)
end
-- ②效果的特殊召唤筛选条件：该卡是电子界族怪兽，且可被当前效果特殊召唤（sumtype为0，同时检查召唤条件与苏生限制）。
function c5043010.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动合法性检查：自己主要怪兽区有空位，且手卡中存在至少1只满足spfilter的电子界族怪兽。
function c5043010.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空格（>0），用来确保特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认手卡中存在至少1只可特殊召唤的电子界族怪兽；两个条件同时满足时②效果才能发动。
		and Duel.IsExistingMatchingCard(c5043010.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息：本次效果包含特殊召唤（CATEGORY_SPECIAL_SUMMON），预定从手卡特殊召唤1只怪兽到tp的场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理时：如果自己主要怪兽区没有空位则直接终止；否则让玩家从手卡选择1只满足spfilter的电子界族怪兽，以表侧表示特殊召唤到自己场上。
function c5043010.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己主要怪兽区是否还有空位，没有空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1张满足spfilter的电子界族怪兽。
	local g=Duel.SelectMatchingCard(tp,c5043010.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到tp自己场上（不视为连接召唤，且不忽略召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
