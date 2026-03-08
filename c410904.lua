--憑依覚醒－ラセンリュウ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以把自己场上的表侧表示的1只魔法师族怪兽和1只4星以下的风属性怪兽送去墓地，从手卡·卡组特殊召唤。
-- ②：这张卡的①的方法特殊召唤时才能发动。对方场上1张卡回到手卡。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「风灵术」卡或「凭依」魔法·陷阱卡加入手卡。
function c410904.initial_effect(c)
	-- ①：这张卡可以把自己场上的表侧表示的1只魔法师族怪兽和1只4星以下的风属性怪兽送去墓地，从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(c410904.spcon)
	e1:SetTarget(c410904.sptg)
	e1:SetOperation(c410904.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤时才能发动。对方场上1张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(410904,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,410904)
	e2:SetCondition(c410904.condition)
	e2:SetTarget(c410904.rthtg)
	e2:SetOperation(c410904.rthop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「风灵术」卡或「凭依」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(410904,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,410905)
	e3:SetCondition(c410904.thcon)
	e3:SetTarget(c410904.thtg)
	e3:SetOperation(c410904.thop)
	c:RegisterEffect(e3)
end
-- 筛选场上表侧表示且能送入墓地的怪兽
function c410904.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 筛选风属性且等级4以下的怪兽
function c410904.spfilter2(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelBelow(4)
end
-- 组合筛选函数，检查所选怪兽组是否满足魔法师族和风属性4星以下的条件
function c410904.fselect(g,tp)
	-- 检查所选怪兽组是否满足魔法师族和风属性4星以下的条件
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsRace,RACE_SPELLCASTER,c410904.spfilter2,nil)
end
-- 判断特殊召唤条件是否满足，即场上有符合条件的2只怪兽
function c410904.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有可送入墓地的怪兽
	local g=Duel.GetMatchingGroup(c410904.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c410904.fselect,2,2,tp)
end
-- 设置特殊召唤时的选择目标，选择符合条件的2只怪兽
function c410904.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上所有可送入墓地的怪兽
	local g=Duel.GetMatchingGroup(c410904.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c410904.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的送墓操作
function c410904.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽送入墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否为通过①效果特殊召唤
function c410904.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 设置效果②的处理目标，选择对方场上的1张卡
function c410904.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可送回手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置效果②的处理信息，指定要送回手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
-- 执行效果②，选择对方场上的1张卡送回手牌
function c410904.rthop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的1张可送回手牌的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 判断是否为从场上送去墓地
function c410904.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选「风灵术」或「凭依」魔法·陷阱卡
function c410904.thfilter(c)
	return ((c:IsSetCard(0xc0) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsSetCard(0x914c)) and c:IsAbleToHand()
end
-- 设置效果③的处理目标，从卡组检索符合条件的卡
function c410904.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c410904.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果③的处理信息，指定要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果③，从卡组检索并加入手牌
function c410904.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择符合条件的卡
	local g=Duel.SelectMatchingCard(tp,c410904.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
