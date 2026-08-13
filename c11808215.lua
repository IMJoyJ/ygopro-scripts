--ダイス・ダンジョン
-- 效果：
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「次元解骰」加入手卡。
-- ②：自己·对方的战斗阶段开始时才能发动。双方各自掷1次骰子，自身场上的全部怪兽的攻击力直到回合结束时受出现的数目的效果适用。
-- ●1：下降1000。
-- ●2：上升1000。
-- ●3：下降500。
-- ●4：上升500。
-- ●5：变成一半。
-- ●6：变成2倍。
function c11808215.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「次元解骰」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c11808215.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段开始时才能发动。双方各自掷1次骰子，自身场上的全部怪兽的攻击力直到回合结束时受出现的数目的效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11808215,1))
	e2:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c11808215.dicetg)
	e2:SetOperation(c11808215.diceop)
	c:RegisterEffect(e2)
end
-- 检索过滤函数：筛选卡组中卡名为「次元解骰」且能够加入手卡的卡。
function c11808215.thfilter(c)
	return c:IsCode(47292920) and c:IsAbleToHand()
end
-- ①效果的发动时处理：若卡组存在「次元解骰」且玩家选择是，则从卡组选1张加入手卡，并向对方确认。
function c11808215.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取持有者tp的卡组中所有满足「次元解骰且能加入手卡」条件的卡。
	local g=Duel.GetMatchingGroup(c11808215.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若检索目标存在且玩家选择“是”，则继续处理检索；提示语为“是否从卡组把1张「次元解骰」加入手卡？”
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(11808215,0)) then  --"是否从卡组把1张「次元解骰」加入手卡？"
		-- 显示选择卡片的提示，提示内容为“请选择要加入手牌的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将玩家选择的卡以效果原因送去其持有者的手卡（加入手卡）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方的玩家确认刚才加入手卡的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- ②效果的发动条件和连锁信息：自己或对方场上有表侧表示怪兽时才能发动；并登记双方各掷1次骰子的操作信息。
function c11808215.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时的合法条件检查：场上存在至少1只表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 登记本次效果将进行掷骰子操作：玩家双方各掷1次（操作信息用于触发相关卡的检测）。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,PLAYER_ALL,1)
end
-- ②效果的处理：依次对当前回合玩家和对方玩家执行掷骰子，根据各自掷出的点数，对各自场上全部表侧表示怪兽适用对应的攻击力变化或设定，直到回合结束时有效。
function c11808215.diceop(e,tp,eg,ep,ev,re,r,rp)
	-- 依次遍历当前回合玩家和对方玩家，使双方各执行一次掷骰子处理。
	for p in aux.TurnPlayers() do
		-- 让玩家p掷1次骰子，得到1~6的点数结果。
		local dice=Duel.TossDice(p,1)
		if dice>=1 and dice<=6 then
			-- 取得玩家p场上全部表侧表示怪兽的集合，用于后续逐个赋予攻击力变化效果。
			local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
			local sc=g:GetFirst()
			while sc do
				local atk=sc:GetAttack()
				-- ●1：下降1000。●2：上升1000。●3：下降500。●4：上升500。●5：变成一半。●6：变成2倍。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(dice<5 and EFFECT_UPDATE_ATTACK or EFFECT_SET_ATTACK_FINAL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				e1:SetValue(({-1000,1000,-500,500,math.ceil(atk/2),atk*2})[dice])
				sc:RegisterEffect(e1)
				sc=g:GetNext()
			end
		end
	end
end
