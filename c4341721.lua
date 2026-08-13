--Trick or Treat！
-- 效果：
-- ①：从自己的卡组·墓地把1只「淘气大精灵 哈洛」或「点心大精灵 维恩」加入手卡。
local s,id,o=GetID()
-- 注册这张卡的①效果：作为魔法卡发动时，从自己的卡组·墓地检索1只「淘气大精灵 哈洛」或「点心大精灵 维恩」加入手牌。
function s.initial_effect(c)
	-- 记录这张卡上记载了「淘气大精灵 哈洛」(54611591)和「点心大精灵 维恩」(81005500)这两个卡名。
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
-- 定义过滤器：目标卡必须是「淘气大精灵 哈洛」或「点心大精灵 维恩」，并且能够加入手牌。
function s.filter(c)
	return c:IsCode(54611591,81005500) and c:IsAbleToHand()
end
-- 效果发动前的目标判定与操作信息设置：确认自己卡组·墓地存在符合条件的卡，并声明本次效果将把1张卡加入手牌。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：自己卡组或墓地中是否存在至少1张符合条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：将本次效果分类为加入手牌/检索，处理的卡数为1，来源为自己卡组或墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从自己卡组·墓地选择1只符合条件的怪兽加入手牌（过滤王家长眠之谷的影响），成功后让对手确认该卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组·墓地中选择1张经过王家长眠之谷效果过滤的符合条件的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手展示本次加入手牌的卡，满足公开信息要求。
		Duel.ConfirmCards(1-tp,g)
	end
end
