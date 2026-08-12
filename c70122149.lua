--呪眼領閾－パレイドリア－
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「咒眼」怪兽加入手卡。
-- ②：1回合1次，自己的魔法与陷阱区域有「太阴之咒眼」存在，自己的「咒眼」怪兽被攻击的伤害计算时才能发动。那次战斗发生的对自己的战斗伤害让对方也承受。
-- ③：场地区域的这张卡被效果破坏的场合，以自己墓地1只「咒眼」怪兽为对象才能发动。那只怪兽加入手卡。
function c70122149.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「咒眼」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,70122149+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c70122149.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己的魔法与陷阱区域有「太阴之咒眼」存在，自己的「咒眼」怪兽被攻击的伤害计算时才能发动。那次战斗发生的对自己的战斗伤害让对方也承受。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c70122149.rfcon)
	e2:SetTarget(c70122149.rftg)
	e2:SetOperation(c70122149.rfop)
	c:RegisterEffect(e2)
	-- ③：场地区域的这张卡被效果破坏的场合，以自己墓地1只「咒眼」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c70122149.thcon)
	e3:SetTarget(c70122149.thtg)
	e3:SetOperation(c70122149.thop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可以加入手牌的「咒眼」怪兽
function c70122149.filter(c)
	return c:IsSetCard(0x129) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 作为这张卡的发动时的效果处理，可以从卡组把1只「咒眼」怪兽加入手卡
function c70122149.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足条件的「咒眼」怪兽
	local g=Duel.GetMatchingGroup(c70122149.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在满足条件的怪兽，询问玩家是否发动检索效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(70122149,0)) then  --"是否把1只「咒眼」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤场上表侧表示的「太阴之咒眼」
function c70122149.filter1(c)
	return c:IsCode(44133040) and c:IsFaceup()
end
-- 检查是否满足效果②的发动条件：自己的魔法与陷阱区域有「太阴之咒眼」存在
function c70122149.rfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的魔法与陷阱区域是否存在表侧表示的「太阴之咒眼」
	return Duel.IsExistingMatchingCard(c70122149.filter1,tp,LOCATION_SZONE,0,1,nil)
end
-- 检查是否满足效果②的发动时点：自己的「咒眼」怪兽被攻击的伤害计算时
function c70122149.rftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前被攻击的怪兽
	local d=Duel.GetAttackTarget()
	if chk==0 then return d~=nil and d:IsControler(tp) and d:IsSetCard(0x129) end
end
-- 执行效果②的效果处理：那次战斗发生的对自己的战斗伤害让对方也承受
function c70122149.rfop(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害让对方也承受。③：场地区域的这张卡被效果破坏的场合，以自己墓地1只「咒眼」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ALSO_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册让对方也承受战斗伤害的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 检查是否满足效果③的发动条件：场地区域的这张卡被效果破坏的场合
function c70122149.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_FZONE)
end
-- 过滤墓地中可以加入手牌的「咒眼」怪兽
function c70122149.thfilter(c)
	return c:IsSetCard(0x129) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果③的发动准备：以自己墓地1只「咒眼」怪兽为对象
function c70122149.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c70122149.filter(chkc) end
	-- 检查自己墓地是否存在可以作为对象的「咒眼」怪兽
	if chk==0 then return Duel.IsExistingTarget(c70122149.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「咒眼」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c70122149.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果③的效果处理：那只怪兽加入手卡
function c70122149.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
