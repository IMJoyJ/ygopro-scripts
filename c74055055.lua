--石油採掘
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地最多2只4星以下的炎属性怪兽为对象才能发动（同名卡最多1张）。那些怪兽加入手卡。
function c74055055.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地最多2只4星以下的炎属性怪兽为对象才能发动（同名卡最多1张）。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74055055,0))  --"回收炎属性怪兽"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,74055055+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c74055055.target)
	e1:SetOperation(c74055055.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中4星以下的炎属性怪兽，且该怪兽可以加入手牌并能成为效果对象
function c74055055.filter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 效果发动的准备阶段，检查并选择自己墓地1到2张卡名不同的4星以下炎属性怪兽作为对象，并设置操作信息
function c74055055.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c74055055.filter(chkc,e) end
	-- 获取自己墓地中所有符合过滤条件的怪兽卡片组
	local g=Duel.GetMatchingGroup(c74055055.filter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return g:GetCount()>0 end
	-- 向玩家发送提示信息，要求选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从符合条件的卡片组中选择1到2张卡名不同的卡片
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
	-- 将玩家选择的卡片设置为效果的对象
	Duel.SetTargetCard(sg)
	-- 设置当前连锁的操作信息，表示将选定的卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果处理的执行函数，获取仍有效的对象卡片并将其加入手牌
function c74055055.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将选定的对象卡片通过效果加入玩家手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
