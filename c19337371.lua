--ヒステリック・サイン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：作为这张卡的发动时的效果处理，从自己的卡组·墓地把1张「万华镜-华丽的分身-」加入手卡。
-- ②：这张卡从手卡·场上送去墓地的回合的结束阶段发动。从卡组把最多3张「鹰身」卡加入手卡（同名卡最多1张）。
function c19337371.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：作为这张卡的发动时的效果处理，从自己的卡组·墓地把1张「万华镜-华丽的分身-」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19337371)
	e1:SetTarget(c19337371.target)
	e1:SetOperation(c19337371.activate)
	c:RegisterEffect(e1)
	-- 这张卡从手卡·场上送去墓地的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c19337371.regcon)
	e2:SetOperation(c19337371.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡从手卡·场上送去墓地的回合的结束阶段发动。从卡组把最多3张「鹰身」卡加入手卡（同名卡最多1张）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19337371,0))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1,19337371)
	e3:SetCondition(c19337371.thcon)
	e3:SetTarget(c19337371.thtg)
	e3:SetOperation(c19337371.thop)
	c:RegisterEffect(e3)
end
-- 定义①的检索过滤条件：对象必须是卡号90219263的「万华镜-华丽的分身-」，且能够加入手卡。
function c19337371.filter(c)
	return c:IsCode(90219263) and c:IsAbleToHand()
end
-- ①的发动条件与操作信息登记：检查自己的卡组·墓地是否存在符合条件的「万华镜」，若存在则允许发动，并登记为从卡组·墓地检索1张加入手卡的处理。
function c19337371.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：己方卡组·墓地中必须至少存在1张满足 c19337371.filter 的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c19337371.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 向系统登记本次连锁为“加入手卡”类操作，目标暂不指定，数量1，来源位置为卡组·墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- ①的效果处理：从己方卡组·墓地选择1张满足条件且不受王家长眠之谷影响的「万华镜-华丽的分身-」加入手卡，并向对方展示确认。
function c19337371.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选择提示并写入选择缓存，作为选卡界面的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方玩家从自己的卡组·墓地中挑选1张同时满足 c19337371.filter 且不受王家长眠之谷影响的卡，作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19337371.filter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- e2的触发条件：本卡被送去墓地前位于手牌或场上，用于确认满足②“从手卡·场上送去墓地”的前提。
function c19337371.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 满足条件时给本卡登记编号19337371的标志；该标志随标准重置事件或结束阶段清除，用于标记本回合曾从手牌·场上送去墓地。
function c19337371.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(19337371,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 定义②的检索过滤条件：对象必须是「鹰身」系列（0x64）的卡，且能够加入手卡。
function c19337371.thfilter(c)
	return c:IsSetCard(0x64) and c:IsAbleToHand()
end
-- e3的发动条件：本卡带有19337371标志，即本回合确实从手牌·场上送去过墓地。
function c19337371.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(19337371)>0
end
-- ②的目标判定与操作信息登记：真正的前置条件由 thcon 控制，这里直接允许发动，并登记为从卡组加入手卡的效果。
function c19337371.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本次连锁为“从卡组检索卡加入手卡”类操作，预计数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②的效果处理：从己方卡组筛选所有符合条件的「鹰身」卡，玩家选择1~3张卡名互不相同的卡加入手卡并让对方确认；若无候选则终止处理。
function c19337371.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方卡组中所有满足 c19337371.thfilter 的「鹰身」卡作为候选集合。
	local g=Duel.GetMatchingGroup(c19337371.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()==0 then return end
	-- 弹出“请选择要加入手牌的卡”的选择提示并写入选择缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从候选集合中选出1~3张卡，并通过 aux.dncheck 保证所选卡的卡名互不相同，实现“同名卡最多1张”的限制。
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,1,3)
	-- 将选出的「鹰身」卡以效果原因加入其持有者的手卡。
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	-- 将实际加入手卡的「鹰身」卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g1)
end
