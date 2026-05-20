--ダイナミスト・プテラン
-- 效果：
-- ←3 【灵摆】 3→
-- ①：这张卡以外的自己场上的「雾动机龙」卡被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
-- 【怪兽效果】
-- ①：这张卡战斗破坏对方怪兽时才能发动。从卡组把1张「雾动机龙」卡加入手卡。
function c64973287.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动效果
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡以外的自己场上的「雾动机龙」卡被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTarget(c64973287.reptg)
	e2:SetValue(c64973287.repval)
	e2:SetOperation(c64973287.repop)
	c:RegisterEffect(e2)
	-- ①：这张卡战斗破坏对方怪兽时才能发动。从卡组把1张「雾动机龙」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64973287,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件为自身战斗破坏对方怪兽
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c64973287.target)
	e3:SetOperation(c64973287.operation)
	c:RegisterEffect(e3)
end
-- 过滤自己场上因战斗或对方效果破坏的「雾动机龙」卡
function c64973287.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0xd8)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的目标过滤与检测（检测是否存在满足代替破坏条件的卡，且自身未确定被破坏）
function c64973287.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c64973287.repfilter,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 过滤需要被代替破坏的卡
function c64973287.repval(e,c)
	return c64973287.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理（破坏自身）
function c64973287.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏自身作为代替
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 过滤卡组中可以加入手牌的「雾动机龙」卡
function c64973287.filter(c)
	return c:IsSetCard(0xd8) and c:IsAbleToHand()
end
-- 检索效果的发动检测与操作信息注册
function c64973287.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「雾动机龙」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c64973287.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体处理（从卡组将1张「雾动机龙」卡加入手牌并给对方确认）
function c64973287.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「雾动机龙」卡
	local g=Duel.SelectMatchingCard(tp,c64973287.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
