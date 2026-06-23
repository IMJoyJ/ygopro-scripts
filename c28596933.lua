--巨竜の羽ばたき
-- 效果：
-- ①：选自己场上1只5星以上的龙族怪兽回到持有者手卡，场上的魔法·陷阱卡全部破坏。
function c28596933.initial_effect(c)
	-- ①：选自己场上1只5星以上的龙族怪兽回到持有者手卡，场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c28596933.target)
	e1:SetOperation(c28596933.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上表侧表示的龙族5星以上可以送入手牌的怪兽
function c28596933.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
-- 过滤函数，用于筛选场上的魔法·陷阱卡
function c28596933.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的处理函数，判断是否满足发动条件
function c28596933.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否存在满足条件的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28596933.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断场地上是否存在魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c28596933.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有魔法·陷阱卡的集合
	local sg=Duel.GetMatchingGroup(c28596933.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置将要处理的卡为1只怪兽，送去手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
	-- 设置将要处理的卡为场上所有魔法·陷阱卡，进行破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果发动时的处理函数，执行效果内容
function c28596933.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c28596933.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 确认选择的怪兽成功送入手牌后执行后续破坏效果
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取场上所有魔法·陷阱卡的集合（排除此卡）
		local sg=Duel.GetMatchingGroup(c28596933.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		-- 将场上所有魔法·陷阱卡破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
