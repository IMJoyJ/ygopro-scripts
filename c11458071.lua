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
-- 过滤满足条件的光属性·天使族怪兽
function c11458071.spfilter1(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 过滤满足条件的暗属性·恶魔族怪兽
function c11458071.spfilter2(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)
end
c11458071.spchecks={c11458071.spfilter1,c11458071.spfilter1,c11458071.spfilter1,c11458071.spfilter2}
-- 过滤满足条件的光属性·天使族或暗属性·恶魔族怪兽
function c11458071.spfilter(c)
	return ((c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)) or (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)))
		and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤条件
function c11458071.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家墓地满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c11458071.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 判断玩家场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroupEach(c11458071.spchecks)
end
-- 设置特殊召唤目标
function c11458071.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家墓地满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c11458071.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroupEach(tp,c11458071.spchecks,true)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤操作
function c11458071.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 设置除外效果的费用
function c11458071.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 设置此回合不能攻击的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1,true)
end
-- 过滤场上正面表示且能除外的怪兽
function c11458071.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 设置除外效果的目标
function c11458071.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11458071.tgfilter(chkc) end
	-- 判断场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c11458071.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择场上满足条件的怪兽
	local g=Duel.SelectTarget(tp,c11458071.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为除外效果
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外效果操作
function c11458071.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
