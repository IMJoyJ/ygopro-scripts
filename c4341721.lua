--Trick or Treat！
-- 效果：
-- ①：从自己的卡组·墓地把1只「淘气大精灵 哈洛」或「点心大精灵 维恩」加入手卡。
local s,id,o=GetID()
-- 创建效果：将卡牌效果注册为发动时可以检索或特殊召唤的魔法卡
function s.initial_effect(c)
	-- 记录该卡与「淘气大精灵 哈洛」和「点心大精灵 维恩」的关联
	aux.AddCodeList(c,54611591,81005500)
	-- ①：从自己的卡组·墓地把1只「淘气大精灵 哈洛」或「点心大精灵 维恩」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：筛选出卡号为哈洛或维恩且可以加入手牌的卡
function s.filter(c)
	return c:IsCode(54611591,81005500) and c:IsAbleToHand()
end
-- 效果的发动检查：确认场上是否存在满足条件的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查条件：确认是否存在至少一张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：确定效果处理时将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：选择并把符合条件的卡加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡组或墓地中的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选卡的卡面信息
		Duel.ConfirmCards(1-tp,g)
	end
end
