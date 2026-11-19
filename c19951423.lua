--S－Force シグナス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「治安战警队 天鹅侠」以外的1只「治安战警队」怪兽加入手卡。这张卡的正对面有对方怪兽存在的场合，再让自己可以抽1张。
-- ②：自己场上的怪兽的正对面的对方怪兽把效果发动的场合才能发动。自己场上的全部「治安战警队」怪兽的攻击力上升1000。
local s,id,o=GetID()
-- 初始化卡片效果，分别注册召唤·特殊召唤触发的①检索与追加抽卡效果，以及对方正对面怪兽发动效果时触发的②全体加攻效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「治安战警队 天鹅侠」以外的1只「治安战警队」怪兽加入手卡。这张卡的正对面有对方怪兽存在的场合，再让自己可以抽1张。
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
-- 过滤卡组中可检索的怪兽：属于「治安战警队」字段、卡名不为自身、属于怪兽卡且能够加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x156) and not c:IsCode(id) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动检查与信息设置：确认卡组中有可检索怪兽，向对方提示所选效果，并登记从自己卡组将1张卡加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1只满足条件的「治安战警队」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示自己选择了检索效果来发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记本次连锁包含从自己卡组将1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤位于同纵列的对方怪兽：属于怪兽卡且控制者为对方玩家
function s.dmfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(1-tp)
end
-- 执行①效果处理：从卡组选择1只符合条件的「治安战警队」怪兽加入手卡并给对方确认；若自身仍在场上且正对面存在对方怪兽，询问并可执行洗切卡组后抽1张卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家发送选择要加入手卡的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动玩家从自己卡组中选择1只「治安战警队 天鹅侠」以外的「治安战警队」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
		local c=e:GetHandler()
		if c:IsRelateToChain() then
			local cg=c:GetColumnGroup()
			-- 检查这张卡同纵列中是否存在对方怪兽，且自己处于可以抽1张卡的状态
			if cg:IsExists(s.dmfilter,1,nil,tp) and Duel.IsPlayerCanDraw(tp,1)
				-- 询问发动玩家是否要追加抽1张卡
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否抽卡？"
				-- 中断当前效果处理流程，使之后的抽卡视为“再”的非同时处理
				Duel.BreakEffect()
				-- 将自己的卡组洗切
				Duel.ShuffleDeck(tp)
				-- 让发动玩家以效果从卡组抽1张卡
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
-- 过滤与指定序列位置正对面的自己场上怪兽：表侧表示且所在主要怪兽区映射位置与对方怪兽序列互补
function s.cfilter(c,seq2)
	-- 将自身所在怪兽区格子序号转换为从左到右0~4的标准纵列序号
	local seq1=aux.MZoneSequence(c:GetSequence())
	return c:IsFaceup() and seq1==4-seq2
end
-- 检查②效果的发动条件：对方玩家在怪兽区发动了怪兽效果，且自己怪兽区存在与该对方怪兽处于正对面纵列的表侧表示怪兽
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发连锁的对方怪兽效果发生时的位置与所在区域格子序号
	local loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and loc&LOCATION_MZONE==LOCATION_MZONE
		-- 检查自己怪兽区是否存在与对方发动效果的怪兽正对面的表侧表示怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,seq)
end
-- 过滤自己场上可获得攻击力加成的怪兽：表侧表示且属于「治安战警队」字段
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x156)
end
-- ②效果的发动检查：确认自己场上存在表侧表示「治安战警队」怪兽，并向对方提示所发动的效果
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区是否存在至少1只表侧表示的「治安战警队」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方玩家提示自己选择了上升攻击力效果来发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 执行②效果处理：遍历自己场上所有表侧表示的「治安战警队」怪兽，分别赋予其攻击力上升1000（直到离场等标准条件重置）的效果
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上当前全部表侧表示的「治安战警队」怪兽卡片组
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历卡片组中的每一只「治安战警队」怪兽
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
