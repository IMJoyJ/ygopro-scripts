--超弩級砲塔列車フライング・ランチャー
-- 效果：
-- 10星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1只机械族·地属性怪兽或1张「扫射特攻」加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只机械族怪兽召唤。
-- ③：把这张卡的超量素材任意数量取除，以那个数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 注册超量召唤成功时检索机械族·地属性怪兽或「扫射特攻」、增加机械族怪兽通常召唤机会、以及去除素材破坏魔陷的效果
function s.initial_effect(c)
	-- 向系统登记此卡关联「扫射特攻」（卡片密码：51369889）
	aux.AddCodeList(c,51369889)
	-- 注册卡片超量召唤的常规素材条件（10星怪兽2只）
	aux.AddXyzProcedure(c,nil,10,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。从卡组把1只机械族·地属性怪兽或1张「扫射特攻」加入手卡。
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
	-- ②：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只机械族怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"使用「超重型炮塔列车 冲天火箭炮」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 将额外召唤机会的限制条件设为机械族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_MACHINE))
	c:RegisterEffect(e2)
	-- ③：把这张卡的超量素材任意数量取除，以那个数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
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
-- 确认此卡是通过超量召唤的方式特殊召唤成功的
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 地属性·机械族怪兽或「扫射特攻」且能够加入手牌的卡片过滤条件
function s.thfilter(c)
	return (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) or c:IsCode(51369889)) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检查
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的怪兽或魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组把卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择需要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只地属性·机械族怪兽或1张「扫射特攻」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 去除任意数量的超量素材作为效果发动的代价
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 获取场上可作为对象的魔法·陷阱卡的总数，以此限制最大去除素材数
	local rt=Duel.GetTargetCount(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
-- 魔法·陷阱卡破坏效果的发动准备与对象选择
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=e:GetLabel()
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查场上是否存在可以被选择为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 向玩家发送提示，请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择与去除素材等量数量的魔法·陷阱卡作为破坏对象
	local tg=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置操作信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,ct,0,0)
end
-- 魔法·陷阱卡破坏效果的执行
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中关联且未受墓地无效影响的作为对象的卡片
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if g:GetCount()>0 then
		-- 破坏选中的魔法·陷阱卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
