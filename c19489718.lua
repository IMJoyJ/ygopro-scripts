--魔鍵銃－バトスバスター
-- 效果：
-- 「魔键-马夫提亚」降临。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡仪式召唤成功的场合才能发动。从卡组把1张「魔键」卡加入手卡。
-- ②：1回合1次，持有和自己墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的对方怪兽在和这张卡进行战斗的攻击宣言时才能发动。自己手卡任意数量回到卡组最下面，那只对方怪兽的效果直到回合结束时无效。那之后，自己抽出回到卡组的数量。
function c19489718.initial_effect(c)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡仪式召唤成功的场合才能发动。从卡组把1张「魔键」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19489718,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,19489718)
	e1:SetCondition(c19489718.srcon)
	e1:SetTarget(c19489718.srtg)
	e1:SetOperation(c19489718.srop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，持有和自己墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的对方怪兽在和这张卡进行战斗的攻击宣言时才能发动。自己手卡任意数量回到卡组最下面，那只对方怪兽的效果直到回合结束时无效。那之后，自己抽出回到卡组的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19489718,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DISABLE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c19489718.discon)
	e2:SetTarget(c19489718.distg)
	e2:SetOperation(c19489718.disop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡必须是仪式召唤成功（召唤类型为仪式召唤）才满足。
function c19489718.srcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 检索目标筛选：判断卡片是否为卡名含有「魔键」的卡，并且能够加入手卡。
function c19489718.srfilter(c)
	return c:IsSetCard(0x165) and c:IsAbleToHand()
end
-- ①效果的发动时点处理：先检查卡组中是否存在1张可检索的「魔键」卡，满足则登记“从卡组把1张卡加入手卡”的操作信息。
function c19489718.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己卡组中存在至少1张满足条件的「魔键」卡（且能加入手卡）时才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c19489718.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记当前连锁将执行“从卡组把1张卡加入手卡”的操作信息，用于其他卡对该效果的对应判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从自己卡组选择1张满足条件的「魔键」卡加入手卡，并向对方展示。
function c19489718.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选择提示，供玩家选择要检索的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张满足「魔键」字段且能加入手卡的卡（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c19489718.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 墓地筛选函数：判断卡片是否为通常怪兽或「魔键」怪兽，且属性与对方那只怪兽的属性相同。
function c19489718.cfilter(c,attr)
	return (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165)) and c:IsAttribute(attr)
end
-- ②效果的发动条件：这张卡的战斗对象为对方怪兽，该怪兽可作为无效对象，且自己墓地存在满足对应属性条件的通常怪兽或「魔键」怪兽；同时把战斗对象存入标签。
function c19489718.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	e:SetLabelObject(tc)
	-- 检查战斗对象：存在战斗对象，且是对方场上的怪兽，并且是表侧表示、未被无效、可被无效其效果的怪兽。
	return tc and tc:IsControler(1-tp) and tc:IsType(TYPE_MONSTER) and aux.NegateMonsterFilter(tc)
		-- 检查自己墓地是否存在与该战斗对象属性相同的通常怪兽或「魔键」怪兽，作为②效果发动的条件。
		and Duel.IsExistingMatchingCard(c19489718.cfilter,tp,LOCATION_GRAVE,0,1,nil,tc:GetAttribute())
end
-- ②效果的发动合法性检查：自己能够抽卡，且手牌中至少有1张可以回到卡组的卡；同时登记对象玩家与操作信息。
function c19489718.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	-- 检查自己是否可以抽卡（若受到“不能抽卡”效果影响则不能发动）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查自己手牌中是否存在至少1张可以回到卡组的卡，作为回卡组并抽卡的前提。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	-- 将当前连锁的对象玩家设为自己，表示后续回卡组与抽卡的玩家是自己。
	Duel.SetTargetPlayer(tp)
	-- 登记“将手牌返回卡组”的操作信息，数量为至少1张（实际数量处理时决定）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 登记“无效那只对方怪兽效果”的操作信息，关联卡为tc，用于后续对应判定。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
	-- 登记“自己进行抽卡”的操作信息，实际抽卡数为回到卡组的卡片数量。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：选择任意数量手牌放回卡组最下面，将战斗对象怪兽的效果无效，然后抽取相同数量的卡。
function c19489718.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 获取当前连锁登记的对象玩家（即自己），用于后续选择和抽卡。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 弹出“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手牌中选择1～63张可以回到卡组的卡（任意数量，至少1张）。
	local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,63,nil)
	if g:GetCount()==0 then return end
	-- 将选中的手牌以效果原因返回持有者卡组最上方，返回实际移动数量ct；若为0则中断处理。
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	if ct==0 then return end
	-- 对刚回到卡组最上方的ct张卡进行排序，为接下来按顺序放到卡组最下面做准备。
	Duel.SortDecktop(p,p,ct)
	for i=1,ct do
		-- 取出当前卡组最上方的1张卡。
		local mg=Duel.GetDecktopGroup(p,1)
		-- 将这张卡移动到卡组最下面，从而实现把所选手牌放到卡组最下面。
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
	if tc and tc:IsRelateToBattle() and tc:IsControler(1-tp)
		and tc:IsCanBeDisabledByEffect(e) then
		-- 那只对方怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		-- 中断当前效果处理，使随后的抽卡处理作为后续独立处理，以正确对应时点。
		Duel.BreakEffect()
		-- 自己抽出与回到卡组的卡片数量相同的卡。
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
