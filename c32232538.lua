--DDD智慧王ソロモン
-- 效果：
-- 4星「DD」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「DD」卡加入手卡。
-- ②：这张卡被除外的场合，以自己场上1只「DD」效果怪兽为对象才能发动。那只效果怪兽直到回合结束时得到以下效果。
-- ●这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
local s,id,o=GetID()
-- 初始化函数：为这张卡设定XYZ召唤手续、苏生限制，并注册①检索效果和②赋予效果。
function s.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：使用等级4的「DD」怪兽2只作为超量素材叠放召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xaf),4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「DD」卡加入手卡。
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
	-- ②：这张卡被除外的场合，以自己场上1只「DD」效果怪兽为对象才能发动。那只效果怪兽直到回合结束时得到以下效果。
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
-- ①效果的发动代价：chk阶段检测能否从这张卡移除1个超量素材作为代价；发动时实际移除1个超量素材。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义检索筛选条件：卡名属于「DD」字段且能够加入手卡的卡。
function s.thfilter(c)
	return c:IsSetCard(0xaf) and c:IsAbleToHand()
end
-- ①效果的目标判定：满足发动条件（卡组存在「DD」卡）时，设定处理时从卡组将1张「DD」卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组是否存在至少1张满足筛选条件的「DD」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定本次效果处理的操作信息：从卡组将1张卡加入手卡（用于连锁判定等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：提示选择要加入手牌的卡，从卡组选1张「DD」卡加入手牌，并向对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张满足s.thfilter条件的「DD」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果对象的过滤条件：自己场上表侧表示、效果怪兽且属于「DD」字段。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsSetCard(0xaf)
end
-- ②效果的目标处理：可选择自己场上1只表侧表示的「DD」效果怪兽为对象；若chkc则验证对象合法性。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
	-- 检测是否存在至少1只可成为②效果对象的「DD」效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出“请选择效果的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的「DD」效果怪兽作为对象（取对象）。
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：给被选中的怪兽赋予“战斗破坏怪兽时给对方原攻击力数值伤害”的效果，并持续到回合结束。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- ●这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"伤害效果（DDD 智慧王 所罗门）"
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetRange(LOCATION_MZONE)
		-- 赋予效果的发动条件：仅在拥有该效果的怪兽进行战斗破坏怪兽时满足（aux.bdcon）。
		e1:SetCondition(aux.bdcon)
		e1:SetTarget(s.damtg)
		e1:SetOperation(s.damop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"「DDD 智慧王 所罗门」效果适用中"
	end
end
-- 伤害效果的目标设定：取被战斗破坏怪兽的原本攻击力作为伤害值，伤害对象为对方；负值按0处理。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetBattleTarget():GetBaseAttack()
	if dam<0 then dam=0 end
	-- 设定伤害对象为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设定伤害数值为被战斗破坏怪兽的原本攻击力。
	Duel.SetTargetParam(dam)
	if dam>0 then
		-- 若伤害值大于0，设置本次操作信息为伤害效果。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- 伤害效果处理：从连锁信息中取得对象玩家和伤害值，给对方造成效果伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中读取之前设定的对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给予玩家p造成d点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
