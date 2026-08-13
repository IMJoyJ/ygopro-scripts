--トロイメア・ゴブリン
-- 效果：
-- 卡名不同的怪兽2只
-- ①：这张卡在自己回合连接召唤的场合，丢弃1张手卡才能发动。这个效果的发动时这张卡是互相连接状态的场合，自己可以抽1张。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以从手卡把1只怪兽在作为这张卡所连接区的自己场上召唤。
-- ②：只要这张卡在怪兽区域存在，双方不能把自己场上的互相连接状态的怪兽作为效果的对象。
function c39064822.initial_effect(c)
	-- 为这张卡『梦幻崩影·哥布林』添加连接召唤手续，素材要求为卡名不同的2只怪兽（通过检查素材的连接代码互不相同来保证卡名不同）。
	aux.AddLinkProcedure(c,nil,2,2,c39064822.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡在自己回合连接召唤的场合，丢弃1张手卡才能发动。这个效果的发动时这张卡是互相连接状态的场合，自己可以抽1张。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以从手卡把1只怪兽在作为这张卡所连接区的自己场上召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39064822,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c39064822.sumcon)
	e1:SetCost(c39064822.sumcost)
	e1:SetTarget(c39064822.sumtg)
	e1:SetOperation(c39064822.sumop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，双方不能把自己场上的互相连接状态的怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c39064822.tgtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 连接素材的合法性过滤：所有素材的连接代码互不相同，即素材卡名各不相同，满足‘卡名不同的怪兽2只’的素材条件。
function c39064822.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 效果①的发动条件判定：这张卡是连接召唤成功，并且当前回合为这张卡的控制者自己的回合，即满足‘这张卡在自己回合连接召唤的场合’。
function c39064822.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡的召唤类型确实是连接召唤，并且当前回合玩家是效果发动者自身（tp），即确认是‘自己回合连接召唤’。
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and Duel.GetTurnPlayer()==tp
end
-- 效果①的发动代价：从手卡丢弃1张卡作为代价。先检查手牌中有无可丢弃的卡，若可以则实际选择丢弃1张，丢弃原因视为代价丢弃（COST+REASON_DISCARD）。
function c39064822.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：确认自己的手牌中存在至少1张可以丢弃的卡，否则该效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行丢弃1张手卡作为发动代价，从自己手牌中选择1张丢弃，丢弃原因为COST+REASON_DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果①的发动目标设定：确认自己能通常召唤且拥有额外通常召唤次数，并且本回合尚未发动过本效果；同时根据这张卡是否处于互相连接状态，决定效果类别中是否包含抽卡（CATEGORY_DRAW），并用label记录该状态供处理阶段使用。
function c39064822.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己可以进行通常召唤，自己可以进行追加通常召唤，且本回合没有使用过本效果（没有对应的flag标记）。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.GetFlagEffect(tp,39064822)==0 end
	if e:GetHandler():GetMutualLinkedGroupCount()>0 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetLabel(1)
	else
		e:SetCategory(0)
		e:SetLabel(0)
	end
end
-- 效果①的实际处理：若发动时这张卡处于互相连接状态且玩家选择抽卡，则抽1张；然后若本回合尚未赋予过本效果的追加召唤能力，则给自己注册‘在作为这张卡所连接区的自己场上追加通常召唤1次’的效果，并登记flag标记。
function c39064822.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足抽卡条件：发动时这张卡处于互相连接状态（label为1），且自己可以抽1张卡。
	if e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
		-- 进一步询问玩家是否抽卡，实现‘自己可以抽1张’的选发效果。
		and Duel.SelectYesNo(tp,aux.Stringid(39064822,1)) then  --"是否抽卡？"
		-- 自己实际抽1张卡，抽卡原因为效果（REASON_EFFECT）。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	-- 如果本回合已经存在本效果的标记（说明额外召唤效果已赋予过），则直接结束，不重复赋予追加召唤效果。
	if Duel.GetFlagEffect(tp,39064822)~=0 then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- ①：这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以从手卡把1只怪兽在作为这张卡所连接区的自己场上召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39064822,2))  --"使用「梦幻崩影·哥布林」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetLabel(fid)
	e1:SetCondition(c39064822.sumcon2)
	e1:SetValue(c39064822.sumval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将额外召唤效果e1注册到玩家tp，使tp玩家本回合获得在指定连接区进行额外通常召唤的权限。
	Duel.RegisterEffect(e1,tp)
	-- 为玩家tp注册一个标志效果，记录本回合已经使用过『梦幻崩影·哥布林』的追加召唤效果，持续到结束阶段并重置，防止同回合再次使用。
	Duel.RegisterFlagEffect(tp,39064822,RESET_PHASE+PHASE_END,0,1)
end
-- 额外召唤效果e1的持续条件：检查这张『梦幻崩影·哥布林』的FieldID与发动时保存的Label一致，确保效果只伴随该卡本回合仍在场上时有效，避免同名卡或其他卡误用。
function c39064822.sumcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFieldID()==e:GetLabel()
end
-- 设置额外通常召唤效果的具体参数：返回可召唤的怪兽区域为这张卡所连接的区域（sumzone），并限制相关相对区域（relzone），实现在这张卡所连接区的自己场上进行追加通常召唤。
function c39064822.sumval(e,c)
	local c=e:GetHandler()
	local sumzone=c:GetLinkedZone()
	local relzone=-bit.lshift(1,c:GetSequence())
	return 0,sumzone,relzone
end
-- ②效果的适用对象过滤器：只有处于互相连接状态的怪兽才会被该效果选中，即‘双方不能把自己场上的互相连接状态的怪兽作为效果的对象’。
function c39064822.tgtg(e,c)
	return c:GetMutualLinkedGroupCount()>0
end
