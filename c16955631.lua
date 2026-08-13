--ジャイアント・ミミグル
-- 效果：
-- 1星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1张「迷拟宝箱鬼」卡加入手卡。
-- ②：只要对方场上有里侧表示怪兽存在，超量怪兽以外的自己的「迷拟宝箱鬼」怪兽可以直接攻击。
-- ③：把这张卡1个超量素材取除，以最多有对方场上的里侧表示怪兽数量的场上的表侧表示卡为对象才能发动。那些卡破坏，给与对方破坏数量×1000伤害。
local s,id,o=GetID()
-- 初始化怪兽效果：设置1星×2的超量召唤手续和苏生限制，并注册②直接攻击、①超量召唤时检索、③取除素材破坏并给予伤害三个效果，且①③各自1回合1次。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用2只1星怪兽叠放进行超量召唤（不限制素材种族/属性/卡名）。
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- ②：只要对方场上有里侧表示怪兽存在，超量怪兽以外的自己的「迷拟宝箱鬼」怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.dircon)
	e1:SetTarget(s.dirtg)
	c:RegisterEffect(e1)
	-- ①：这张卡超量召唤的场合才能发动。从卡组把1张「迷拟宝箱鬼」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：把这张卡1个超量素材取除，以最多有对方场上的里侧表示怪兽数量的场上的表侧表示卡为对象才能发动。那些卡破坏，给与对方破坏数量×1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 直接攻击效果的适用条件：对方场上存在里侧守备表示怪兽时才允许直接攻击。
function s.dircon(e)
	-- 检查对方场上是否存在至少1只里侧守备表示的怪兽。
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil,POS_FACEDOWN_DEFENSE)
end
-- 直接攻击效果的适用对象过滤：仅限自己场上卡名属于「迷拟宝箱鬼」且不是超量怪兽的怪兽获得直接攻击能力。
function s.dirtg(e,c)
	return c:IsSetCard(0x1b7) and not c:IsType(TYPE_XYZ)
end
-- ①效果的发动条件：这张卡以超量召唤方式特殊召唤成功。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 检索的卡片过滤条件：卡名属于「迷拟宝箱鬼」字段且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1b7) and c:IsAbleToHand()
end
-- ①效果的目标操作：发动时检查卡组是否存在可检索的「迷拟宝箱鬼」卡，并设置将1张卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：自己卡组中存在至少1张符合检索过滤条件的「迷拟宝箱鬼」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：效果处理时从己方卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：选择1张符合条件的「迷拟宝箱鬼」卡加入手卡，并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选出1张符合s.thfilter过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动代价：作为cost从这张卡上取除1个超量素材；先检查是否有素材可取，实际处理时取除1个。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③效果的目标选择：以对方场上里侧守备表示怪兽数量为最大可选数，选择场上表侧表示卡为对象，并设置破坏和伤害的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算对方场上里侧守备表示怪兽的数量，作为可选的破坏对象数量上限。
	local ct=Duel.GetMatchingGroupCount(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEDOWN_DEFENSE)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 发动合法性检查：对方场上存在里侧守备表示怪兽（使数量上限至少为1）且场上存在可选的表侧表示卡。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，要求玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1到ct张表侧表示卡作为效果对象，并登记为当前连锁的对象。
	local sg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息：本次效果将破坏选择的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置操作信息：给对方造成对象数量×1000的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,sg:GetCount()*1000)
end
-- ③效果的处理：从连锁对象中取出仍与效果相关的表侧表示卡，全部破坏，并给与对方对应伤害。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡，并过滤出仍然与效果相关的卡（排除已被转移/离场导致联系重置的卡）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 用效果破坏这些对象卡，返回实际破坏数量。
		local dp=Duel.Destroy(tg,REASON_EFFECT)
		-- 给对方造成破坏数量×1000的效果伤害。
		Duel.Damage(1-tp,dp*1000,REASON_EFFECT)
	end
end
