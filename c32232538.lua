--DDD智慧王ソロモン
-- 效果：
-- 4星「DD」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「DD」卡加入手卡。
-- ②：这张卡被除外的场合，以自己场上1只「DD」效果怪兽为对象才能发动。那只效果怪兽直到回合结束时得到以下效果。
-- ●这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤手续、启用复活限制，并注册两个效果
function s.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，要求使用满足条件的4星怪兽叠放，最少2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xaf),4,2)
	c:EnableReviveLimit()
	-- 效果①：把这张卡1个超量素材取除才能发动。从卡组把1张「DD」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡被除外的场合，以自己场上1只「DD」效果怪兽为对象才能发动。那只效果怪兽直到回合结束时得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"赋予效果"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 效果①的费用处理函数，检查并移除1个超量素材
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤器，筛选「DD」卡且能加入手牌
function s.thfilter(c)
	return c:IsSetCard(0xaf) and c:IsAbleToHand()
end
-- 效果①的发动条件判断函数，检查卡组是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要从卡组检索的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动处理函数，选择并把卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的目标过滤器，筛选自己场上正面表示的「DD」效果怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsSetCard(0xaf)
end
-- 效果②的发动条件判断函数，选择满足条件的目标怪兽
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
	-- 检查场上是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的目标怪兽
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的发动处理函数，为选中的怪兽添加战斗破坏时的伤害效果
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 为选中的怪兽添加战斗破坏时的伤害效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"伤害效果（DDD 智慧王 所罗门）"
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetRange(LOCATION_MZONE)
		-- 设置战斗破坏时触发的条件
		e1:SetCondition(aux.bdcon)
		e1:SetTarget(s.damtg)
		e1:SetOperation(s.damop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"「DDD 智慧王 所罗门」效果适用中"
	end
end
-- 伤害效果的发动条件判断函数，设置伤害值和目标玩家
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetBattleTarget():GetBaseAttack()
	if dam<0 then dam=0 end
	-- 设置伤害目标玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害值参数
	Duel.SetTargetParam(dam)
	if dam>0 then
		-- 设置连锁操作信息，指定将要造成伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- 伤害效果的发动处理函数，对目标玩家造成伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
