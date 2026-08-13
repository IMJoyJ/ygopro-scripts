--古代の機械飛竜
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「古代的机械飞龙」以外的1张「古代的机械」卡加入手卡。这个效果的发动后，直到回合结束时自己不能把卡盖放。
-- ②：这张卡攻击的场合，对方直到伤害步骤结束时怪兽的效果不能发动。
function c17663375.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「古代的机械飞龙」以外的1张「古代的机械」卡加入手卡。这个效果的发动后，直到回合结束时自己不能把卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17663375,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,17663375)
	e1:SetTarget(c17663375.thtg)
	e1:SetOperation(c17663375.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡攻击的场合，对方直到伤害步骤结束时怪兽的效果不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c17663375.aclimit)
	e3:SetCondition(c17663375.actcon)
	c:RegisterEffect(e3)
end
-- 筛选符合条件的卡：卡名属于「古代的机械」字段、卡名不是「古代的机械飞龙」、且能够加入手卡。
function c17663375.thfilter(c)
	return c:IsSetCard(0x7) and not c:IsCode(17663375) and c:IsAbleToHand()
end
-- ①效果的发动条件判定与操作信息设置：自己卡组存在符合条件的「古代的机械」卡时才能发动，并设置把1张卡加入手卡的处理信息。
function c17663375.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点（chk==0）检查自己卡组是否存在至少1张符合条件的「古代的机械」卡，若存在则满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c17663375.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果从卡组把1张卡加入手卡（处理数量为1，处理位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选1张符合条件的「古代的机械」卡加入手卡并让对方确认；随后给自己附加「直到回合结束时不能盖放」的一系列限制（不能盖放怪兽/魔法陷阱、不能变里侧表示、不能以里侧表示特殊召唤）。
function c17663375.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出「请选择要加入手牌的卡」的提示消息，供玩家选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张符合条件的「古代的机械」卡。
	local g=Duel.SelectMatchingCard(tp,c17663375.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把卡盖放。②：这张卡攻击的场合，对方直到伤害步骤结束时怪兽的效果不能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetTargetRange(1,0)
	-- 将该限制效果的目标筛选设为无条件（aux.TRUE），使效果作用于所有相关卡片。
	e1:SetTarget(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将「不能盖放怪兽」的限制效果注册给当前玩家，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	-- 将「不能盖放魔法·陷阱」的限制效果注册给当前玩家。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	-- 将「不能把卡片变里侧表示」的限制效果注册给当前玩家。
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetTarget(c17663375.sumlimit)
	-- 将「不能以里侧表示特殊召唤」的限制效果注册给当前玩家。
	Duel.RegisterEffect(e4,tp)
end
-- 判定函数：若特殊召唤的表示形式包含里侧表示（POS_FACEDOWN），则禁止该特殊召唤。
function c17663375.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)>0
end
-- ②效果的判定函数：对方发动的效果是否为怪兽效果（若是则受到不能发动限制）。
function c17663375.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动条件：当前进行攻击的怪兽是否就是本卡。
function c17663375.actcon(e)
	-- 返回当前攻击怪兽是否就是这张卡（e:GetHandler()）。
	return Duel.GetAttacker()==e:GetHandler()
end
