--ドラゴニックD
-- 效果：
-- ①：场上的「真龙」怪兽的攻击力·守备力上升300。
-- ②：只要这张卡在场地区域存在，上级召唤的「真龙」怪兽在1回合各有1次不会被战斗破坏。
-- ③：1回合1次，自己主要阶段才能发动。这张卡以外的自己的手卡·场上1张卡破坏，从卡组把1张「真龙」卡加入手卡。
function c13035077.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「真龙」怪兽的攻击力·守备力上升300。（本行实现攻击力上升部分）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置攻击力增减效果的作用对象为场上表侧表示的「真龙」怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf9))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在场地区域存在，上级召唤的「真龙」怪兽在1回合各有1次不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(c13035077.indtg)
	e4:SetValue(c13035077.indct)
	c:RegisterEffect(e4)
	-- ③：1回合1次，自己主要阶段才能发动。这张卡以外的自己的手卡·场上1张卡破坏，从卡组把1张「真龙」卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(13035077,0))
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c13035077.destg)
	e5:SetOperation(c13035077.desop)
	c:RegisterEffect(e5)
end
-- 判断怪兽是否为上级召唤的「真龙」怪兽，作为②效果的保护对象筛选条件。
function c13035077.indtg(e,c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsSetCard(0xf9)
end
-- 若破坏原因是战斗破坏，则返回1，为该怪兽提供1次不会被战斗破坏的机会；否则返回0。
function c13035077.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 从卡组检索「真龙」卡的过滤条件：持有「真龙」字段且可以加入手卡。
function c13035077.thfilter(c)
	return c:IsSetCard(0xf9) and c:IsAbleToHand()
end
-- ③的发动条件与操作信息登记：检查存在可破坏的这张卡以外的手卡·场上卡以及可检索的「真龙」卡，并登记破坏1张、检索1张的预操作。
function c13035077.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查自己手牌·场上是否存在至少1张这张卡以外的卡可作为破坏对象。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 同时检查卡组中是否存在至少1张「真龙」卡可以加入手卡。
		and Duel.IsExistingMatchingCard(c13035077.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 获取自己手牌·场上除这张卡以外的所有卡，作为破坏对象候选集合。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	-- 登记本次效果将破坏1张卡的操作信息，目标候选为集合g。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记从卡组将1张卡加入手卡的操作信息，目标玩家为发动者。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：选择并破坏这张卡以外的手卡·场上1张卡，若破坏成功则从卡组选1张「真龙」卡加入手卡并向对方展示。
function c13035077.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从自己的手牌·场上选择1张这张卡以外的卡作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,aux.ExceptThisCard(e))
	-- 若成功选择到卡并将其效果破坏成功，则继续执行检索处理。
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 显示“请选择要加入手牌的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组选择1张满足「真龙」且可加入手卡条件的卡。
		local g=Duel.SelectMatchingCard(tp,c13035077.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的「真龙」卡加入其持有者的手卡，原因为效果。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
