--超弩級砲塔列車フライング・ランチャー
-- 效果：
-- 10星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1只机械族·地属性怪兽或1张「扫射特攻」加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只机械族怪兽召唤。
-- ③：把这张卡的超量素材任意数量取除，以那个数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果
function s.initial_effect(c)
	-- 为卡片添加代码列表，记录「扫射特攻」卡号
	aux.AddCodeList(c,51369889)
	-- 设置XYZ召唤程序，需要10星且叠放2只怪兽
	aux.AddXyzProcedure(c,nil,10,2)
	c:EnableReviveLimit()
	-- 效果①：超量召唤成功时发动，检索满足条件的机械族地属性怪兽或「扫射特攻」加入手牌
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 效果②：只要此卡在场，自己主要阶段可以额外召唤1只机械族怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"使用「超重型炮塔列车 冲天火箭炮」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置效果②的目标为机械族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_MACHINE))
	c:RegisterEffect(e2)
	-- 效果③：将此卡超量素材取除，破坏场上的魔法·陷阱卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：此卡为XYZ召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 检索过滤器函数，筛选机械族地属性怪兽或「扫射特攻」
function s.thfilter(c)
	return (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) or c:IsCode(51369889)) and c:IsAbleToHand()
end
-- 效果①的发动时的处理函数，检查是否有满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否卡组存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果①的处理信息，准备将卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动效果处理函数，选择并送入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③的发动费用处理函数，移除1个以上超量素材
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 获取场上的魔法·陷阱卡数量用于计算可移除的素材数
	local rt=Duel.GetTargetCount(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
-- 效果③的发动时处理函数，选择破坏的魔法·陷阱卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=e:GetLabel()
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查场上是否存在魔法·陷阱卡作为目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择破坏对象的魔法·陷阱卡
	local tg=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置效果③的处理信息，准备破坏卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,ct,0,0)
end
-- 效果③的发动效果处理函数，破坏选中的卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选中的卡，并过滤出与连锁相关的场上卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.AND(Card.IsRelateToChain,Card.IsOnField),nil)
	if g:GetCount()>0 then
		-- 将符合条件的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
