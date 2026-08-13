--憑依装着－ダルク
-- 效果：
-- 可以把自己场上1只「暗灵使 达克」和1只暗属性怪兽送去墓地，从手卡·卡组特殊召唤。这个方法特殊召唤成功时，可以从卡组把1只3星或者4星的魔法师族·光属性怪兽加入手卡。此外，这个方法特殊召唤的这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c21390858.initial_effect(c)
	-- 可以把自己场上1只「暗灵使 达克」和1只暗属性怪兽送去墓地，从手卡·卡组特殊召唤。
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
	-- 这个方法特殊召唤成功时，可以从卡组把1只3星或者4星的魔法师族·光属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21390858,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c21390858.condition)
	e2:SetTarget(c21390858.target)
	e2:SetOperation(c21390858.operation)
	c:RegisterEffect(e2)
	-- 此外，这个方法特殊召唤的这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetCondition(c21390858.condition)
	c:RegisterEffect(e3)
end
-- 素材过滤：要求怪兽为表侧表示，且可以作为Cost送去墓地。
function c21390858.spfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 组合选择判定：确认选出的2张怪兽在送去墓地后自己场上仍有可用怪兽区；并且2张卡正好是1只「暗灵使 达克」和1只暗属性怪兽，顺序不限。
function c21390858.fselect(g,tp)
	-- 合并判定：素材送墓后仍有怪兽区空位，且素材组合满足“1只「暗灵使 达克」+1只暗属性怪兽”的要求。
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,Card.IsCode,19327348,Card.IsAttribute,ATTRIBUTE_DARK)
end
-- 特殊召唤规则效果的发动条件：当c为空时表示询问是否可进行规则召唤，返回true；否则检查自己场上是否存在满足素材条件的2张表侧卡。
function c21390858.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取可能作为素材的候选组：我方主要怪兽区上所有表侧表示且可作为Cost送去墓地的怪兽。
	local g=Duel.GetMatchingGroup(c21390858.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c21390858.fselect,2,2,tp)
end
-- 特殊召唤手续的Target：从候选素材中选择满足fselect的2张卡；选中后保存为LabelObject并返回true，否则不能发动。
function c21390858.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取候选素材组：我方怪兽区上表侧且可作为Cost送去墓地的怪兽（用于选择素材的操作）。
	local g=Duel.GetMatchingGroup(c21390858.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 显示选择提示，要求玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c21390858.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的Operation：从LabelObject取出选好的2张素材，将它们送去墓地，并释放临时Group引用。
function c21390858.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的2张素材卡作为这个特殊召唤手续的代价送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 检索目标的过滤条件：卡为3星或4星、光属性、魔法师族，且可以被加入手卡。
function c21390858.tfilter(c)
	return c:IsLevel(3,4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 判断这张卡是否是通过本卡自身的规则效果特殊召唤的（召唤类型为特殊召唤+自身值），用于限定‘这个方法特殊召唤成功时’和‘这个方法特殊召唤的这张卡’。
function c21390858.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 检索效果的Target：在发动时确认卡组存在可检索目标，并设置本次处理为从卡组将1张卡加入手卡的操作信息。
function c21390858.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否存在至少1张满足检索条件（3星或4星、光属性、魔法师族、可加入手卡）的卡；否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c21390858.tfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：效果处理时将以玩家tp从卡组把1张卡加入手卡（目标未定，所以targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的Operation：选择1张符合条件的怪兽加入手卡，并向对方展示确认。
function c21390858.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张符合tfilter条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c21390858.tfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（第二个参数nil表示回到持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
