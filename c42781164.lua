--キラーチューン・トラックメイカー
-- 效果：
-- 「杀手级调整曲」调整＋调整1只以上
-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「杀手级调整曲」卡加入手卡。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。对方场上1张卡回到手卡。
local s,id,o=GetID()
-- 初始化效果函数，设置同调召唤手续、特殊召唤限制和三个效果
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求满足条件的调整怪兽作为同调素材
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1d5),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	-- 效果原文：场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCondition(s.syncon)
	e1:SetCode(EFFECT_HAND_SYNCHRO)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.tfilter)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡特殊召唤的场合才能发动。从卡组把1张「杀手级调整曲」卡加入手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 效果原文：②：这张卡作为同调素材送去墓地的场合才能发动。对方场上1张卡回到手卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回手效果"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.rthcon)
	e3:SetTarget(s.rthtg)
	e3:SetOperation(s.rthop)
	c:RegisterEffect(e3)
	s.killer_tune_be_material_effect=e3
	-- 效果原文：这个卡名的①②的效果1回合各能使用1次
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(21142671)
	c:RegisterEffect(e4)
end
-- 过滤函数，判断目标怪兽是否为调整类型
function s.tfilter(e,c)
	return c:IsSynchroType(TYPE_TUNER)
end
-- 条件函数，判断该卡是否在主要怪兽区
function s.syncon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 检索过滤函数，判断目标卡是否为杀手级调整曲且能加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1d5) and c:IsAbleToHand()
end
-- 设置检索效果的处理信息，确定要检索的卡组中的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的处理信息，指定要处理的卡为卡组中的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，选择并把卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 条件函数，判断该卡是否在墓地且因同调召唤而成为素材
function s.rthcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 设置回手效果的处理信息，确定要处理的对方场上的卡
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足回手条件，即对方场上是否存在能送回手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置回手效果的处理信息，指定要处理的卡为对方场上的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
-- 回手效果的处理函数，选择并把卡送回手牌
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的对方场上的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示被选为对象的卡
		Duel.HintSelection(g)
		-- 将选中的卡送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
