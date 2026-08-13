--アカシック・マジシャン
-- 效果：
-- 衍生物以外的相同种族的怪兽2只
-- 自己对「虚空俏丽魔术师」1回合只能有1次连接召唤。
-- ①：这张卡连接召唤成功的场合发动。这张卡所连接区的怪兽全部回到持有者手卡。
-- ②：1回合1次，宣言1个卡名才能发动。把这张卡所互相连接区的怪兽的连接标记合计数量的卡从自己卡组上面翻开，那之中有宣言的卡的场合，那卡加入手卡。那以外的翻开的卡全部送去墓地。
function c28776350.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只衍生物以外的相同种族的怪兽作为连接素材（通过lcheck追加检查种族相同）。
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2,2,c28776350.lcheck)
	c:EnableReviveLimit()
	-- 自己对「虚空俏丽魔术师」1回合只能有1次连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c28776350.regcon)
	e1:SetOperation(c28776350.regop)
	c:RegisterEffect(e1)
	-- ①：这张卡连接召唤成功的场合发动。这张卡所连接区的怪兽全部回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28776350,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c28776350.thcon)
	e2:SetTarget(c28776350.thtg)
	e2:SetOperation(c28776350.thop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，宣言1个卡名才能发动。把这张卡所互相连接区的怪兽的连接标记合计数量的卡从自己卡组上面翻开，那之中有宣言的卡的场合，那卡加入手卡。那以外的翻开的卡全部送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28776350,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c28776350.actg)
	e3:SetOperation(c28776350.acop)
	c:RegisterEffect(e3)
end
-- 定义连接素材的追加检查函数lcheck，用于确认所选的连接素材怪兽全部拥有相同种族。
function c28776350.lcheck(g)
	-- 使用SameValueCheck检查素材组中所有怪兽通过Card.GetLinkRace计算的种族位掩码是否存在共同交集，即种族全部相同。
	return aux.SameValueCheck(g,Card.GetLinkRace)
end
-- regcon条件：本效果的触发条件为这张卡是以连接召唤方式特殊召唤成功。
function c28776350.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- regop操作：连接召唤成功时，给己方场上注册一个永续效果：直到回合结束，自己不能进行「虚空俏丽魔术师」的连接召唤。
function c28776350.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己对「虚空俏丽魔术师」1回合只能有1次连接召唤。①：这张卡连接召唤成功的场合发动。这张卡所连接区的怪兽全部回到持有者手卡。②：1回合1次，宣言1个卡名才能发动。把这张卡所互相连接区的怪兽的连接标记合计数量的卡从自己卡组上面翻开，那之中有宣言的卡的场合，那卡加入手卡。那以外的翻开的卡全部送去墓地。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c28776350.splimit)
	-- 将刚创建的限制特殊召唤的效果e1注册到当前玩家tp的场上，使其生效。
	Duel.RegisterEffect(e1,tp)
end
-- splimit限制判断：被限制的怪兽必须是「虚空俏丽魔术师」，且召唤方式为连接召唤。
function c28776350.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(28776350) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- thcon条件：这张卡以连接召唤方式特殊召唤成功时，①效果才满足发动条件。
function c28776350.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- thtg目标设定：①效果发动时，收集这张卡所连接区中所有能够加入手卡的怪兽，并设置对应的回手卡操作信息。
function c28776350.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lg=e:GetHandler():GetLinkedGroup():Filter(Card.IsAbleToHand,nil)
	-- 将①效果的操作信息设为回手卡：对象为所连接区中满足条件的怪兽，数量为其数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,lg,lg:GetCount(),0,0)
end
-- thop处理：①效果处理时，取出这张卡所连接区的怪兽，实际执行返回持有者手卡。
function c28776350.thop(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup():Filter(Card.IsAbleToHand,nil)
	-- 将所连接区的怪兽全部返回持有者手卡（player参数为nil表示返回各自持有者手卡）。
	Duel.SendtoHand(lg,nil,REASON_EFFECT)
end
-- actg是②效果的发动阶段处理：检查互相连接区连接标记合计数量、卡组可送墓及存在可加入手卡的卡；随后宣言卡名并保存为连锁参数。
function c28776350.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local lg=c:GetMutualLinkedGroup()
		local ct=lg:GetSum(Card.GetLink)
		-- ②效果发动合法性检查：若互相连接区怪兽的连接标记合计为0，或玩家卡组不能被送墓，则不能发动。
		if ct<=0 or not Duel.IsPlayerCanDiscardDeck(tp,ct) then return false end
		-- 取得玩家卡组最上方ct张卡，作为将要翻开的候选卡组。
		local g=Duel.GetDecktopGroup(tp,ct)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	-- 提示玩家宣言一个卡名，HINTMSG_CODE表示需要输入/选择卡名。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言一个卡名（过滤条件限定为融合·同调·XYZ·连接怪兽），返回宣言的卡号ac。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号ac保存为当前连锁的目标参数，供效果处理时读取。
	Duel.SetTargetParam(ac)
	-- 设置本连锁包含卡名宣言（CATEGORY_ANNOUNCE）的操作信息，以便相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- thfilter过滤函数：判断翻开的卡是否与宣言卡号一致，并且能够加入手卡。
function c28776350.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- acop是②效果的实际处理：翻开卡组顶ct张卡，将其中宣言的卡加入手卡并展示给对方，其余卡送去墓地，同时处理洗牌相关操作。
function c28776350.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetMutualLinkedGroup()
	local ct=lg:GetSum(Card.GetLink)
	-- 效果处理时再次确认：互相连接区连接标记合计ct>0且玩家卡组可送墓，否则中止处理。
	if ct<=0 or not Duel.IsPlayerCanDiscardDeck(tp,ct) then return end
	-- 向双方确认并展示玩家卡组最上方ct张卡。
	Duel.ConfirmDecktop(tp,ct)
	-- 取得卡组最上方ct张卡作为本次处理的对象组。
	local g=Duel.GetDecktopGroup(tp,ct)
	-- 获取发动时通过Duel.SetTargetParam保存的宣言卡号ac。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local hg=g:Filter(c28776350.thfilter,nil,ac)
	g:Sub(hg)
	if hg:GetCount()~=0 then
		-- 禁用自动洗切检测，因为接下来要将卡加入手卡，避免系统在效果处理结束时自动洗卡组。
		Duel.DisableShuffleCheck()
		-- 将翻开的宣言卡加入其持有者的手卡。
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
		-- 将加入手卡的宣言卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,hg)
		-- 手动洗切自己的手卡，因为从卡组获得了卡，需要隐藏手牌信息。
		Duel.ShuffleHand(tp)
	end
	if g:GetCount()~=0 then
		-- 禁用自动洗切检测，因为接下来要将剩余翻开的卡送去墓地，避免系统自动洗卡组。
		Duel.DisableShuffleCheck()
		-- 将剩余翻开的卡以效果原因（并标记为翻开过）全部送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	end
end
