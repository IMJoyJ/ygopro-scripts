--超念銃士ヴァロン
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ②：这张卡被送去墓地的场合，以场上1张里侧表示卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化卡片的核心函数：为卡添加超量召唤手续和苏生限制，然后注册两个效果e1（①的变为里侧守备表示效果）和e2（②的破坏里侧表示卡效果），两个效果分别通过CountLimit限定为每回合各1次，且分别使用不同的计数码保证各自独立。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用任意2只等级5的怪兽叠放来超量召唤（素材数量2）。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成里侧表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.poscon)
	e1:SetCost(s.poscost)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以场上1张里侧表示卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定函数：仅在主要阶段（自己或对方的主要阶段）才能发动。
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段，是则返回true，满足发动时点条件。
	return Duel.IsMainPhase()
end
-- ①效果的发动代价：取除这张卡的1个超量素材作为发动代价；chk==0时只检查能否取除，实际发动时执行取除操作。
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的取对象筛选条件：对方场上的表侧表示怪兽，且该怪兽可以变为里侧表示。
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ①效果的取对象合法性判定：若在连锁处理时指定了对象chkc，则必须满足位于主要怪兽区、是对方表侧表示且可变为里侧守备表示。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc)
		and chkc:IsControler(1-tp) end
	-- 发动时点检查：对方场上是否存在至少1只满足posfilter条件的表侧表示怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示选择提示“请选择表侧表示的卡”，等待玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只满足posfilter条件的表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：该操作包含改变表示形式（CATEGORY_POSITION）和盖放怪兽（CATEGORY_MSET），对象为选择的g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①效果的处理：取得对象怪兽，若该怪兽仍在场上且与本次连锁相关且仍为表侧表示，则将其变为里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的效果对象（第一张目标卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将目标怪兽的表示形式变为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- ②效果的发动判定和目标选择函数：选择场上1张里侧表示卡作为对象，若对象不合法或场上没有里侧表示卡则不能发动。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFacedown() end
	-- 发动时点检查：场上（双方怪兽区+魔法陷阱区）是否存在至少1张里侧表示的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作者显示选择提示“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上双方区域选择1张里侧表示的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息：该操作包含破坏效果（CATEGORY_DESTROY），对象为选择的g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理：取得对象卡，若该卡仍与本次连锁有联系（没有离场或无效化），则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的效果对象（要破坏的里侧表示卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象卡以效果原因（REASON_EFFECT）破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
