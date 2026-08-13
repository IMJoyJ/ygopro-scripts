--魔界劇団－ワイルド・ホープ
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，以另一边的自己的灵摆区域1张「魔界剧团」卡为对象才能发动。那张卡的灵摆刻度直到回合结束时变成9。这个效果的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能特殊召唤。
-- 【怪兽效果】
-- 这个卡名的②的怪兽效果1回合只能使用1次。
-- ①：1回合1次，自己主要阶段才能发动。这张卡的攻击力直到回合结束时上升自己场上的「魔界剧团」怪兽种类×100。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「魔界剧团-狂放新秀」以外的1张「魔界剧团」卡加入手卡。
function c51391183.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽属性（可在灵摆区域发动、进行灵摆召唤等），并注册作为灵摆卡的基础效果。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以另一边的自己的灵摆区域1张「魔界剧团」卡为对象才能发动。那张卡的灵摆刻度直到回合结束时变成9。这个效果的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51391183,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c51391183.target)
	e1:SetOperation(c51391183.operation)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。这张卡的攻击力直到回合结束时上升自己场上的「魔界剧团」怪兽种类×100。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c51391183.atktg)
	e2:SetOperation(c51391183.atkop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的怪兽效果1回合只能使用1次。②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「魔界剧团-狂放新秀」以外的1张「魔界剧团」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,51391183)
	e3:SetCondition(c51391183.thcon)
	e3:SetTarget(c51391183.thtg)
	e3:SetOperation(c51391183.thop)
	c:RegisterEffect(e3)
end
-- 取对象处理：确认自己灵摆区域存在除自身以外的「魔界剧团」卡，然后将该卡（另一边的灵摆卡）设为效果对象。
function c51391183.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件判定：己方灵摆区域存在1张除自身以外、可作为对象的「魔界剧团」卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x10ec) end
	-- 取得另一边的自己的灵摆区域中符合条件的「魔界剧团」卡（由于自身占据一个灵摆区域，实际就是另一侧的那张卡）。
	local tc=Duel.GetFirstMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,e:GetHandler(),0x10ec)
	-- 将选中的卡设置为当前连锁的对象，用于效果处理时的关联判定。
	Duel.SetTargetCard(tc)
end
-- 效果处理：若发动卡仍在灵摆区域且对象仍关联，则将对象的左右灵摆刻度均改为9直到回合结束；随后对发动玩家附加自肃，直到回合结束不能特殊召唤「魔界剧团」以外的怪兽。
function c51391183.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁的对象卡（即之前 SetTargetCard 指定的另一张灵摆卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那张卡的灵摆刻度直到回合结束时变成9。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(9)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		tc:RegisterEffect(e2)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能特殊召唤；①：1回合1次，自己主要阶段才能发动。这张卡的攻击力直到回合结束时上升自己场上的「魔界剧团」怪兽种类×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c51391183.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给当前回合玩家，使该玩家直到回合结束受此不能特殊召唤的限制。
	Duel.RegisterEffect(e3,tp)
end
-- 自肃的判定函数：若要特殊召唤的怪兽不是「魔界剧团」系列，则不允许特殊召唤。
function c51391183.splimit(e,c)
	return not c:IsSetCard(0x10ec)
end
-- 攻击力上升对象的过滤条件：表侧表示且属于「魔界剧团」系列的自己场上的怪兽。
function c51391183.atkfilter(c)
	return c:IsSetCard(0x10ec) and c:IsFaceup()
end
-- 怪兽①的发动判定：自己主要阶段时，检查自己场上是否存在至少1只表侧表示「魔界剧团」怪兽。
function c51391183.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若检查阶段 chk==0 时，判断自己场上是否至少有1只表侧表示「魔界剧团」怪兽，有则满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c51391183.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 攻击力上升效果处理：取得自己场上表侧表示「魔界剧团」怪兽组，按不同卡名数×100计算上升值；若本卡表侧且与效果关联，则给本卡附加攻击力上升效果直到回合结束。
function c51391183.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有表侧表示「魔界剧团」怪兽的集合，用于计算种类数。
	local g=Duel.GetMatchingGroup(c51391183.atkfilter,tp,LOCATION_MZONE,0,nil)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atkval=g:GetClassCount(Card.GetCode)*100
		-- 这张卡的攻击力直到回合结束时上升自己场上的「魔界剧团」怪兽种类×100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 怪兽②的诱发条件判定：本卡被战斗或效果破坏（破坏原因中同时包含战斗/效果其中之一）时才满足。
function c51391183.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 检索用过滤条件：对象卡属于「魔界剧团」、可以加入手卡，且卡名不是「魔界剧团-狂放新秀」自身。
function c51391183.filter(c)
	return c:IsSetCard(0x10ec) and c:IsAbleToHand() and not c:IsCode(51391183)
end
-- 怪兽②的发动判定与操作信息设置：卡组中存在符合条件的「魔界剧团」卡；并设置从卡组将1张卡加入手牌的操作信息。
function c51391183.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件检查：己方卡组是否存在至少1张符合条件的「魔界剧团」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c51391183.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息（效果处理时要把1张卡加入手牌），供其他卡/效果进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 实际处理：玩家从卡组选择1张符合条件的「魔界剧团」卡，将其加入手牌，并向对方展示确认。
function c51391183.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示文字‘请选择要加入手牌的卡’，供玩家选择卡牌时使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 弹出卡组选择界面，让玩家从卡组中选择1张符合条件的卡。
	local g=Duel.SelectMatchingCard(tp,c51391183.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果处理的原因送入持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认，保证信息公开。
		Duel.ConfirmCards(1-tp,g)
	end
end
