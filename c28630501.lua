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
	-- ②：这张卡以外的自己的「妖仙兽」怪兽给与对方战斗伤害时才能发动。从卡组把「妖仙兽 镰叁太刀」以外的1张「妖仙兽」卡加入手卡。
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
-- 过滤函数，用于筛选手卡中满足条件的「妖仙兽」怪兽（不包括自身）且可通常召唤的卡片。
function c28630501.filter(c)
	return c:IsSetCard(0xb3) and not c:IsCode(28630501) and c:IsSummonable(true,nil)
end
-- 效果处理时的条件判断函数，检查手卡中是否存在满足条件的「妖仙兽」怪兽。
function c28630501.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的「妖仙兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28630501.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁操作信息，表示将要进行召唤操作。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理函数，提示玩家选择一张手卡中的「妖仙兽」怪兽进行通常召唤。
function c28630501.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的「妖仙兽」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手卡中选择一张满足条件的「妖仙兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c28630501.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 对选中的怪兽进行通常召唤。
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end
-- 判断是否满足效果发动条件，即战斗伤害是由己方「妖仙兽」怪兽造成的且不是自身。
function c28630501.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and tc:IsSetCard(0xb3) and tc~=e:GetHandler()
end
-- 过滤函数，用于筛选卡组中满足条件的「妖仙兽」卡（不包括自身）且可加入手牌。
function c28630501.thfilter(c)
	return c:IsSetCard(0xb3) and not c:IsCode(28630501) and c:IsAbleToHand()
end
-- 效果处理时的条件判断函数，检查卡组中是否存在满足条件的「妖仙兽」卡。
function c28630501.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「妖仙兽」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c28630501.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要进行从卡组检索卡牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，提示玩家选择一张卡组中的「妖仙兽」卡加入手牌。
function c28630501.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的「妖仙兽」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的「妖仙兽」卡。
	local g=Duel.SelectMatchingCard(tp,c28630501.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡牌。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 注册一个在召唤成功后触发的效果，用于在结束阶段将自身送回手牌。
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
-- 设置返回手牌效果的处理条件，始终返回true。
function c28630501.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将要将自身送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将自身送回手牌。
function c28630501.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身送回手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
