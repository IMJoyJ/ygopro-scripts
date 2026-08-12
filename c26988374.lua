--魔鍵憑神－アシュタルトゥ
-- 效果：
-- 8星怪兽×2
-- ①：1回合1次，自己的通常怪兽或者「魔键」怪兽战斗破坏对方怪兽时，把这张卡1个超量素材取除才能发动。给与对方那只破坏的怪兽的原本攻击力数值的伤害。
-- ②：对方主要阶段1次，以持有和自己的场上·墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的对方场上1只怪兽为对象才能发动。这张卡1个超量素材取除，作为对象的怪兽除外。
local s,id,o=GetID()
-- 初始化效果，设置XYZ召唤手续、启用复活限制，并注册两个诱发效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续，使用8星怪兽叠放2只
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己的通常怪兽或者「魔键」怪兽战斗破坏对方怪兽时，把这张卡1个超量素材取除才能发动。给与对方那只破坏的怪兽的原本攻击力数值的伤害。
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
	-- ②：对方主要阶段1次，以持有和自己的场上·墓地的通常怪兽或者「魔键」怪兽的其中任意种相同属性的对方场上1只怪兽为对象才能发动。这张卡1个超量素材取除，作为对象的怪兽除外。
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
-- 判断是否满足效果①的发动条件，即己方的通常怪兽或魔键怪兽战斗破坏对方怪兽
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:GetBaseAttack()>0 and ec:IsControler(tp) and (ec:IsType(TYPE_NORMAL) or ec:IsSetCard(0x165))
		and ec:IsRelateToBattle() and ec:IsStatus(STATUS_OPPO_BATTLE)
end
-- 支付效果①的费用，将自身1个超量素材取除
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果①的目标和操作信息，将被破坏怪兽设为目标并准备造成伤害
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetLabelObject()
	-- 将被破坏的怪兽设为连锁对象
	Duel.SetTargetCard(bc)
	local dam=bc:GetBaseAttack()
	-- 设置伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害值为被破坏怪兽的原本攻击力
	Duel.SetTargetParam(dam)
	-- 设置操作信息为造成伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行效果①的处理，对对方造成伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获取连锁对象玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetBaseAttack()
		if dam<0 then dam=0 end
		-- 对目标玩家造成指定数值的伤害
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
-- 判断是否满足效果②的发动条件，即在对方主要阶段发动
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前阶段是否为对方的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤函数，用于判断场上或墓地的怪兽是否具有指定属性且为通常怪兽或魔键怪兽
function s.gfilter(c,att)
	return c:IsAttribute(att) and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165))
		and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 过滤函数，用于判断对方场上是否可以除外的怪兽
function s.filter(c,tp)
	return c:IsFaceup() and c:IsAbleToRemove()
		-- 检查是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.gfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c:GetAttribute())
end
-- 设置效果②的目标选择条件，选择对方场上满足条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp) end
	-- 检查是否满足效果②的发动条件，即是否存在可除外的怪兽和足够的超量素材
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp)
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息为除外效果
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行效果②的处理，将目标怪兽除外
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) then
		-- 将目标怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
