--バルキリー・ナイト
-- 效果：
-- ①：只要这张卡在怪兽区域存在，对方不能选择「女武神骑士」以外的战士族怪兽作为攻击对象。
-- ②：这张卡被战斗破坏送去墓地时，从自己墓地把1只战士族怪兽和这张卡除外，以自己墓地1只5星以上的战士族怪兽为对象才能发动。那只战士族怪兽特殊召唤。
function c99348756.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方不能选择「女武神骑士」以外的战士族怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c99348756.atktg)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏送去墓地时，从自己墓地把1只战士族怪兽和这张卡除外，以自己墓地1只5星以上的战士族怪兽为对象才能发动。那只战士族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99348756,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c99348756.spcon)
	e2:SetTarget(c99348756.sptg)
	e2:SetOperation(c99348756.spop)
	c:RegisterEffect(e2)
end
-- 判断候选攻击对象是否为“不是这张卡自身且表侧表示的战士族怪兽”，若是则对方不能将其选为攻击对象。
function c99348756.atktg(e,c)
	return not c:IsCode(99348756) and c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 发动条件判定：这张卡被战斗破坏后已经处于墓地，且破坏原因确实是战斗破坏。
function c99348756.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 筛选可作为除外代价的战士族怪兽：自身能作为代价除外，并且除外后墓地仍有满足特殊召唤对象条件的（5星以上战士族）怪兽存在。
function c99348756.rmfilter(c,e,tp,g)
	return c:IsAbleToRemoveAsCost() and g:IsExists(c99348756.spfilter,1,c,e,tp)
end
-- 特殊召唤对象过滤条件：该怪兽能成为此效果的对象，等级在5以上，并且可以被特殊召唤。
function c99348756.spfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查：确认指定对象是否合法；收集自己墓地中除自身以外的战士族怪兽；并检查是否有空位、自身能否除外、是否存在可被除外的战士族怪兽来保证后续特殊召唤成立。
function c99348756.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c99348756.spfilter(chkc,e,tp) end
	-- 获取自己墓地中除这张卡自身以外的全部战士族怪兽，作为选择除外代价和特殊召唤对象的候选集合。
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,0,e:GetHandler(),RACE_WARRIOR)
	-- 检查自己主要怪兽区域是否有空位，以保证后续能够进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsAbleToRemoveAsCost()
		and g:IsExists(c99348756.rmfilter,1,nil,e,tp,g) end
	-- 给玩家发送“请选择要除外的卡”的提示消息，用于下一步选择除外代价。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:FilterSelect(tp,c99348756.rmfilter,1,1,nil,e,tp,g)
	g:Sub(rg)
	rg:AddCard(e:GetHandler())
	-- 将选择的1只战士族怪兽与这张卡自身以表侧表示除外，作为效果的发动代价。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	-- 给玩家发送“请选择要特殊召唤的卡”的提示消息，用于下一步选择特殊召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:FilterSelect(tp,c99348756.spfilter,1,1,nil,e,tp)
	-- 将选择的那只5星以上战士族怪兽设置为该效果的对象（取对象）。
	Duel.SetTargetCard(sg)
	-- 设置连锁操作信息：本次效果将特殊召唤选择的1只怪兽，用于其他卡片或效果对该连锁的响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end
-- 效果处理：从已设置的对象中取出目标怪兽，若它仍与此效果相关且是战士族，就将其特殊召唤。
function c99348756.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的对象卡（即之前选择的5星以上战士族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_WARRIOR) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上（不限制表示形式，默认为表侧攻击表示）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
