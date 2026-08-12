--暗黒竜 コラプサーペント
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只光属性怪兽除外的场合才能特殊召唤。这个方法的「暗黑龙 坍缩星蛇」的特殊召唤1回合只能有1次。
-- ①：这张卡从场上送去墓地的场合才能发动。从卡组把1只「辉白龙 暴源翼龙」加入手卡。
function c61901281.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 从自己墓地把1只光属性怪兽除外的场合才能特殊召唤。这个方法的「暗黑龙 坍缩星蛇」的特殊召唤1回合只能有1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,61901281+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c61901281.spcon)
	e2:SetTarget(c61901281.sptg)
	e2:SetOperation(c61901281.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡从场上送去墓地的场合才能发动。从卡组把1只「辉白龙 暴源翼龙」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61901281,0))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c61901281.condition)
	e3:SetTarget(c61901281.target)
	e3:SetOperation(c61901281.operation)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中可以作为特殊召唤Cost除外的光属性怪兽
function c61901281.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判断函数，检查怪兽区域是否有空位以及墓地是否存在可除外的光属性怪兽
function c61901281.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件（光属性且可除外）的怪兽
		and Duel.IsExistingMatchingCard(c61901281.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则的目标选择函数，让玩家选择1只墓地的光属性怪兽作为特殊召唤的Cost
function c61901281.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足过滤条件的光属性怪兽组
	local g=Duel.GetMatchingGroup(c61901281.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作函数，执行将选定怪兽除外的操作
function c61901281.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽以特殊召唤为原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 效果发动条件判断：这张卡必须是从场上送去墓地
function c61901281.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动时的目标选择与合法性检查，并设置效果处理信息
function c61901281.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在可检索的「辉白龙 暴源翼龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c61901281.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示该效果包含“从卡组将1张卡加入手牌”的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中卡名为「辉白龙 暴源翼龙」且能加入手牌的卡
function c61901281.filter(c)
	return c:IsCode(99234526) and c:IsAbleToHand()
end
-- 效果处理函数，从卡组选择「辉白龙 暴源翼龙」加入手牌并向对方展示
function c61901281.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「辉白龙 暴源翼龙」
	local g=Duel.SelectMatchingCard(tp,c61901281.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
