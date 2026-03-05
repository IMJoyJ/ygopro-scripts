--憑依装着－ダルク
-- 效果：
-- 可以把自己场上1只「暗灵使 达克」和1只暗属性怪兽送去墓地，从手卡·卡组特殊召唤。这个方法特殊召唤成功时，可以从卡组把1只3星或者4星的魔法师族·光属性怪兽加入手卡。此外，这个方法特殊召唤的这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c21390858.initial_effect(c)
	-- 效果原文：可以把自己场上1只「暗灵使 达克」和1只暗属性怪兽送去墓地，从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(c21390858.spcon)
	e1:SetTarget(c21390858.sptg)
	e1:SetOperation(c21390858.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 效果原文：这个方法特殊召唤成功时，可以从卡组把1只3星或者4星的魔法师族·光属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21390858,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c21390858.condition)
	e2:SetTarget(c21390858.target)
	e2:SetOperation(c21390858.operation)
	c:RegisterEffect(e2)
	-- 效果原文：此外，这个方法特殊召唤的这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetCondition(c21390858.condition)
	c:RegisterEffect(e3)
end
-- 检索满足条件的怪兽区怪兽，用于特殊召唤的条件判断
function c21390858.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 检查所选的2张怪兽是否满足「暗灵使 达克」和暗属性的组合要求
function c21390858.fselect(g,tp)
	-- 检查所选的2张怪兽是否满足「暗灵使 达克」和暗属性的组合要求
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsCode,19327348,Card.IsAttribute,ATTRIBUTE_DARK)
end
-- 判断是否满足特殊召唤的条件，即场上有满足条件的2张怪兽
function c21390858.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c21390858.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c21390858.fselect,2,2,tp)
end
-- 选择满足条件的2张怪兽进行特殊召唤
function c21390858.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c21390858.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c21390858.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的处理，将选中的怪兽送去墓地
function c21390858.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 检索满足条件的魔法师族·光属性·3星或4星怪兽
function c21390858.tfilter(c)
	return c:IsLevel(3,4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 判断该卡是否为通过特殊召唤方式出场
function c21390858.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 设置检索效果的目标
function c21390858.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，即卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21390858.tfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，选择并加入手牌
function c21390858.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,c21390858.tfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
