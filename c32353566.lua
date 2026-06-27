--魔女の聖夜行
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：主要阶段才能发动。从卡组把1只「魔女术」怪兽加入手卡，那之后选1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在场地区域存在，在自己回合内使对应效果生效。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(id)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.effcon)
	c:RegisterEffect(e3)
end
-- 过滤卡组中的「魔女术」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的目标选择与检查
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组是否存在可以检索的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 声明检索并加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 声明丢弃手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 检索效果的实际操作：加入手牌并丢弃一张手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 执行加入手牌操作，并确认是否成功
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 切分效果时点
		Duel.BreakEffect()
		-- 提示选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 从手牌中选择要丢弃的一张卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 将手牌洗牌
		Duel.ShuffleHand(tp)
		-- 执行丢弃手牌送墓
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 场地效果的生效条件：必须在自己的回合中
function s.effcon(e)
	-- 确认当前是否为我方的回合
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
