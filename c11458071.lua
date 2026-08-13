--天魔神 エンライズ
-- 效果：
-- 这张卡不能通常召唤。把自己墓地的3只光属性·天使族怪兽和1只暗属性·恶魔族怪兽从游戏中除外的场合才能特殊召唤。可以把场上表侧表示存在的1只怪兽从游戏中除外。这个效果发动的场合，这个回合这张卡不能攻击。这个效果1回合只能使用1次。
function c11458071.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己墓地的3只光属性·天使族怪兽和1只暗属性·恶魔族怪兽从游戏中除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c11458071.spcon)
	e2:SetTarget(c11458071.sptg)
	e2:SetOperation(c11458071.spop)
	c:RegisterEffect(e2)
	-- 可以把场上表侧表示存在的1只怪兽从游戏中除外。这个效果发动的场合，这个回合这张卡不能攻击。这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11458071,0))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c11458071.rmcost)
	e3:SetTarget(c11458071.rmtg)
	e3:SetOperation(c11458071.rmop)
	c:RegisterEffect(e3)
end
-- 判断怪兽是否为光属性·天使族，用于筛选特殊召唤所需的3只光属性天使族素材之一。
function c11458071.spfilter1(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 判断怪兽是否为暗属性·恶魔族，用于筛选特殊召唤所需的1只暗属性恶魔族素材。
function c11458071.spfilter2(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)
end
c11458071.spchecks={c11458071.spfilter1,c11458071.spfilter1,c11458071.spfilter1,c11458071.spfilter2}
-- 综合判断墓地中的卡片是否为光属性天使族或暗属性恶魔族，且可作为除外代价；作为特殊召唤素材的候选过滤条件。
function c11458071.spfilter(c)
	return ((c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)) or (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)))
		and c:IsAbleToRemoveAsCost()
end
-- 检查特殊召唤条件：自己主要怪兽区有空位，且墓地中存在满足“3只光属性·天使族+1只暗属性·恶魔族”组合的素材。
function c11458071.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己墓地中所有满足spfilter条件的卡片，作为可选择为除外素材的候选集合。
	local g=Duel.GetMatchingGroup(c11458071.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 确认自己主要怪兽区存在空位，以保证特殊召唤能够进行。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroupEach(c11458071.spchecks)
end
-- 执行特殊召唤手续的选择：提示玩家选择3只光属性天使族和1只暗属性恶魔族作为除外素材，并保存选择结果，成功后允许发动。
function c11458071.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中满足素材条件的卡片集合，供玩家进行选择。
	local g=Duel.GetMatchingGroup(c11458071.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 显示“请选择要除外的卡”的提示信息，引导玩家选择素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroupEach(tp,c11458071.spchecks,true)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤手续：取出之前选择的素材，一并除外，完成特殊召唤。
function c11458071.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的4张素材以表侧表示除外，作为特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 发动除外效果的代价：确认本回合该卡尚未攻击过；若满足，则给自己设置一个结束阶段前不能攻击的誓约效果。
function c11458071.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 可以把场上表侧表示存在的1只怪兽从游戏中除外。这个效果发动的场合，这个回合这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1,true)
end
-- 过滤出场上表侧表示且可以被除外的怪兽，作为此效果可以选择的取对象目标。
function c11458071.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 该效果的取对象处理：若有合法对象，选择场上1只表侧表示且可除外的怪兽，并登记除外信息。
function c11458071.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11458071.tgfilter(chkc) end
	-- 检查场上是否存在至少1只满足条件的表侧表示且可除外的怪兽，作为效果可否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(c11458071.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要除外的卡”的提示信息，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1只满足条件的表侧表示怪兽作为效果对象，并自动与该效果建立关联。
	local g=Duel.SelectTarget(tp,c11458071.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：本效果将处理除外的对象为g（1张卡），用于连锁和时点判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 除外效果处理：取得对象卡，确认其仍表侧表示且与当前效果关联后将其除外。
function c11458071.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的对象卡（本效果选择的那1只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将该对象怪兽以表侧表示除外（由于卡片效果而除外）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
