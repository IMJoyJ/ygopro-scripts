--ジャイアント・ミミグル
-- 效果：
-- 1星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1张「迷拟宝箱鬼」卡加入手卡。
-- ②：只要对方场上有里侧表示怪兽存在，超量怪兽以外的自己的「迷拟宝箱鬼」怪兽可以直接攻击。
-- ③：把这张卡1个超量素材取除，以最多有对方场上的里侧表示怪兽数量的场上的表侧表示卡为对象才能发动。那些卡破坏，给与对方破坏数量×1000伤害。
local s,id,o=GetID()
-- 初始化效果函数，添加超量召唤手续、启用复活限制，并注册三个效果
function s.initial_effect(c)
	-- 为该卡添加超量召唤手续，使用1星怪兽2只进行叠放
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
-- 判断对方场上是否存在里侧表示的怪兽
function s.dircon(e)
	-- 检查对方场上是否存在至少1只里侧表示的怪兽
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil,POS_FACEDOWN_DEFENSE)
end
-- 设置效果目标，筛选自己场上的「迷拟宝箱鬼」非超量怪兽
function s.dirtg(e,c)
	return c:IsSetCard(0x1b7) and not c:IsType(TYPE_XYZ)
end
-- 判断此卡是否为超量召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 检索过滤器，筛选「迷拟宝箱鬼」卡且能加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1b7) and c:IsAbleToHand()
end
-- 设置检索效果的处理信息，确定要检索的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即卡组中是否存在符合条件的「迷拟宝箱鬼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的处理信息，指定检索卡牌数量和位置
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张符合条件的「迷拟宝箱鬼」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 破坏效果的费用处理函数，移除1个超量素材
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 破坏效果的目标选择函数，根据对方里侧怪兽数量选择目标卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取对方场上里侧表示怪兽数量
	local ct=Duel.GetMatchingGroupCount(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEDOWN_DEFENSE)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 检查是否满足破坏效果发动条件，即对方场上有里侧怪兽且场上存在可破坏的表侧表示卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多对方里侧怪兽数量的场上表侧表示卡作为破坏对象
	local sg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置破坏效果的处理信息，指定破坏卡牌数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置伤害效果的处理信息，指定给与对方的伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,sg:GetCount()*1000)
end
-- 破坏效果的处理函数，执行破坏并造成伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡组，并筛选与当前效果相关的卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡组破坏
		local dp=Duel.Destroy(tg,REASON_EFFECT)
		-- 给与对方破坏数量×1000的伤害
		Duel.Damage(1-tp,dp*1000,REASON_EFFECT)
	end
end
