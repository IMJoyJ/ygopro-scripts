--ASHLAN U1000
-- 效果：
-- 种族·属性不同的怪兽2只
-- 这张卡所连接区的仪式怪兽向守备表示怪兽攻击的场合，给与对方攻击力超过那个守备力数值的战斗伤害。
-- 「阿修LAN U1000」的以下效果1回合各能使用1次。
-- 可以把手卡1只仪式怪兽给对方出示；从卡组把和出示怪兽种族·属性不同的1只仪式怪兽加入手卡。
-- 自己仪式召唤的场合（伤害步骤除外）：可以以对方场上1张表侧表示卡为对象；那张卡回到手卡。
local s,id,o=GetID()
-- 初始化效果函数，设置连接召唤手续并注册3个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要2只连接素材，且连接素材的种族和属性不能全部相同
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	-- 这张卡所连接区的仪式怪兽向守备表示怪兽攻击的场合，给与对方攻击力超过那个守备力数值的战斗伤害
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.piercetg)
	c:RegisterEffect(e1)
	-- 可以把手卡1只仪式怪兽给对方出示；从卡组把和出示怪兽种族·属性不同的1只仪式怪兽加入手卡
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
	-- 自己仪式召唤的场合（伤害步骤除外）：可以以对方场上1张表侧表示卡为对象；那张卡回到手卡
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
-- 连接素材的种族和属性不能全部相同
function s.lcheck(g)
	-- 连接素材的种族和属性不能全部相同
	return not aux.SameValueCheck(g,Card.GetLinkRace) and not aux.SameValueCheck(g,Card.GetLinkAttribute)
end
-- 设置贯穿伤害效果的目标为连接区的仪式怪兽
function s.piercetg(e,c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 检索过滤器，筛选种族和属性与给定值不同的仪式怪兽
function s.thfilter(c,race,att)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsAbleToHand() and c:GetRace()~=race and c:GetAttribute()~=att
end
-- 消耗过滤器，筛选手卡中未公开的仪式怪兽，并确保卡组中有符合条件的检索对象
function s.costfilter(c,tp)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and not c:IsPublic()
		-- 确保卡组中有种族和属性与所选怪兽不同的仪式怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetRace(),c:GetAttribute())
end
-- 设置检索效果的消耗，选择手卡中的仪式怪兽并确认给对方观看
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足消耗条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足消耗条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetRace(),tc:GetAttribute())
	-- 向对方确认所选怪兽
	Duel.ConfirmCards(1-tp,tc)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
end
-- 设置检索效果的目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，从卡组选择符合条件的怪兽加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local race,att=e:GetLabel()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足检索条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,race,att)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤器，筛选自己仪式召唤的怪兽
function s.cthfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 条件函数，判断是否有自己仪式召唤成功的怪兽
function s.cthcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cthfilter,1,nil,tp)
end
-- 设置返回手牌效果的目标
function s.cthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsAbleToHand() end
	-- 检查是否存在满足目标条件的卡
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足目标条件的卡
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置返回手牌效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行返回手牌效果，将目标卡送回手牌
function s.cthop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
