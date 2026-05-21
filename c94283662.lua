--トランス・デーモン
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从手卡丢弃1只恶魔族怪兽，这张卡的攻击力直到回合结束时上升500。
-- ②：自己场上的这张卡被破坏送去墓地时，以除外的1只自己的暗属性怪兽为对象才能发动。那只怪兽加入手卡。
function c94283662.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。从手卡丢弃1只恶魔族怪兽，这张卡的攻击力直到回合结束时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94283662,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c94283662.target)
	e1:SetOperation(c94283662.operation)
	c:RegisterEffect(e1)
	-- ②：自己场上的这张卡被破坏送去墓地时，以除外的1只自己的暗属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94283662,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c94283662.thcon)
	e2:SetTarget(c94283662.thtg)
	e2:SetOperation(c94283662.thop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可丢弃的恶魔族怪兽
function c94283662.dfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsDiscardable()
end
-- ①号效果的发动准备与检测（检查手卡中是否存在恶魔族怪兽，并设置丢弃手卡的操作信息）
function c94283662.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡中是否存在至少1只可以丢弃的恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94283662.dfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息，表示该效果包含丢弃1张手卡的处理
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- ①号效果的执行（丢弃1只恶魔族怪兽，并使这张卡的攻击力直到回合结束时上升500）
function c94283662.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让玩家选择并丢弃1张手卡中的恶魔族怪兽
	local ct=Duel.DiscardHand(tp,c94283662.dfilter,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		c:RegisterEffect(e1)
	end
end
-- 检查触发条件：这张卡在自己场上被破坏并送去墓地
function c94283662.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)>0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤除外状态的、可以加入手卡的暗属性怪兽
function c94283662.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- ②号效果的发动准备（检查除外区是否存在暗属性怪兽，选择对象，并设置加入手卡的操作信息）
function c94283662.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c94283662.filter(chkc) end
	-- 检查自己的除外区是否存在至少1只可以加入手卡的暗属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c94283662.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外的1只自己的暗属性怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c94283662.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息，表示该效果包含将选中的卡加入手卡的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ②号效果的执行（将作为对象的除外怪兽加入手卡）
function c94283662.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
