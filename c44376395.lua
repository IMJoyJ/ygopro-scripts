--ASHLAN－U１０００型
-- 效果：
-- 种族和属性不同的怪兽2只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡所连接区的仪式怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：把手卡1只仪式怪兽给对方观看才能发动。和给人观看的怪兽种族和属性不同的1只仪式怪兽从卡组加入手卡。
-- ③：自己把怪兽仪式召唤的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果：设置苏生限制，添加连接召唤手续（2只满足种族和属性不同条件的怪兽），并注册三个效果——①所连接区仪式怪兽的贯穿伤害永续效果、②展示手卡仪式怪兽检索仪式怪兽的起动效果、③自己仪式召唤成功时将对方场上表侧表示卡回到手卡的诱发选发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：用2只满足lcheck条件（种族和属性互不相同）的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	-- ①：这张卡所连接区的仪式怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.piercetg)
	c:RegisterEffect(e1)
	-- ②：把手卡1只仪式怪兽给对方观看才能发动。和给人观看的怪兽种族和属性不同的1只仪式怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：自己把怪兽仪式召唤的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.cthcon)
	e3:SetTarget(s.cthtg)
	e3:SetOperation(s.cthop)
	c:RegisterEffect(e3)
end
-- 连接素材检查函数：判断选中的一组连接素材是否种族和属性互不相同
function s.lcheck(g)
	-- 检查素材组中不存在所有卡片共有的种族，也不存在所有卡片共有的属性（即种族和属性各不相同）
	return not aux.SameValueCheck(g,Card.GetLinkRace) and not aux.SameValueCheck(g,Card.GetLinkAttribute)
end
-- 贯穿效果的作用对象过滤：这张卡所连接区的仪式怪兽获得贯穿伤害效果
function s.piercetg(e,c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 检索目标过滤函数：卡组中可以加入手卡、且种族和属性与展示的怪兽均不同的仪式怪兽
function s.thfilter(c,race,att)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsAbleToHand() and c:GetRace()~=race and c:GetAttribute()~=att
end
-- 代价支付用过滤函数：手卡中未公开、且卡组中存在与其种族和属性均不同的仪式怪兽的仪式怪兽
function s.costfilter(c,tp)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and not c:IsPublic()
		-- 检查卡组中是否存在与该卡种族和属性均不同、可以加入手卡的仪式怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetRace(),c:GetAttribute())
end
-- 代价处理：从手卡选择1只满足条件的仪式怪兽给对方观看，记录其种族和属性，然后洗切手卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以给对方观看的仪式怪兽（能否支付代价）
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择1张要给对方确认的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1只满足条件的仪式怪兽作为要展示的卡
	local tc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetRace(),tc:GetAttribute())
	-- 把选择的仪式怪兽给对方观看确认
	Duel.ConfirmCards(1-tp,tc)
	-- 洗切自己的手卡
	Duel.ShuffleHand(tp)
end
-- 检索效果的发动目标处理：效果必定可以发动，并设置从卡组将卡加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组将1张卡加入手卡（检索对象在效果处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：取得代价阶段记录的种族和属性，从卡组选择1只与其不同的仪式怪兽加入手卡，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local race,att=e:GetLabel()
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只种族和属性与展示的怪兽均不同的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,race,att)
	if g:GetCount()>0 then
		-- 将选择的仪式怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 仪式召唤触发条件过滤：是自己进行仪式召唤出场的怪兽
function s.cthfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果发动条件：特殊召唤成功的怪兽中存在自己仪式召唤的怪兽
function s.cthcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cthfilter,1,nil,tp)
end
-- 回到手卡效果的目标处理：以对方场上1张表侧表示、可以回到手卡的卡为对象
function s.cthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在表侧表示且可以回到手卡的卡（能否取对象发动）
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要回到手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 以对方场上1张表侧表示、可以回到手卡的卡为对象
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将对象的1张卡回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回到手卡效果处理：取得作为对象的卡，若其仍与本连锁相关则将其回到手卡
function s.cthop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象的卡回到持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
