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
-- 过滤函数，用于检索卡组中可加入手牌的「次元解骰」卡片。
function c11808215.thfilter(c)
	return c:IsCode(47292920) and c:IsAbleToHand()
end
-- 发动时的处理函数，用于执行①效果，即检索并加入手牌。
function c11808215.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「次元解骰」卡片组。
	local g=Duel.GetMatchingGroup(c11808215.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否存在满足条件的卡片并询问玩家是否发动效果。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(11808215,0)) then  --"是否从卡组把1张「次元解骰」加入手卡？"
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片送入手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认送入手牌的卡片。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 骰子效果的触发条件函数，用于判断是否可以发动。
function c11808215.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置连锁操作信息，表示将要进行骰子投掷。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,PLAYER_ALL,1)
end
-- 骰子效果的处理函数，用于执行②效果。
function c11808215.diceop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历当前回合玩家和对方玩家。
	for p in aux.TurnPlayers() do
		-- 让玩家投掷一次骰子。
		local dice=Duel.TossDice(p,1)
		if dice>=1 and dice<=6 then
			-- 获取当前玩家场上的所有表侧表示怪兽。
			local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
			local sc=g:GetFirst()
			while sc do
				local atk=sc:GetAttack()
				-- 根据骰子点数为怪兽设置攻击力变化效果。
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
