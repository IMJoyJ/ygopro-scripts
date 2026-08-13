--魔鍵憑神－アシュタルトゥ
-- 效果：
-- 8星怪兽×2
-- ①：1回合1次，自己的通常怪兽或者「魔键」怪兽战斗破坏对方怪兽时，把这张卡1个超量素材取除才能发动。给与对方那只破坏的怪兽的原本攻击力数值的伤害。
-- ②：对方主要阶段1次，以持有和自己的场上·墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的对方场上1只怪兽为对象才能发动。这张卡1个超量素材取除，作为对象的怪兽除外。
local s,id,o=GetID()
-- 定义为卡片的初始效果设置函数：为卡添加XYZ召唤手续，并注册①战斗破坏时给伤害的诱发效果和②对方主要阶段除外的即时效果。
function s.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：需要2只8星怪兽作为超量素材叠放才能XYZ召唤。
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- 对应效果原文①：1回合1次，自己的通常怪兽或者「魔键」怪兽战斗破坏对方怪兽时，把这张卡1个超量素材取除才能发动。给与对方那只破坏的怪兽的原本攻击力数值的伤害。此处创建并注册该伤害诱发效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.damcon)
	e1:SetCost(s.damcost)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	-- 对应效果原文②：对方主要阶段1次，以持有和自己的场上·墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的对方场上1只怪兽为对象才能发动。这张卡1个超量素材取除，作为对象的怪兽除外。此处创建并注册该除外即时效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- ①的发动条件：自己的通常怪兽或「魔键」怪兽与对方怪兽战斗并即将把对方怪兽破坏；要求破坏的对方怪兽原本攻击力大于0，己方战斗怪兽为通常怪兽或「魔键」字段，且仍与战斗相关并处于和对方怪兽战斗的状态。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:GetBaseAttack()>0 and ec:IsControler(tp) and (ec:IsType(TYPE_NORMAL) or ec:IsSetCard(0x165))
		and ec:IsRelateToBattle() and ec:IsStatus(STATUS_OPPO_BATTLE)
end
-- ①的发动代价：发动时需要把这张卡1个超量素材取除；chk==0时检测是否有超量素材可取，实际发动时去除1个超量素材。
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①的发动目标处理：将被战斗破坏的对方怪兽设为对象，记录其原本攻击力作为伤害数值，并设定伤害对象为对方玩家。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetLabelObject()
	-- 将被战斗破坏的对方怪兽设置为当前连锁的对象卡，以便后续处理时取得该卡。
	Duel.SetTargetCard(bc)
	local dam=bc:GetBaseAttack()
	-- 将受到伤害的玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将伤害数值记录为连锁对象参数，值为被破坏怪兽的原本攻击力。
	Duel.SetTargetParam(dam)
	-- 设置操作信息：本次连锁将给对方玩家造成dam点伤害，供伤害类效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- ①效果处理：若被破坏的怪兽仍与效果关联，则给对象玩家造成该怪兽原本攻击力数值的伤害；原本攻击力小于0时按0计算。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象卡（即被战斗破坏的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获取连锁中设定的对象玩家，即承受伤害的对方玩家。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetBaseAttack()
		if dam<0 then dam=0 end
		-- 给对象玩家造成dam点效果伤害。
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
-- ②的发动条件：当前必须是对方回合的主要阶段1或主要阶段2（即对方主要阶段），且本卡在怪兽区。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判定当前不是自己回合（Duel.GetTurnPlayer()~=tp）且处于主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤函数：检查我方场上·墓地是否存在表侧表示或在墓地的通常怪兽或「魔键」怪兽，且属性与目标怪兽属性相同。
function s.gfilter(c,att)
	return c:IsAttribute(att) and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165))
		and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 用于选择对象怪兽的过滤：对方场上表侧表示且可以除外的怪兽，且我方场上·墓地存在与其相同属性的通常怪兽或「魔键」怪兽。
function s.filter(c,tp)
	return c:IsFaceup() and c:IsAbleToRemove()
		-- 检查我方场上·墓地是否存在至少1张与对象怪兽相同属性的通常怪兽或「魔键」怪兽（表侧表示或在墓地）。
		and Duel.IsExistingMatchingCard(s.gfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c:GetAttribute())
end
-- ②的发动目标选择：从对方场上选择1只满足条件且可除外的表侧表示怪兽作为对象，同时检查本卡是否有超量素材可去除作为代价。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp) end
	-- 发动合法性检查：对方场上有满足条件的对象怪兽，且本卡有超量素材可以取除作为代价。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp)
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 给玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方场上选择1只满足条件的表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：将选择的对象怪兽以除外方式处理。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果处理：若本卡仍与效果关联且成功取除1个超量素材，并且对象怪兽仍与效果关联，则把对象怪兽表侧表示除外。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
