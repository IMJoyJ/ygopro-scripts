--竜儀巧－メテオニス＝DAD
-- 效果：
-- 「流星辉巧群」降临
-- ①：自己场上的其他的「龙辉巧」怪兽不会被对方的效果破坏。
-- ②：1回合最多2次，对方把怪兽的效果发动时，攻击力合计直到变成那只怪兽的原本攻击力以上为止从自己墓地把「龙辉巧」怪兽除外才能发动。那个发动无效并破坏。
-- ③：仪式召唤的这张卡被对方破坏的场合才能发动。从手卡·卡组把1只攻击力4000的仪式怪兽当作仪式召唤作特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含仪式召唤限制、效果①（场上其他「龙辉巧」怪兽的效果破坏抗性）、效果②（无效并破坏对方怪兽效果的发动）以及效果③（被破坏时从手卡·卡组特殊召唤攻击力4000的仪式怪兽）。
function s.initial_effect(c)
	-- 将「流星辉巧群」（卡号22398665）记录在这张卡记载的卡名列表中。
	aux.AddCodeList(c,22398665)
	c:EnableReviveLimit()
	-- ①：自己场上的其他的「龙辉巧」怪兽不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.indtg)
	-- 设置抗性类型为不会被对方的效果破坏。
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- ②：1回合最多2次，对方把怪兽的效果发动时，攻击力合计直到变成那只怪兽的原本攻击力以上为止从自己墓地把「龙辉巧」怪兽除外才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"怪兽效果无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：仪式召唤的这张卡被对方破坏的场合才能发动。从手卡·卡组把1只攻击力4000的仪式怪兽当作仪式召唤作特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤自身以外的自己场上的「龙辉巧」怪兽，作为效果①破坏抗性的适用对象。
function s.indtg(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x154)
end
-- 效果②的发动条件：对方发动怪兽效果，且该发动可以被无效，同时此卡不在伤害步骤被战斗破坏。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的怪兽效果，且该发动可以被无效。
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果②的发动代价处理函数，设置标签100用于后续在target中检测是否通过cost检测。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤墓地中可作为除外代价的「龙辉巧」怪兽（攻击力大于等于1，且可以作为代价除外）。
function s.costfilter(c,atk)
	return c:IsSetCard(0x154) and c:IsType(TYPE_MONSTER) and (atk==0 or c:IsAttackAbove(1)) and c:IsAbleToRemoveAsCost()
end
-- 检查选取的怪兽组的攻击力合计是否达到目标数值，且不包含多余的卡（即去掉任意一张后合计攻击力就会低于目标数值）。
function s.fselect(g,atk)
	local sum=g:GetSum(Card.GetAttack)
	return sum>=atk and (atk==0 and g:GetCount()==1 or not g:IsExists(Card.IsAttackBelow,1,nil,sum-atk))
end
-- 效果②的目标确认与代价支付：计算对方怪兽的原本攻击力，从墓地选择并除外攻击力合计在其以上的「龙辉巧」怪兽，并设置无效与破坏的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=0
	if re:GetHandler():IsLocation(LOCATION_MZONE) then
		atk=re:GetHandler():GetBaseAttack()
	else
		atk=re:GetHandler():GetTextAttack()
	end
	-- 获取自己墓地中所有满足条件的「龙辉巧」怪兽。
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,nil,atk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		return g:CheckSubGroup(s.fselect,1,#g,atk)
	end
	-- 给玩家发送提示信息，提示选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,1,#g,atk)
	-- 将选定的怪兽作为发动代价表侧表示除外。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	-- 设置操作信息，表示该效果包含“使发动无效”的处理。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果对方发动的卡可以被破坏，则设置操作信息，表示该效果包含“破坏”的处理。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的效果处理：使对方怪兽效果的发动无效，并将其破坏。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 成功使发动无效，且该卡在连锁处理时仍与效果关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动被无效的卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果③的发动条件：仪式召唤的这张卡在自己场上被对方破坏并送去墓地或除外。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤手卡·卡组中攻击力为4000且可以当作仪式召唤特殊召唤的仪式怪兽。
function s.spfilter(c,e,tp)
	return c:IsAttack(4000) and c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
-- 效果③的靶向处理：检查怪兽区域是否有空位，以及手卡·卡组是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果③的效果处理：从手卡·卡组选择1只攻击力4000的仪式怪兽，当作仪式召唤特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有可用的怪兽区域空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的仪式怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选定的怪兽当作仪式召唤特殊召唤到场上。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
