--エピュアリィ・ハピネス
-- 效果：
-- 2星怪兽×2
-- ①：这张卡进行战斗的伤害步骤结束时才能发动。从卡组把1张「纯爱妖精」卡加入手卡。这张卡有「纯爱妖精快乐回忆」在作为超量素材的场合，可以选场上1只表侧表示怪兽把攻击力变成一半。
-- ②：自己把「纯爱妖精」速攻魔法卡发动时才能发动。场上的那张卡在下面重叠作为超量素材。那之后，可以选对方场上1张魔法·陷阱卡回到持有者手卡。这个效果1回合可以使用最多3次。
local s,id,o=GetID()
-- 注册该怪兽所需的卡片代号记录、XYZ召唤手续（2星怪兽×2）与苏生限制，然后分别注册效果①（伤害步骤结束时检索纯爱妖精并可减半攻击力）和效果②（自己发动纯爱妖精速攻魔法时将其作为超量素材并可选回对方魔陷，1回合最多3次）。
function s.initial_effect(c)
	-- 通过aux.AddCodeList记录这张卡上记载着卡名「纯爱妖精快乐回忆」（卡号82105704），用于判断超量素材是否含有该卡。
	aux.AddCodeList(c,82105704)
	-- 为这张卡添加XYZ召唤手续：需要2只2星怪兽叠放作为超量素材。
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：这张卡进行战斗的伤害步骤结束时才能发动。从卡组把1张「纯爱妖精」卡加入手卡。这张卡有「纯爱妖精快乐回忆」在作为超量素材的场合，可以选场上1只表侧表示怪兽把攻击力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己把「纯爱妖精」速攻魔法卡发动时才能发动。场上的那张卡在下面重叠作为超量素材。那之后，可以选对方场上1张魔法·陷阱卡回到持有者手卡。这个效果1回合可以使用最多3次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动的速攻魔法卡在这张卡下面重叠"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(3)
	e2:SetCondition(s.matcon)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
-- 定义效果①的检索过滤函数：筛选持有者为当前玩家的卡组中，卡名包含「纯爱妖精」（setname=0x18c）且能被效果加入手卡的卡。
function s.tgfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x18c)
end
-- 定义效果①的发动条件与对象设定：在伤害步骤结束时，若卡组存在可检索的纯爱妖精卡则允许发动；向对方提示发动后，将操作信息设定为从卡组把1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点（chk==0）检查卡组是否存在至少1张满足tgfilter的「纯爱妖精」卡，作为效果①能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家发送提示“对方选择了：”并显示该效果的描述文字，用于宣言效果①的发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置本次效果的操作信息：不取对象，从当前玩家卡组将1张卡加入手卡（CATEGORY_TOHAND），供连锁中的其他效果（如星尘龙、王家长眠之谷）进行判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果①的检索：先从卡组选择1张「纯爱妖精」卡加入手卡并展示给对手；随后若本卡有「纯爱妖精快乐回忆」作为超量素材且场上有表侧表示怪兽，则询问玩家是否让其中1只怪兽攻击力变成一半，若是则选1只表侧怪兽并赋予其攻击力变为原来一半（向上取整）的持续效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选择提示，作为随后SelectMatchingCard的交互提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 以当前玩家视角从卡组选择1张满足tgfilter的「纯爱妖精」卡，作为检索对象。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若选择到了卡片，且将其以效果（REASON_EFFECT）送去持有者手卡的操作实际成功，则执行后续确认处理。
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 将刚刚加入手卡的检索结果展示给对方玩家确认（显示卡片信息）。
		Duel.ConfirmCards(1-tp,g)
	end
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,82105704)
		-- 追加条件：当前场上（双方怪兽区域合计）存在至少1只表侧表示怪兽，才能进行攻击力减半的追加选择。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 在满足追加条件后，向当前玩家询问“是否选择1只表侧表示怪兽使其攻击力变成一半？”，若选择是则继续执行减半处理。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选怪兽攻击力变成一半？"
		-- 调用Duel.BreakEffect中断当前效果处理，使后续减半处理与前面的检索处理视为不同时间点，以避免时点错误和连锁判定问题。
		Duel.BreakEffect()
		-- 弹出“请选择表侧表示的卡”的选择提示，用于选择攻击力减半的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 从双方怪兽区域选择1只表侧表示怪兽，并取出第一张作为攻击力减半的对象。
		local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
		-- 为被选中的怪兽播放被选为目标的手工动画，并在规则上将其登记为本效果的对象（广义）。
		Duel.HintSelection(Group.FromCards(tc))
		local atk=tc:GetAttack()
		-- 可以选场上1只表侧表示怪兽把攻击力变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
	end
end
-- 定义效果②的发动条件：当前连锁中发动的卡是魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），发动者是己方（rp==tp），并且该卡是速攻魔法且卡名含有「纯爱妖精」（0x18c）。
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp
		and re:IsActiveType(TYPE_QUICKPLAY) and re:GetHandler():IsSetCard(0x18c)
end
-- 定义效果②的发动时点与目标设定：检查连锁中那张速攻魔法卡是否能作为超量素材叠放；若可以，则向对方提示该效果发动，并让该魔法卡与当前效果e建立联系，确保处理时能正确判定该卡是否仍在连锁中。
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsCanOverlay() end
	-- 向对方玩家发送提示“对方选择了：”并显示效果②的描述文字，用于宣言效果②的发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	re:GetHandler():CreateEffectRelation(e)
end
-- 定义效果②追加回手的过滤函数：筛选对方场上的魔法·陷阱卡（包含表侧和里侧）且能够被效果送回持有者手卡的卡。
function s.rthfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 处理效果②：将发动中的那张「纯爱妖精」速攻魔法卡作为超量素材叠放到这张卡下面；叠放成功后，若对方场上有可回手的魔陷，则询问玩家是否选择1张回到持有者手卡，若选是则进行回手处理。
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if c:IsRelateToChain() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) and tc:IsCanOverlay() then
		tc:CancelToGrave()
		-- 执行Duel.Overlay，将连锁中那张速攻魔法卡tc强制作为超量素材叠放在这张卡c的下方。
		Duel.Overlay(c,tc)
		-- 检查对方场上是否存在至少1张满足rthfilter（魔法·陷阱卡且能回手）的卡，作为追加回手效果能否发动的条件。
		if Duel.IsExistingMatchingCard(s.rthfilter,tp,0,LOCATION_ONFIELD,1,nil)
			-- 在存在可回手对象时，询问当前玩家“是否选择对方1张魔法·陷阱卡回到持有者手卡？”，若选择是则继续执行回手处理。
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否选对方卡回到手卡？"
			-- 调用Duel.BreakEffect中断当前效果，使后续回手处理与前面的叠放处理视为不同时间点，以避免时点错误。
			Duel.BreakEffect()
			-- 弹出“请选择要返回手牌的卡”的选择提示，用于选择回手的对象。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 选择对方场上1张满足rthfilter的魔法·陷阱卡，作为返回持有者手卡的对象。
			local tg=Duel.SelectMatchingCard(tp,s.rthfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
			-- 以效果理由（REASON_EFFECT）将所选卡片返回其持有者手卡。
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		end
	end
end
