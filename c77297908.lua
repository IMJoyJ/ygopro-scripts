--魔界劇場「ファンタスティックシアター」
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只「魔界剧团」灵摆怪兽和1张「魔界台本」魔法卡给对方观看才能发动。和给人观看的魔法卡卡名不同的1张「魔界台本」魔法卡从卡组加入手卡。
-- ②：只要灵摆召唤的「魔界剧团」灵摆怪兽在自己场上存在，对方发动的怪兽的效果变成「选对方场上盖放的1张魔法·陷阱卡破坏」。
function c77297908.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：把手卡1只「魔界剧团」灵摆怪兽和1张「魔界台本」魔法卡给对方观看才能发动。和给人观看的魔法卡卡名不同的1张「魔界台本」魔法卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77297908,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,77297908)
	e2:SetCost(c77297908.thcost)
	e2:SetTarget(c77297908.thtg)
	e2:SetOperation(c77297908.thop)
	c:RegisterEffect(e2)
	-- ②：只要灵摆召唤的「魔界剧团」灵摆怪兽在自己场上存在，对方发动的怪兽的效果变成「选对方场上盖放的1张魔法·陷阱卡破坏」。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,77297909)
	e4:SetCondition(c77297908.chcon)
	e4:SetOperation(c77297908.chop)
	c:RegisterEffect(e4)
end
-- 过滤手卡中未给对方观看的「魔界剧团」灵摆怪兽
function c77297908.cfilter(c)
	return c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and not c:IsPublic()
end
-- 过滤手卡中未给对方观看且卡组中存在同名卡以外的「魔界台本」魔法卡的「魔界台本」魔法卡
function c77297908.cfilter2(c,tp)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and not c:IsPublic()
		-- 检查卡组中是否存在与该卡卡名不同的「魔界台本」魔法卡
		and Duel.IsExistingMatchingCard(c77297908.cfilter3,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤卡组中与展示的魔法卡卡名不同且能加入手卡的「魔界台本」魔法卡
function c77297908.cfilter3(c,code)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and not c:IsCode(code) and c:IsAbleToHand()
end
-- 效果①的发动代价（Cost）处理函数
function c77297908.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手卡中是否存在可展示的「魔界剧团」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77297908.cfilter,tp,LOCATION_HAND,0,1,nil)
		-- 并检查手卡中是否存在可展示且能满足检索条件的「魔界台本」魔法卡
		and Duel.IsExistingMatchingCard(c77297908.cfilter2,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中1只满足条件的「魔界剧团」灵摆怪兽
	local g1=Duel.SelectMatchingCard(tp,c77297908.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 让玩家选择手卡中1张满足条件的「魔界台本」魔法卡
	local g2=Duel.SelectMatchingCard(tp,c77297908.cfilter2,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabel(g2:GetFirst():GetCode())
	g1:Merge(g2)
	-- 将选出的卡片给对方玩家确认
	Duel.ConfirmCards(1-tp,g1)
	-- 洗切玩家的手卡
	Duel.ShuffleHand(tp)
end
-- 效果①的效果目标（Target）处理函数
function c77297908.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，表示该效果的操作为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果运行（Operation）处理函数
function c77297908.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张与展示的魔法卡卡名不同的「魔界台本」魔法卡
	local g=Duel.SelectMatchingCard(tp,c77297908.cfilter3,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选取的卡片因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤自己场上表侧表示的灵摆召唤的「魔界剧团」灵摆怪兽
function c77297908.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsType(TYPE_PENDULUM)
end
-- 效果②的触发条件（Condition）判断函数
function c77297908.chcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER)
		-- 检查自己场上是否存在灵摆召唤的「魔界剧团」灵摆怪兽
		and Duel.IsExistingMatchingCard(c77297908.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的效果运行（Operation）处理函数
function c77297908.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 清空当前正在处理的连锁的效果对象
	Duel.ChangeTargetCard(ev,g)
	-- 将当前正在处理的连锁的效果处理函数替换为指定的破坏效果处理函数
	return Duel.ChangeChainOperation(ev,c77297908.repop)
end
-- 过滤场上盖放的魔法·陷阱卡
function c77297908.desfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 替换后的效果处理函数，即「选对方场上盖放的1张魔法·陷阱卡破坏」
function c77297908.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上显示本卡（魔界剧场「奇幻剧场」）的卡片发动动画
	Duel.Hint(HINT_CARD,0,77297908)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前回合玩家选择对方场上盖放的1张魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c77297908.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 在场上高亮显示被选择的卡片
		Duel.HintSelection(g)
		-- 将选中的卡片因效果破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
