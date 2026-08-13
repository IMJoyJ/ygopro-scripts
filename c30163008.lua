--羅天神将
-- 效果：
-- 相同种族的怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方的准备阶段，以这张卡所连接区1只表侧表示怪兽为对象才能发动。种族和那只怪兽相同的1只4星以下的怪兽从手卡往作为这张卡所连接区的自己场上特殊召唤。
-- ②：自己·对方的战斗阶段开始时，以对方场上1张卡为对象才能发动。那张卡破坏。
function c30163008.initial_effect(c)
	c:EnableReviveLimit()
	-- 为罗天神将添加连接召唤手续：以2只以上相同种族的怪兽作为连接素材，素材种族一致性由lcheck函数检查。
	aux.AddLinkProcedure(c,nil,2,nil,c30163008.lcheck)
	-- ①：自己·对方的准备阶段，以这张卡所连接区1只表侧表示怪兽为对象才能发动。种族和那只怪兽相同的1只4星以下的怪兽从手卡往作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c30163008.target)
	e1:SetOperation(c30163008.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的战斗阶段开始时，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,30163008)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c30163008.destg)
	e2:SetOperation(c30163008.desop)
	c:RegisterEffect(e2)
end
-- 定义lcheck连接素材检查函数：对候选连接素材组g调用SameValueCheck，检查所有素材怪兽是否拥有共同的种族位掩码，以符合“相同种族的怪兽2只以上”的召唤条件。
function c30163008.lcheck(g)
	-- 返回aux.SameValueCheck的判定结果：若全部素材怪兽的种族位掩码按位与后不为0（存在共同种族），则允许这组怪兽作为连接素材。
	return aux.SameValueCheck(g,Card.GetLinkRace)
end
-- 定义cfilter过滤函数，用于筛选①效果的对象候选：该卡须为表侧表示且位于本卡连接区，并且手牌中存在与它同种族、4星以下且能特殊召唤到本卡连接区的怪兽。
function c30163008.cfilter(c,e,tp,lg,zone)
	return c:IsFaceup() and lg:IsContains(c)
		-- 进一步检查手牌中是否存在满足spfilter条件的怪兽：该怪兽与当前候选对象同种族、等级4以下，且能被特殊召唤到本卡连接区，以保证选定对象后能实际进行特殊召唤。
		and Duel.IsExistingMatchingCard(c30163008.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetRace(),zone)
end
-- 定义chkfilter过滤函数，用于对象卡的合法性确认：对象卡必须是表侧表示、位于本卡连接区，且其种族位掩码包含效果记录的目标种族rc（即与之前选定的怪兽种族一致）。
function c30163008.chkfilter(c,e,tp,lg,rc)
	return c:IsFaceup() and lg:IsContains(c) and c:GetRace()&rc==rc
end
-- 定义spfilter过滤函数，作为手牌中可特殊召唤怪兽的筛选条件：等级4以下、种族等于指定种族rac，且能够被当前玩家以表侧表示特殊召唤到zone区域。
function c30163008.spfilter(c,e,tp,rac,zone)
	return c:IsLevelBelow(4) and c:IsRace(rac) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 定义①效果的Target函数：检查发动条件（存在连接区表侧表示对象、手牌有可特召怪兽、特召区域有空位），选择对象后将对象怪兽的种族记录到e的Label，供处理时使用。
function c30163008.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local zone=c:GetLinkedZone(tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c30163008.chkfilter(chkc,e,tp,lg,e:GetLabel()) end
	-- 检查作为本卡连接区的zone中是否有至少1个空的怪兽区域，确保后续特殊召唤有可用格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		-- 并且检查场上是否存在至少1只满足cfilter的怪兽（位于本卡连接区且手牌有相应可特召怪兽），作为①效果的发动条件。
		and Duel.IsExistingTarget(c30163008.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp,lg,zone) end
	-- 向当前玩家发送选择提示框，提示内容为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让当前玩家从符合条件的本卡连接区表侧表示怪兽中选择1只作为效果对象，并将该卡登记为本连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c30163008.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp,lg,zone)
	-- 设置本次连锁的操作信息：效果包含特殊召唤类别，处理时将从手牌特殊召唤1只怪兽（具体怪兽在效果处理时选择，因此目标暂为nil，数量为1，来源位置为手牌）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	e:SetLabel(g:GetFirst():GetRace())
end
-- 定义①效果的处理函数：验证发动者卡片和对象卡片仍与效果关联且对象未变成里侧表示；随后从手牌中选择1只满足条件的怪兽（与对象同种族、等级4以下且能特召到本卡连接区），在检查特殊召唤条件后将其表侧表示特殊召唤到作为本卡连接区的自己场上。
function c30163008.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取回①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local zone=c:GetLinkedZone(tp)
	-- 向当前玩家发送选择要特殊召唤的卡的提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足spfilter条件的怪兽（等级4以下、种族与对象相同、可特殊召唤到本卡连接区）作为要特殊召唤的卡。
	local sc=Duel.SelectMatchingCard(tp,c30163008.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetRace(),zone):GetFirst()
	if sc then
		-- 在检查特殊召唤条件与苏生限制后，将选择的怪兽以表侧表示特殊召唤到作为本卡连接区的自己场上（zone区域）。
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 定义②效果的Target函数：选择对方场上的1张卡作为对象，并设置破坏效果的操作信息；发动条件为对方场上有任意卡可选择。
function c30163008.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 效果发动时检查对方场上是否存在至少1张可成为对象的卡，若有则②效果满足发动条件。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向当前玩家发送选择要破坏的卡的提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家选择对方场上的1张卡作为效果对象，并将该卡登记为本连锁的取对象目标。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息：破坏对象为已选择的g（目标卡），数量为1，破坏原因为效果，目标位置为对方场上。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义②效果的处理函数：在效果处理时取回对象卡，若对象卡仍与本效果关联，则将其破坏。
function c30163008.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回②效果发动时选择的对方场上的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡片，即执行“那张卡破坏”。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
