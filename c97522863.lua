--刻印を持つ者
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组选1张「王家的神殿」或者有那个卡名记述的魔法·陷阱卡加入手卡或送去墓地。
-- ②：只要自己场上有「王家的神殿」存在，这张卡以及自己场上的「阿匹卜」怪兽不会被战斗·效果破坏。
-- ③：只要这张卡在怪兽区域存在，自己场上的「王家的神殿」不会被效果破坏。
local s,id,o=GetID()
-- 初始化函数，注册该卡片的所有效果：①召唤·特召成功时检索或送墓「王家的神殿」相关魔陷；②场上有「王家的神殿」时自身及「阿匹卜」怪兽获得战效破坏抗性；③自身在场时「王家的神殿」获得效果破坏抗性。
function s.initial_effect(c)
	-- 将「王家的神殿」的卡片密码注册到该卡的效果关联列表中，以便其他卡片检测关联性。
	aux.AddCodeList(c,29762407)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组选1张「王家的神殿」或者有那个卡名记述的魔法·陷阱卡加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要自己场上有「王家的神殿」存在，这张卡以及自己场上的「阿匹卜」怪兽不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.indcon)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	-- ③：只要这张卡在怪兽区域存在，自己场上的「王家的神殿」不会被效果破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_ONFIELD,0)
	e5:SetTarget(s.indtg2)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 过滤函数，用于筛选卡组中可以加入手卡或送去墓地的「王家的神殿」或记述了该卡名的魔法·陷阱卡。
function s.thfilter(c)
	-- 检查卡片是否为「王家的神殿」或者是有该卡名记述的魔法·陷阱卡。
	return (c:IsCode(29762407) or aux.IsCodeListed(c,29762407) and c:IsType(TYPE_SPELL+TYPE_TRAP))
		and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ①效果的发动准备函数，检查卡组中是否存在可操作的卡片。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果的执行函数，处理从卡组选择卡片并加入手卡或送去墓地的具体逻辑。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在界面上提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡片。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断选中的卡片是否能加入手卡，并根据其是否能送墓以及玩家的选择来决定后续操作分支。
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选中的卡片加入玩家手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,tc)
	elseif tc:IsAbleToGrave() then
		-- 将选中的卡片送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- ②效果的适用条件函数，判断自己场上是否存在表侧表示的「王家的神殿」。
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「王家的神殿」（卡号29762407）。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,29762407)
end
-- ②效果的抗性适用对象过滤函数，使抗性适用于自身以及自己场上的「阿匹卜」怪兽。
function s.indtg(e,c)
	return c:IsSetCard(0x1c8) or e:GetHandler()==c
end
-- ③效果的抗性适用对象过滤函数，使抗性适用于自己场上的「王家的神殿」。
function s.indtg2(e,c)
	return c:IsCode(29762407)
end
