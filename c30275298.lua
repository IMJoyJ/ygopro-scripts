--終撃竜－サイバー・エンド・ドラゴン
-- 效果：
-- 攻击力2100以上的机械族怪兽×3
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：只用光属性怪兽作为素材让这张卡融合召唤的场合，支付4000基本分才能发动。从卡组把1张「限制解除」加入手卡。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：持有比原本攻击力高的攻击力的这张卡在同1次的战斗阶段中可以作3次攻击。
local s,id,o=GetID()
-- 注册卡片效果及召唤手续的初始化函数。
function s.initial_effect(c)
	-- 将卡片「限制解除」的卡号（23171610）记录到本卡的关联卡片列表中。
	aux.AddCodeList(c,23171610)
	-- 注册需要3个满足过滤条件s.ffilter的怪兽作为融合素材的融合召唤手续。
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过融合召唤的方式进行特殊召唤。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：只用光属性怪兽作为素材让这张卡融合召唤的场合，支付4000基本分才能发动。从卡组把1张「限制解除」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ①：只用光属性怪兽作为素材让这张卡融合召唤的场合，支付4000基本分才能发动。从卡组把1张「限制解除」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
	-- ③：持有比原本攻击力高的攻击力的这张卡在同1次的战斗阶段中可以作3次攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EXTRA_ATTACK)
	e5:SetCondition(s.eacon)
	e5:SetValue(2)
	c:RegisterEffect(e5)
end
-- 融合素材的过滤条件：攻击力在2100以上的机械族怪兽。
function s.ffilter(c,fc)
	return c:IsAttackAbove(2100) and c:IsRace(RACE_MACHINE)
end
-- 检索效果的发动条件：本卡是由融合召唤特殊召唤，且融合素材全部为光属性怪兽（标记值为1）。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1 and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检索效果的Cost处理函数：检查并支付4000点基本分。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付4000点基本分的Cost。
	if chk==0 then return Duel.CheckLPCost(tp,4000) end
	-- 让玩家支付4000点基本分。
	Duel.PayLPCost(tp,4000)
end
-- 检索卡片的过滤条件：卡名为「限制解除」（卡号为23171610）且能加入手卡。
function s.thfilter(c)
	return c:IsCode(23171610) and c:IsAbleToHand()
end
-- 检索效果的Target处理函数：检查卡组是否存在「限制解除」并设置将卡片加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组中是否存在可以加入手牌的「限制解除」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的Operation处理函数：从卡组选择1张「限制解除」加入手牌并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方玩家从卡组选择1张满足过滤条件的「限制解除」。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 融合素材检查函数：检查融合素材是否全部为光属性，并将结果作为标记值（flag）设置到e2效果中。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	-- 检查融合素材是否存在且其中不存在非光属性的怪兽（即全部融合素材都是光属性）。
	if g:GetCount()>0 and not g:IsExists(aux.NOT(Card.IsFusionAttribute),1,nil,ATTRIBUTE_LIGHT) then
		flag=1
	end
	e:GetLabelObject():SetLabel(flag)
end
-- 追加攻击效果的发动条件：本卡的攻击力比原本攻击力高。
function s.eacon(e)
	local c=e:GetHandler()
	return c:GetAttack()>c:GetBaseAttack()
end
