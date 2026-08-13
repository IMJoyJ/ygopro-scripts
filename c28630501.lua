--妖仙獣 鎌参太刀
-- 效果：
-- 「妖仙兽 镰叁太刀」的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功的场合才能发动。从手卡把「妖仙兽 镰叁太刀」以外的1只「妖仙兽」怪兽召唤。
-- ②：这张卡以外的自己的「妖仙兽」怪兽给与对方战斗伤害时才能发动。从卡组把「妖仙兽 镰叁太刀」以外的1张「妖仙兽」卡加入手卡。
-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
function c28630501.initial_effect(c)
	-- ①：这张卡召唤成功的场合才能发动。从手卡把「妖仙兽 镰叁太刀」以外的1只「妖仙兽」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28630501,0))  --"召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c28630501.sumtg)
	e1:SetOperation(c28630501.sumop)
	c:RegisterEffect(e1)
	-- 「妖仙兽 镰叁太刀」的②的效果1回合只能使用1次。②：这张卡以外的自己的「妖仙兽」怪兽给与对方战斗伤害时才能发动。从卡组把「妖仙兽 镰叁太刀」以外的1张「妖仙兽」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28630501,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,28630501)
	e2:SetCondition(c28630501.thcon)
	e2:SetTarget(c28630501.thtg)
	e2:SetOperation(c28630501.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c28630501.regop)
	c:RegisterEffect(e3)
end
-- 定义①效果的召唤对象筛选条件：必须是「妖仙兽」字段怪兽，不是「妖仙兽 镰叁太刀」自身，且能够进行通常召唤（忽略通常召唤次数限制）。
function c28630501.filter(c)
	return c:IsSetCard(0xb3) and not c:IsCode(28630501) and c:IsSummonable(true,nil)
end
-- ①效果的发动条件与目标设置函数：在发动检查时确认手牌中存在可召唤的符合条件的妖仙兽怪兽，并设置本连锁处理将进行1只怪兽的通常召唤的操作信息。
function c28630501.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认自己手牌中是否存在至少1只满足c28630501.filter条件的怪兽，用于判定①效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28630501.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 登记连锁处理信息：本次效果处理将进行1只怪兽的通常召唤（由于选择怪兽不固定，对象信息为空，数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ①效果的实际处理：先提示玩家选择要召唤的卡，再从手牌中选择1只符合条件的妖仙兽怪兽，选到后将其以不占用通常召唤次数的方式通常召唤上场。
function c28630501.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出选择提示消息，提示内容为“请选择要召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌中选出1张满足filter条件的卡片作为通常召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c28630501.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择出的怪兽进行通常召唤：ignore_count=true表示不消耗本回合的通常召唤次数，nil表示不使用特殊效果，按通常召唤规则上场。
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end
-- ②效果的发动条件判定：战斗伤害事件中，受到伤害的玩家是对方（ep~=tp），造成伤害的怪兽是自己控制的、属于“妖仙兽”字段，且不是这张卡自身，才能发动。
function c28630501.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and tc:IsSetCard(0xb3) and tc~=e:GetHandler()
end
-- 定义②效果检索卡组的筛选条件：必须是“妖仙兽”字段卡，不是“妖仙兽 镰叁太刀”自身，且能够被加入手卡。
function c28630501.thfilter(c)
	return c:IsSetCard(0xb3) and not c:IsCode(28630501) and c:IsAbleToHand()
end
-- ②效果的发动条件与目标设置函数：在发动检查时确认卡组存在可检索的妖仙兽卡，并设置本连锁处理为从卡组将1张卡加入手卡的检索操作。
function c28630501.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认自己卡组中是否存在至少1张满足thfilter条件的卡，用于判定②效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28630501.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记连锁处理信息：本次效果处理将把1张卡从卡组加入手卡（检索目标不定，指定玩家tp的卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：先提示玩家选择要加入手牌的卡，再从卡组选择1张符合条件的妖仙兽卡，加入持有者手牌，并向对方展示加入手牌的卡。
function c28630501.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出选择提示消息，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选出1张满足thfilter条件的卡作为检索对象。
	local g=Duel.SelectMatchingCard(tp,c28630501.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因（REASON_EFFECT）送回其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家（1-tp）确认展示检索加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的注册辅助函数：当这张卡召唤成功时，强制为这张卡注册一个结束阶段回手的效果；该注册过程不会被无效化（EFFECT_FLAG_CANNOT_DISABLE）。
function c28630501.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28630501,2))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(c28630501.rettg)
	e1:SetOperation(c28630501.retop)
	e1:SetReset(RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- ③回手效果的发动条件与目标设置：由于是必定发动，chk==0直接返回true；并设置操作信息为把效果持有者这张卡加入手牌。
function c28630501.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记连锁处理信息：本次效果处理将把这张卡自身（效果持有者）加入持有者手牌，目标确定且数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③回手效果的实际处理：若这张卡仍与当前效果保持关联（未因离场等重置），则将其送回持有者手牌。
function c28630501.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以效果原因送回持有者手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
