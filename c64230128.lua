--暗黒神殿ザララーム
-- 效果：
-- ①：只要自己场上有把「光之圣剑 丹内尔」装备的怪兽存在，对方在战斗阶段不能把效果发动。
-- ②：1回合1次，自己的「勇者衍生物」战斗破坏对方怪兽时才能发动。给与对方那只对方怪兽的原本攻击力数值的伤害。
-- ③：这张卡的②的效果发动的回合的自己主要阶段才能发动1次。从自己的卡组·墓地选「暗黑神殿 扎拉拉姆」以外的1张有「勇者衍生物」的衍生物名记述的场地魔法卡加入手卡。
function c64230128.initial_effect(c)
	-- 注册卡片记述了「勇者衍生物」的卡片密码。
	aux.AddCodeList(c,3285552)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要自己场上有把「光之圣剑 丹内尔」装备的怪兽存在，对方在战斗阶段不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c64230128.actlimcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己的「勇者衍生物」战斗破坏对方怪兽时才能发动。给与对方那只对方怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c64230128.damcon)
	e2:SetTarget(c64230128.damtg)
	e2:SetOperation(c64230128.damop)
	c:RegisterEffect(e2)
	-- ③：这张卡的②的效果发动的回合的自己主要阶段才能发动1次。从自己的卡组·墓地选「暗黑神殿 扎拉拉姆」以外的1张有「勇者衍生物」的衍生物名记述的场地魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c64230128.thcon)
	e3:SetTarget(c64230128.thtg)
	e3:SetOperation(c64230128.thop)
	c:RegisterEffect(e3)
end
-- 过滤自身装备了「光之圣剑 丹内尔」的怪兽。
function c64230128.actlimfilter(c)
	return c:GetEquipCount()>0 and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,65952776)
end
-- 对方在战斗阶段不能把效果发动的条件：当前为战斗阶段，且自己场上存在装备了「光之圣剑 丹内尔」的怪兽。
function c64230128.actlimcon(e)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	local tp=e:GetHandlerPlayer()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
		-- 检查自己场上是否存在至少1只满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c64230128.actlimfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 伤害效果的发动条件：自己的「勇者衍生物」战斗破坏对方怪兽。
function c64230128.damcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsCode(3285552) and rc:IsControler(tp)
end
-- 伤害效果的靶向处理：将被战斗破坏的对方怪兽设为效果处理对象，并设置给与对方其原本攻击力数值伤害的操作信息。
function c64230128.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=eg:GetFirst()
	local bc=c:GetBattleTarget()
	-- 将被战斗破坏的对方怪兽设置为当前连锁的效果处理对象。
	Duel.SetTargetCard(bc)
	local dam=bc:GetBaseAttack()
	if dam<0 then dam=0 end
	-- 将对方玩家设置为受到伤害的对象玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将计算出的原本攻击力数值设置为伤害参数。
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息为：给与对方玩家对应数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的执行：给与对方该怪兽原本攻击力数值的伤害，并给这张卡注册已发动过②效果的标记。
function c64230128.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被设为对象的怪兽（即被战斗破坏的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获取当前连锁中设定的对象玩家和伤害数值。
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 以效果伤害的形式给与对象玩家对应的伤害。
		Duel.Damage(p,d,REASON_EFFECT)
	end
	c:RegisterFlagEffect(64230128,RESET_PHASE+PHASE_END,0,1)
end
-- 检索效果的发动条件：这张卡的②的效果发动的回合的自己主要阶段。
function c64230128.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡是否在当前回合发动过②效果，且当前是否为主要阶段2。
	return e:GetHandler():GetFlagEffect(64230128)>0 and Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤卡组·墓地中「暗黑神殿 扎拉拉姆」以外的、有「勇者衍生物」记述的场地魔法卡。
function c64230128.thfilter(c)
	-- 检查卡片是否记述了「勇者衍生物」且是场地魔法卡，且不是本名卡，并且可以加入手卡。
	return aux.IsCodeListed(c,3285552) and c:IsType(TYPE_FIELD) and not c:IsCode(64230128) and c:IsAbleToHand()
end
-- 检索效果的靶向处理：检查卡组或墓地是否存在满足条件的卡，并设置将卡加入手卡的操作信息。
function c64230128.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地中是否存在至少1张满足条件的场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c64230128.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组或墓地将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索效果的执行：从卡组或墓地选择1张满足条件的场地魔法卡加入手卡，并给对方确认。
function c64230128.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件且不受「王家长眠之谷」影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c64230128.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
