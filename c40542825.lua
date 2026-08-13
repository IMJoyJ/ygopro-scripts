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
-- 定义素材过滤条件：怪兽须表侧表示，且可以作为cost送去墓地。
function c40542825.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 定义素材组合合法性判定：所选2张素材送入墓地后己方仍有空余怪兽区域，且组合中一张是「光灵使 莱娜」（卡号73318863），另一张是光属性怪兽。
function c40542825.fselect(g,tp)
	-- 验证素材组同时满足“送入墓地后空位检查”和“一张光灵使莱娜、一张光属性怪兽”的组合条件。
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsCode,73318863,Card.IsAttribute,ATTRIBUTE_LIGHT)
end
-- 特殊召唤规则条件：若询问对象为nil则直接允许；否则检查己方场上是否存在满足条件的2张素材组合。
function c40542825.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得己方场上所有可作为素材的怪兽（表侧表示且能作为cost送墓）。
	local g=Duel.GetMatchingGroup(c40542825.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c40542825.fselect,2,2,tp)
end
-- 特殊召唤规则的目标选择：让玩家从候选素材中选择2张，选中后保留为效果标签以供处理时送墓，若取消则本次特殊召唤不进行。
function c40542825.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得己方场上所有可作为素材的怪兽，供玩家选择。
	local g=Duel.GetMatchingGroup(c40542825.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 向玩家显示“请选择要送去墓地的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c40542825.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的实际处理：将保存的2张素材怪兽送去墓地，完成召唤手续。
function c40542825.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以“特殊召唤”为原因将选中的素材怪兽送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 定义检索目标：守备力1500的魔法师族怪兽、卡名不是「凭依装着-莱娜」且可以加入手卡。
function c40542825.thfilter(c)
	return c:IsDefense(1500) and c:IsRace(RACE_SPELLCASTER) and not c:IsCode(40542825) and c:IsAbleToHand()
end
-- 判断此卡是否通过①的方法（即由自身规则效果）特殊召唤成功，作为后续检索和贯穿伤害效果的条件。
function c40542825.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 检索效果发动条件：卡组中存在符合条件的怪兽；同时设置操作信息为从卡组将1张卡加入手卡。
function c40542825.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法确认阶段检查卡组中是否存在1张符合条件的检索目标。
	if chk==0 then return Duel.IsExistingMatchingCard(c40542825.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：选择1张符合条件的守备力1500魔法师族怪兽加入手卡，并向对方确认。
function c40542825.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合过滤条件（守备力1500魔法师族、非本卡、可加入手卡）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c40542825.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
