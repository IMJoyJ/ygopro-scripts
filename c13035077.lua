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
	-- ①：场上的「真龙」怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 筛选满足「真龙」种族且在主要怪兽区的怪兽
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
-- 筛选满足上级召唤且为「真龙」种族的怪兽
function c13035077.indtg(e,c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsSetCard(0xf9)
end
-- 若破坏原因为战斗，则返回1次不会被破坏，否则返回0次
function c13035077.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 筛选满足「真龙」种族且可以加入手卡的卡
function c13035077.thfilter(c)
	return c:IsSetCard(0xf9) and c:IsAbleToHand()
end
-- 判断发动条件：自己手卡或场上的卡至少1张，卡组中至少1张「真龙」卡
function c13035077.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断发动条件：自己手卡或场上的卡至少1张
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 判断发动条件：卡组中至少1张「真龙」卡
		and Duel.IsExistingMatchingCard(c13035077.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 获取满足条件的自己手卡或场上的卡
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	-- 设置连锁操作信息：将1张卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁操作信息：将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择1张手卡或场上的卡破坏，然后从卡组检索1张「真龙」卡加入手卡
function c13035077.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择1张手卡或场上的卡作为破坏对象
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,aux.ExceptThisCard(e))
	-- 确认选择的卡被破坏成功
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手卡的「真龙」卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 从卡组中选择1张「真龙」卡
		local g=Duel.SelectMatchingCard(tp,c13035077.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的「真龙」卡加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
