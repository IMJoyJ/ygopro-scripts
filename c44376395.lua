--ASHLAN－U１０００型
-- 效果：
-- 种族·属性不同的怪兽2只
-- 这张卡所连接区的仪式怪兽向守备表示怪兽攻击的场合，给与对方攻击力超过那个守备力数值的战斗伤害。
-- 「阿修LAN U1000」的以下效果1回合各能使用1次。
-- 可以把手卡1只仪式怪兽给对方出示；从卡组把和出示怪兽种族·属性不同的1只仪式怪兽加入手卡。
-- 自己仪式召唤的场合（伤害步骤除外）：可以以对方场上1张表侧表示卡为对象；那张卡回到手卡。
local s,id,o=GetID()
-- 定义initial_effect函数，用于初始化卡片效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，需要种族和属性不同的两只怪兽作为素材。
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	-- 创建EFFECT_TYPE_FIELD类型的效果，设置EFFECT_PIERCE（贯穿伤害），作用范围为怪兽区，目标为连接区的仪式怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.piercetg)
	c:RegisterEffect(e1)
	-- 创建起动效果，检索手牌或卡组中的仪式怪兽，类别为CATEGORY_TOHAND和CATEGORY_SEARCH。
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
	-- 创建诱发选发效果，当自己仪式召唤成功时，将对方场上的一张表侧表示卡送回手牌，类别为CATEGORY_TOHAND。
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
-- 定义lcheck函数，用于检查连接素材是否满足种族和属性不同的条件。
function s.lcheck(g)
	-- 返回not aux.SameValueCheck(g,Card.GetLinkRace) and not aux.SameValueCheck(g,Card.GetLinkAttribute)，判断连接素材的种族和属性是否都不同。
	return not aux.SameValueCheck(g,Card.GetLinkRace) and not aux.SameValueCheck(g,Card.GetLinkAttribute)
end
-- 定义piercetg函数，用于确定贯穿伤害的目标怪兽。
function s.piercetg(e,c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 定义thfilter函数，用于过滤可以加入手牌的仪式怪兽。
function s.thfilter(c,race,att)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsAbleToHand() and c:GetRace()~=race and c:GetAttribute()~=att
end
-- 定义costfilter函数，用于过滤可以给对方展示的手卡中的仪式怪兽。
function s.costfilter(c,tp)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and not c:IsPublic()
		-- 判断是否存在满足条件的卡片，即种族和属性与当前卡不同的仪式怪兽。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetRace(),c:GetAttribute())
end
-- 定义thcost函数，设置检索效果的代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否有符合条件的仪式怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要给对方确认的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张满足条件的卡片并将其种族和属性记录到效果标签上。
	local tc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetRace(),tc:GetAttribute())
	-- 确认选中的卡片。
	Duel.ConfirmCards(1-tp,tc)
	-- 洗切手牌。
	Duel.ShuffleHand(tp)
end
-- 定义thtg函数，设置检索效果的目标。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为CATEGORY_TOHAND，表示从卡组加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义thop函数，执行检索效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local race,att=e:GetLabel()
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 根据标签中的种族和属性过滤卡组，并让玩家选择一张卡片。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,race,att)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义cthfilter函数，用于判断怪兽是否为自己的召唤且是仪式召唤。
function s.cthfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 定义cthcon函数，设置返回手牌效果的触发条件。
function s.cthcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cthfilter,1,nil,tp)
end
-- 定义cthtg函数，设置返回手牌效果的目标。
function s.cthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsAbleToHand() end
	-- 检查目标卡片是否在场上、属于对方、表侧表示且可以送回手牌。
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择一张满足条件的卡片作为目标。
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为CATEGORY_TOHAND，表示将目标卡片送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义cthop函数，执行返回手牌效果。
function s.cthop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 如果目标卡片与连锁有关联，则将其送回手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
