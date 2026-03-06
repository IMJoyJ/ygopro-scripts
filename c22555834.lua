--魔轟神界の階
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「魔轰神」怪兽送去墓地。
-- ②：以自己墓地1只「魔轰神」怪兽为对象才能发动。选自己2张手卡丢弃，作为对象的怪兽加入手卡。
-- ③：自己手卡比对方少的场合，自己的「魔轰神」怪兽的攻击力只在向对方怪兽攻击的伤害计算时上升双方手卡数量差×200。
function c22555834.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「魔轰神」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22555834+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c22555834.activate)
	c:RegisterEffect(e1)
	-- ②：以自己墓地1只「魔轰神」怪兽为对象才能发动。选自己2张手卡丢弃，作为对象的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22555834,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,22555834)
	e2:SetTarget(c22555834.thtg)
	e2:SetOperation(c22555834.thop)
	c:RegisterEffect(e2)
	-- ③：自己手卡比对方少的场合，自己的「魔轰神」怪兽的攻击力只在向对方怪兽攻击的伤害计算时上升双方手卡数量差×200。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c22555834.atktg)
	e3:SetCondition(c22555834.atkcon)
	e3:SetValue(c22555834.atkval)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选可以送去墓地的「魔轰神」怪兽
function c22555834.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x35) and c:IsAbleToGrave()
end
-- 发动时的效果处理，从卡组选择1只「魔轰神」怪兽送去墓地
function c22555834.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「魔轰神」怪兽组
	local g=Duel.GetMatchingGroup(c22555834.tgfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否满足发动条件并询问玩家是否发动
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(22555834,0)) then  --"是否从卡组把「魔轰神」怪兽送去墓地？"
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选可以加入手牌的「魔轰神」怪兽
function c22555834.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x35) and c:IsAbleToHand()
end
-- 设置效果目标，检查是否有满足条件的墓地「魔轰神」怪兽和手牌
function c22555834.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22555834.thfilter(chkc) end
	-- 检查是否有满足条件的墓地「魔轰神」怪兽
	if chk==0 then return Duel.IsExistingTarget(c22555834.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查是否有满足条件的手牌
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,2,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标墓地「魔轰神」怪兽
	local g1=Duel.SelectTarget(tp,c22555834.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，指定将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
	-- 设置效果操作信息，指定丢弃2张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,2)
end
-- 效果处理函数，丢弃2张手牌并将目标怪兽加入手牌
function c22555834.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断是否成功丢弃2张手牌且目标怪兽有效
	if Duel.DiscardHand(tp,aux.TRUE,2,2,REASON_EFFECT+REASON_DISCARD)>1 and tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 设置攻击力更新的目标条件
function c22555834.atktg(e,c)
	-- 目标为「魔轰神」怪兽且为当前攻击怪兽
	return c:IsSetCard(0x35) and Duel.GetAttacker()==c
end
-- 设置攻击力更新的触发条件
function c22555834.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 当前阶段为伤害计算阶段且存在攻击对象
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()~=nil
		-- 己方手牌数量少于对方手牌数量
		and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
end
-- 计算攻击力提升值
function c22555834.atkval(e,c)
	-- 计算双方手牌数量差
	local ct=Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_HAND)-Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)
	return ct>0 and ct*200
end
