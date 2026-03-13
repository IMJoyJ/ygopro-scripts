--エピュアリィ・ハピネス
-- 效果：
-- 2星怪兽×2
-- ①：这张卡进行战斗的伤害步骤结束时才能发动。从卡组把1张「纯爱妖精」卡加入手卡。这张卡有「纯爱妖精快乐回忆」在作为超量素材的场合，可以选场上1只表侧表示怪兽把攻击力变成一半。
-- ②：自己把「纯爱妖精」速攻魔法卡发动时才能发动。场上的那张卡在下面重叠作为超量素材。那之后，可以选对方场上1张魔法·陷阱卡回到持有者手卡。这个效果1回合可以使用最多3次。
local s,id,o=GetID()
-- 初始化效果函数，注册XYZ召唤手续并创建两个效果
function s.initial_effect(c)
	-- 为卡片添加「纯爱妖精快乐回忆」的代码列表
	aux.AddCodeList(c,82105704)
	-- 设置该卡需要2星怪兽×2进行XYZ召唤
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- 效果①：伤害步骤结束时发动，从卡组检索1张「纯爱妖精」卡加入手牌，并可选择场上1只表侧表示怪兽将其攻击力变为一半
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 效果②：自己把「纯爱妖精」速攻魔法卡发动时发动，将该卡作为超量素材叠放于自身下方，并可选择对方场上1张魔法·陷阱卡回到持有者手卡，此效果1回合最多使用3次
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
-- 检索过滤器函数，用于筛选可以加入手牌的「纯爱妖精」卡
function s.tgfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x18c)
end
-- 效果①的目标函数，检查是否满足检索条件并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，即场上是否存在至少1张可加入手牌的「纯爱妖精」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示该效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息，表示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数，执行检索并可能改变怪兽攻击力
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「纯爱妖精」卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否有选中的卡且成功送入手牌
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 确认对方玩家看到被选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,82105704)
		-- 检查场上是否存在至少1只表侧表示怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 询问玩家是否选择怪兽攻击力减半
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选怪兽攻击力变成一半？"
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 提示玩家选择要改变攻击力的表侧表示怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择场上1只表侧表示怪兽
		local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
		-- 显示被选中的怪兽动画效果
		Duel.HintSelection(Group.FromCards(tc))
		local atk=tc:GetAttack()
		-- 设置怪兽攻击力变为原来的一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动条件函数，判断是否为己方发动的「纯爱妖精」速攻魔法卡
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp
		and re:IsActiveType(TYPE_QUICKPLAY) and re:GetHandler():IsSetCard(0x18c)
end
-- 效果②的目标函数，检查要叠放的卡是否可以作为超量素材
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsCanOverlay() end
	-- 向对方玩家提示该效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	re:GetHandler():CreateEffectRelation(e)
end
-- 选择返回手牌的魔法·陷阱卡过滤器
function s.rthfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的处理函数，执行叠放并可能将对方卡送回手牌
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if c:IsRelateToChain() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) and tc:IsCanOverlay() then
		tc:CancelToGrave()
		-- 将选中的卡叠放于自身下方
		Duel.Overlay(c,tc)
		-- 检查对方场上是否存在可送回手牌的魔法·陷阱卡
		if Duel.IsExistingMatchingCard(s.rthfilter,tp,0,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否选择对方卡返回手牌
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否选对方卡回到手卡？"
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 提示玩家选择要返回手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 选择要返回手牌的魔法·陷阱卡
			local tg=Duel.SelectMatchingCard(tp,s.rthfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
			-- 将选中的卡送回持有者手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		end
	end
end
