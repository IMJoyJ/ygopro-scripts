--妖仙獣 鎌壱太刀
-- 效果：
-- ①：这张卡召唤成功的场合才能发动。从手卡把「妖仙兽 镰壹太刀」以外的1只「妖仙兽」怪兽召唤。
-- ②：只在这张卡在场上表侧表示存在才有1次，自己场上有这张卡以外的「妖仙兽」怪兽存在的场合以对方场上1张表侧表示的卡为对象才能发动。那张卡回到持有者手卡。
-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
function c65247798.initial_effect(c)
	-- ①：这张卡召唤成功的场合才能发动。从手卡把「妖仙兽 镰壹太刀」以外的1只「妖仙兽」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65247798,0))  --"召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c65247798.sumtg)
	e1:SetOperation(c65247798.sumop)
	c:RegisterEffect(e1)
	-- ②：只在这张卡在场上表侧表示存在才有1次，自己场上有这张卡以外的「妖仙兽」怪兽存在的场合以对方场上1张表侧表示的卡为对象才能发动。那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65247798,1))  --"弹回手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e2:SetCountLimit(1)
	e2:SetCondition(c65247798.thcon)
	e2:SetTarget(c65247798.thtg)
	e2:SetOperation(c65247798.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c65247798.regop)
	c:RegisterEffect(e3)
end
-- 过滤函数：手牌中除「妖仙兽 镰壹太刀」以外、可以进行通常召唤的「妖仙兽」怪兽
function c65247798.filter(c)
	return c:IsSetCard(0xb3) and not c:IsCode(65247798) and c:IsSummonable(true,nil)
end
-- 效果①的发动准备（检查手牌中是否存在可召唤的「妖仙兽」怪兽，并设置召唤操作信息）
function c65247798.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张满足过滤条件的「妖仙兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65247798.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：包含1次通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果①的处理（从手牌选择1只「妖仙兽」怪兽进行通常召唤）
function c65247798.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌选择1张满足过滤条件的「妖仙兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c65247798.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 让玩家无视每回合通常召唤次数限制，对选择的怪兽进行通常召唤
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end
-- 过滤函数：自己场上表侧表示的「妖仙兽」怪兽
function c65247798.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- 效果②的发动条件（自己场上存在这张卡以外的「妖仙兽」怪兽）
function c65247798.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除这张卡以外的表侧表示的「妖仙兽」怪兽
	return Duel.IsExistingMatchingCard(c65247798.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤函数：场上表侧表示且能回到手牌的卡
function c65247798.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果②的发动准备（选择对方场上1张表侧表示的卡作为对象，并设置回手牌操作信息）
function c65247798.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c65247798.thfilter(chkc) end
	-- 检查对方场上是否存在至少1张满足过滤条件的表侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(c65247798.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c65247798.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将选中的对象卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理（使作为对象的卡回到持有者手牌）
function c65247798.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果③的注册处理（在召唤成功的场合，注册一个在结束阶段发动的诱发必发效果）
function c65247798.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65247798,2))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(c65247798.rettg)
	e1:SetOperation(c65247798.retop)
	e1:SetReset(RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 效果③的发动准备（设置自身回手牌的操作信息）
function c65247798.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将自身送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果③的处理（使这张卡回到持有者手牌）
function c65247798.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果将这张卡送回持有者的手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
