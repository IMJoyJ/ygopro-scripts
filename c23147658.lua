--風化戦士
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。把1张「风化战士」以外的有「化石融合」的卡名记述的卡或者「化石融合」从卡组加入手卡。
-- ②：自己结束阶段发动。这张卡的攻击力下降600。
function c23147658.initial_effect(c)
	-- 将“化石融合”的卡号59419719登记到风化战士的记述卡名列表中，使后续检索能识别“有「化石融合」卡名记述的卡”。
	aux.AddCodeList(c,59419719)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。把1张「风化战士」以外的有「化石融合」的卡名记述的卡或者「化石融合」从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23147658,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,23147658)
	e1:SetTarget(c23147658.thtg)
	e1:SetOperation(c23147658.thop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_TO_GRAVE)
	e1x:SetCondition(c23147658.thcon)
	c:RegisterEffect(e1x)
	-- ②：自己结束阶段发动。这张卡的攻击力下降600。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23147658,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c23147658.atkcon)
	e2:SetOperation(c23147658.atkop)
	c:RegisterEffect(e2)
end
-- 定义①效果的检索过滤函数，用于筛选可加入手卡的符合条件的卡组卡片。
function c23147658.thfilter(c)
	-- 筛选条件：卡片不是「风化战士」自身，且卡名为「化石融合」或其文本记述了「化石融合」，同时能够被加入手卡。
	return aux.IsCodeOrListed(c,59419719) and not c:IsCode(23147658) and c:IsAbleToHand()
end
-- 定义效果送墓侧触发分支的额外条件：这张卡被送去墓地时，送墓原因必须是效果，即对应“被效果送去墓地的场合”。
function c23147658.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 设置①效果的发动条件与操作信息：若卡组存在符合条件的卡则可发动，并宣告本效果涉及从卡组将1张卡加入手卡。
function c23147658.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时的合法性检查：确认卡组中存在至少1张满足检索条件的卡片，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c23147658.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：本效果将1张卡从卡组加入手卡，供其他效果进行联动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行①效果的检索处理：让玩家从卡组选择1张符合条件的卡加入手卡，并向对方展示。
function c23147658.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己的卡组中选出1张满足thfilter条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c23147658.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果的触发条件函数，用于判断是否处于自己结束阶段。
function c23147658.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 仅当当前回合玩家为这张卡的控制者（即自己的结束阶段）时，条件成立。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果处理：若这张卡仍与效果相关且表侧表示存在于场上，则使其攻击力下降600。
function c23147658.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力下降600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
