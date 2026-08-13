--鋼核合成獣研究所
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡给1张「核成兽的钢核」对方观看。或者不给观看让这张卡破坏。每次场上存在的名字带有「核成」的怪兽在结束阶段时被破坏，那些怪兽的原本持有者可以从卡组把1只名字带有「核成」的怪兽加入手卡。
function c53039326.initial_effect(c)
	-- 记录这张卡文本中提到的「核成兽的钢核」（卡号36623431），用于关联该卡名的检索/展示等处理。
	aux.AddCodeList(c,36623431)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应效果原文：“这张卡的控制者在每次自己的结束阶段从手卡给1张「核成兽的钢核」对方观看。或者不给观看让这张卡破坏。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c53039326.mtcon)
	e2:SetOperation(c53039326.mtop)
	c:RegisterEffect(e2)
	-- 对应效果原文：“每次场上存在的名字带有「核成」的怪兽在结束阶段时被破坏，那些怪兽的原本持有者可以从卡组把1只名字带有「核成」的怪兽加入手卡。”
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetDescription(aux.Stringid(53039326,2))  --"检索"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_EVENT_PLAYER)
	e4:SetCode(EVENT_CUSTOM+53039326)
	e4:SetTarget(c53039326.target)
	e4:SetOperation(c53039326.operation)
	c:RegisterEffect(e4)
	if not c53039326.global_check then
		c53039326.global_check=true
		-- 对应效果原文：“这张卡的控制者在每次自己的结束阶段从手卡给1张「核成兽的钢核」对方观看。或者不给观看让这张卡破坏。每次场上存在的名字带有「核成」的怪兽在结束阶段时被破坏，那些怪兽的原本持有者可以从卡组把1只名字带有「核成」的怪兽加入手卡。”
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(c53039326.check)
		-- 将全局破坏监听效果ge1注册到玩家0（全游戏），使check函数能监听场上任意怪兽被破坏的事件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 筛选条件：手牌中存在且未公开的「核成兽的钢核」（卡号36623431），可作为给对方观看的候选。
function c53039326.cfilter(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- 该维持效果e2的发动条件：仅当当前回合玩家是这张卡的控制者tp时，才在结束阶段执行维持COST处理。
function c53039326.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于tp，用于确保只在自己的结束阶段处理维持COST。
	return Duel.GetTurnPlayer()==tp
end
-- 结束阶段维持COST处理：展示自身并获取手牌中未公开的钢核；若有钢核则让控制者选择展示钢核或破坏此卡，若没有则只能破坏此卡；选择展示时选1张钢核给对方确认并洗切手牌，选择破坏时以COST破坏此卡。
function c53039326.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给这张卡显示被选择/进入处理的动画，提示双方该卡正在执行结束阶段的维持COST处理。
	Duel.HintSelection(Group.FromCards(c))
	-- 获取tp手牌中所有满足cfilter的「核成兽的钢核」，得到可展示的候选集合。
	local g=Duel.GetMatchingGroup(c53039326.cfilter,tp,LOCATION_HAND,0,nil)
	local sel=1
	if g:GetCount()~=0 then
		-- 手牌有钢核时，让tp在“展示钢核”和“破坏此卡”两者中选择，返回选择序号（0为展示，1为破坏）。
		sel=Duel.SelectOption(tp,aux.Stringid(53039326,0),aux.Stringid(53039326,1))  --"把1张「核成兽的钢核」对方观看/破坏「钢核合成兽研究所」"
	else
		-- 手牌没有钢核时，仅提供“破坏此卡”一个选项；将SelectOption返回的0加1变为1，以与上面破坏分支的sel值一致。
		sel=Duel.SelectOption(tp,aux.Stringid(53039326,1))+1  --"破坏「钢核合成兽研究所」"
	end
	if sel==0 then
		-- 提示tp选择一张卡给对方确认，并写入选择提示缓存（HINTMSG_CONFIRM）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local cg=g:Select(tp,1,1,nil)
		-- 将选中的钢核展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,cg)
		-- 展示手牌后洗切tp的手牌，防止对手通过刚才的确认得知手牌顺序。
		Duel.ShuffleHand(tp)
	else
		-- 因未展示钢核，以COST（规则代价）的方式破坏这张「钢核合成兽研究所」。
		Duel.Destroy(c,REASON_COST)
	end
end
-- check函数：全局破坏事件的操作。仅在结束阶段，筛选出被破坏前是表侧表示且在怪兽区的「核成」怪兽，按原本持有者是否为当前回合玩家分成g1/g2两组，并分别为两组触发自定义检索事件EVENT_CUSTOM+53039326，让对应的原本持有者获得检索机会。
function c53039326.check(e,tp,eg,ep,ev,re,r,rp)
	-- 只处理结束阶段发生的破坏；若不是结束阶段，直接结束本次操作。
	if Duel.GetCurrentPhase()~=PHASE_END then return end
	local tc=eg:GetFirst()
	-- 取得当前回合玩家，用于判断被破坏的「核成」怪兽的原本持有者是否为当前回合玩家。
	local turnp=Duel.GetTurnPlayer()
	local g1=Group.CreateGroup()
	local g2=Group.CreateGroup()
	while tc do
		if tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and tc:IsSetCard(0x1d) then
			if tc:GetOwner()==turnp then g1:AddCard(tc) else g2:AddCard(tc) end
		end
		tc=eg:GetNext()
	end
	-- 若存在原本持有者是当前回合玩家的被破坏「核成」怪兽，则对这些怪兽触发自定义检索事件，事件玩家为当前回合玩家，使其可以发动检索效果。
	if g1:GetCount()>0 then Duel.RaiseEvent(g1,EVENT_CUSTOM+53039326,re,r,rp,turnp,0) end
	-- 若存在原本持有者是对方玩家（非当前回合玩家）的被破坏「核成」怪兽，则对它们触发自定义检索事件，事件玩家为该原本持有者，使其可以发动检索效果。
	if g2:GetCount()>0 then Duel.RaiseEvent(g2,EVENT_CUSTOM+53039326,re,r,rp,1-turnp,0) end
end
-- 检索目标的筛选条件：必须是怪兽、字段为「核成」（0x1d）、且能够被加入手卡。
function c53039326.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1d) and c:IsAbleToHand()
end
-- 检索效果的发动条件与操作信息设置：chk==0时确认卡组存在至少1只符合条件的「核成」怪兽；然后设置本连锁将执行“从卡组把1张卡加入手卡”的操作。
function c53039326.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时，检查卡组是否存在满足filter的「核成」怪兽，若不存在则检索效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c53039326.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明本效果处理时将从卡组把1张卡加入手卡（目标玩家为tp，区域为卡组，具体卡在效果处理时选择），供其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理：提示tp选择，从卡组选出1只符合条件的「核成」怪兽，将其加入卡片的原本持有者手卡，然后向对方展示确认。
function c53039326.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示提示“请选择要加入手卡的卡”，并设置选择卡片时的提示缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让tp从自己的卡组选择1张满足filter的「核成」怪兽（不取对象，在处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c53039326.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其原本持有者手卡（player为nil表示回到持有者手卡），实现“原本持有者从卡组加入手卡”。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
