--蕾禍ノ鎧石竜
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把自己墓地1只昆虫族·植物族·爬虫类族怪兽除外，从手卡特殊召唤。
-- ②：从手卡丢弃1只昆虫族·植物族·爬虫类族怪兽，以昆虫族·植物族·爬虫类族怪兽以外的对方场上1只表侧表示怪兽为对象才能发动。那只怪兽回到手卡。
local s,id,o=GetID()
-- 创建两个效果，一个用于特殊召唤条件，一个用于发动效果
function s.initial_effect(c)
	-- ①：这张卡可以把自己墓地1只昆虫族·植物族·爬虫类族怪兽除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：从手卡丢弃1只昆虫族·植物族·爬虫类族怪兽，以昆虫族·植物族·爬虫类族怪兽以外的对方场上1只表侧表示怪兽为对象才能发动。那只怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"把怪兽弹回手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的墓地怪兽（昆虫族·植物族·爬虫类族且可除外）
function s.spcostfilter1(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE)
end
-- 判断是否满足特殊召唤条件，包括是否有可用怪兽区和是否有符合条件的墓地怪兽
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断场上是否有可用怪兽区
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取符合条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(s.spcostfilter1,tp,LOCATION_GRAVE,0,nil)
	return #g>0
end
-- 处理特殊召唤时的除外操作
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 再次获取符合条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(s.spcostfilter1,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		-- 将选中的卡除外作为代价
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
	end
end
-- 过滤满足条件的手卡怪兽（昆虫族·植物族·爬虫类族且可丢弃）
function s.costfilter(c)
	return c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsDiscardable()
end
-- 处理效果发动时的丢弃手卡操作
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的手卡怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃手卡操作
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤满足条件的对方场上怪兽（非昆虫族·植物族·爬虫类族且正面表示）
function s.thfilter(c)
	return not c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsFaceup()
end
-- 设置效果的目标选择和操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查是否满足目标选择条件
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定将怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果发动后的送回手牌操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
