--S－Force シグナス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「治安战警队 天鹅侠」以外的1只「治安战警队」怪兽加入手卡。这张卡的正对面有对方怪兽存在的场合，再让自己可以抽1张。
-- ②：自己场上的怪兽的正对面的对方怪兽把效果发动的场合才能发动。自己场上的全部「治安战警队」怪兽的攻击力上升1000。
local s,id,o=GetID()
-- 初始化卡片效果的函数，注册了召唤/特殊召唤成功时检索「治安战警队」怪兽且正对面有对方怪兽时可以抽牌的诱发效果，以及对方在我方怪兽正对面发动怪兽效果时让全场「治安战警队」上升攻击力的全场诱发效果。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「治安战警队 天鹅侠」以外的1只「治安战警队」怪兽加入手卡。这张卡的正对面有对方怪兽存在的场合，再让自己可以抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己场上的怪兽的正对面的对方怪兽把效果发动的场合才能发动。自己场上的全部「治安战警队」怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"上升攻击力"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 过滤函数，筛选出卡组中属于「治安战警队」系列且卡名不是本卡名的怪兽。
function s.thfilter(c)
	return c:IsSetCard(0x156) and not c:IsCode(id) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备与检查函数，确认卡组中是否存在可检索的「治安战警队」怪兽，并在发动时向对方提示本效果的发动并声明包含检索操作的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前判断玩家卡组中是否存在至少1张可以加入手牌的「治安战警队」怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家发送效果发动的提示信息，展示所发动的效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理的操作信息，表明本效果包含从卡组将1只怪兽加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，判断与该卡处于同一纵列的卡片中是否存在属于对方的怪兽卡。
function s.dmfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(1-tp)
end
-- 检索与抽卡效果的执行处理函数，先让玩家从卡组检索1只「治安战警队」怪兽，之后若此卡正对面有对方怪兽，询问玩家是否选择抽1张牌并执行抽牌处理。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示消息，指示其选择卡组中要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合筛选条件的「治安战警队」怪兽卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片从卡组加入到玩家的手牌中。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方确认。
		Duel.ConfirmCards(1-tp,g)
		local c=e:GetHandler()
		if c:IsRelateToChain() then
			local cg=c:GetColumnGroup()
			-- 判断这张卡在当前纵列对应的卡片组中是否存在属于对方的怪兽，并且玩家当前可以执行抽牌操作。
			if cg:IsExists(s.dmfilter,1,nil,tp) and Duel.IsPlayerCanDraw(tp,1)
				-- 弹出一个对话框询问玩家是否选择抽卡。
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否抽卡？"
				-- 中断效果处理的连续性，使之后的抽卡操作与之前的检索加入手牌操作不视为同时处理。
				Duel.BreakEffect()
				-- 洗切玩家的卡组，重新打乱卡组顺序。
				Duel.ShuffleDeck(tp)
				-- 让玩家以效果原因从卡组抽1张卡。
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
-- 过滤函数，判断某只怪兽是否是我方场上表侧表示的「治安战警队」怪兽，且其位置处于被指定怪兽的正对面纵列上。
function s.cfilter(c,seq2)
	-- 获取怪兽在怪兽区域中的绝对序号位置（0-4）。
	local seq1=aux.MZoneSequence(c:GetSequence())
	return c:IsFaceup() and c:IsSetCard(0x156) and seq1==4-seq2
end
-- 提升攻击力效果的条件判断函数，确认发生效果发动的卡片处于对方的主要怪兽区域，且其正对面纵列存在我方表侧表示的「治安战警队」怪兽。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发效果发动时，那张卡在场上的位置区域与怪兽区的具体纵列序号。
	local loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and loc&LOCATION_MZONE==LOCATION_MZONE
		-- 判断我方场上是否存在1只表侧表示的「治安战警队」怪兽，其所处的纵列位置刚好与发动的对方怪兽处于正对面。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,seq)
end
-- 过滤函数，筛选出我方场上所有表侧表示的「治安战警队」怪兽。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x156)
end
-- 提升攻击力效果的发动准备与检查函数，确认我方场上是否存在「治安战警队」怪兽，并向对方提示本效果的发动。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前检查我方场上是否还存在至少1只表侧表示的「治安战警队」怪兽以作为攻击力上升的适用对象。
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方玩家提示此上升攻击力的效果发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 提升攻击力效果的执行处理函数，获取我方场上所有表侧表示的「治安战警队」怪兽，遍历并分别为其注册攻击力上升1000的效果。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在当前场上筛选出所有属于「治安战警队」的表侧表示怪兽并组成一个卡片组。
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历卡片组中的每一张符合条件的怪兽卡。
	for tc in aux.Next(g) do
		-- 自己场上的全部「治安战警队」怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
