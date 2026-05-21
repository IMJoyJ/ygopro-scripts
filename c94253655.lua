--海造賊－豪速のブレンネ号
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的其他的恶魔族怪兽的攻击力上升500。
-- ②：从手卡丢弃1张「海造贼」卡，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡除外。那之后，可以从卡组把1只「海造贼」怪兽加入手卡。这张卡有「海造贼」卡装备的场合，这个效果在对方回合也能发动。
function c94253655.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己场上的其他的恶魔族怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c94253655.atktg)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	-- ②：从手卡丢弃1张「海造贼」卡，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡除外。那之后，可以从卡组把1只「海造贼」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94253655,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,94253655)
	e2:SetCondition(c94253655.rmcon1)
	e2:SetCost(c94253655.rmcost)
	e2:SetTarget(c94253655.rmtg)
	e2:SetOperation(c94253655.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_SSET+TIMING_EQUIP+TIMING_END_PHASE)
	e3:SetCondition(c94253655.rmcon2)
	c:RegisterEffect(e3)
end
-- 过滤自身以外、自己场上表侧表示的恶魔族怪兽作为攻击力上升效果的对象
function c94253655.atktg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c~=e:GetHandler()
end
-- 过滤表侧表示的「海造贼」卡
function c94253655.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- 检查自身没有装备「海造贼」卡，作为起动效果的发动条件
function c94253655.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return not g or not g:IsExists(c94253655.confilter,1,nil)
end
-- 检查自身有装备「海造贼」卡，作为诱发即时效果（对方回合也能发动）的发动条件
function c94253655.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return g and g:IsExists(c94253655.confilter,1,nil)
end
-- 过滤手卡中可以丢弃的「海造贼」卡
function c94253655.costfilter(c)
	return c:IsSetCard(0x13f) and c:IsDiscardable()
end
-- 效果②的发动代价：从手卡丢弃1张「海造贼」卡
function c94253655.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可作为发动代价丢弃的「海造贼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c94253655.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要丢弃的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家选择1张手卡中的「海造贼」卡
	local g=Duel.SelectMatchingCard(tp,c94253655.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡作为发动代价丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤场上可以被除外的魔法·陷阱卡
function c94253655.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 效果②的靶向与效果注册：以对方场上1张魔法·陷阱卡为对象发动，并设置除外操作信息
function c94253655.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c94253655.rmfilter(chkc) end
	-- 检查对方场上是否存在可以作为效果对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c94253655.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择对方场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c94253655.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：除外该对象卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 过滤卡组中可以加入手卡的「海造贼」怪兽
function c94253655.thfilter(c)
	return c:IsSetCard(0x13f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的处理：除外对象卡，之后可以从卡组把1只「海造贼」怪兽加入手卡
function c94253655.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍符合条件且成功除外，且卡组有可检索的「海造贼」怪兽，则询问玩家是否进行检索
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(c94253655.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(94253655,1)) then  --"是否从卡组把「海造贼」怪兽加入手卡？"
		-- 中断当前效果处理，使后续的检索处理与除外处理不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只「海造贼」怪兽
		local g=Duel.SelectMatchingCard(tp,c94253655.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
