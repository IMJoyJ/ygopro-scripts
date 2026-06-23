--憑依装着－ライナ
-- 效果：
-- ①：这张卡可以把自己场上的表侧表示的1只「光灵使 莱娜」和1只光属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤时才能发动。从卡组把「凭依装着-莱娜」以外的1只守备力1500的魔法师族怪兽加入手卡。
-- ③：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c40542825.initial_effect(c)
	-- ①：这张卡可以把自己场上的表侧表示的1只「光灵使 莱娜」和1只光属性怪兽送去墓地，从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(c40542825.spcon)
	e1:SetTarget(c40542825.sptg)
	e1:SetOperation(c40542825.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤时才能发动。从卡组把「凭依装着-莱娜」以外的1只守备力1500的魔法师族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40542825,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c40542825.condition)
	e2:SetTarget(c40542825.thtg)
	e2:SetOperation(c40542825.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡的①的方法特殊召唤的这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetCondition(c40542825.condition)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的场上表侧表示怪兽，用于特殊召唤的条件检查
function c40542825.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 检查所选的两张怪兽是否满足「光灵使 莱娜」和光属性的组合要求
function c40542825.fselect(g,tp)
	-- 检查所选的两张怪兽是否满足「光灵使 莱娜」和光属性的组合要求
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsCode,73318863,Card.IsAttribute,ATTRIBUTE_LIGHT)
end
-- 判断是否满足特殊召唤的条件，即场上有满足条件的两张怪兽
function c40542825.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c40542825.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c40542825.fselect,2,2,tp)
end
-- 选择满足条件的两张怪兽并将其送去墓地
function c40542825.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c40542825.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c40542825.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将选择的怪兽组送去墓地
function c40542825.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽组送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤满足条件的魔法师族守备力为1500的怪兽
function c40542825.thfilter(c)
	return c:IsDefense(1500) and c:IsRace(RACE_SPELLCASTER) and not c:IsCode(40542825) and c:IsAbleToHand()
end
-- 判断该卡是否为通过①的方法特殊召唤
function c40542825.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 设置检索效果的处理信息
function c40542825.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c40542825.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 选择满足条件的怪兽并加入手牌
function c40542825.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c40542825.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
