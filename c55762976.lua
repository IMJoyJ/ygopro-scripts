--グッサリ＠イグニスター
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：连接怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
-- ②：自己的连接怪兽战斗破坏对方怪兽时才能发动。给与对方那只对方怪兽的原本攻击力数值的伤害。
-- ③：自己的连接怪兽和对方怪兽进行战斗的攻击宣言时，把墓地的这张卡除外才能发动。那些双方怪兽的攻击力变成3000。
function c55762976.initial_effect(c)
	-- ①：连接怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55762976,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,55762976)
	e1:SetCondition(c55762976.spcon)
	e1:SetTarget(c55762976.sptg)
	e1:SetOperation(c55762976.spop)
	c:RegisterEffect(e1)
	-- ②：自己的连接怪兽战斗破坏对方怪兽时才能发动。给与对方那只对方怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55762976,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,55762977)
	e2:SetCondition(c55762976.damcon)
	e2:SetTarget(c55762976.damtg)
	e2:SetOperation(c55762976.damop)
	c:RegisterEffect(e2)
	-- ③：自己的连接怪兽和对方怪兽进行战斗的攻击宣言时，把墓地的这张卡除外才能发动。那些双方怪兽的攻击力变成3000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55762976,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,55762978)
	e3:SetCondition(c55762976.atkcon)
	-- 设置发动代价为将墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetOperation(c55762976.atkop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示存在的连接怪兽被战斗破坏
function c55762976.cfilter(c)
	return c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0 and c:IsReason(REASON_BATTLE)
end
-- ①号效果发动条件：确认被破坏的卡中存在满足条件的连接怪兽，且不包含自身
function c55762976.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c55762976.cfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- ①号效果的目标选择与操作信息设置：检查自身能否特殊召唤，并设置特殊召唤的操作信息
function c55762976.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查怪兽区域是否有空位，以及自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，包含自身1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①号效果的处理：若自身仍存在于手卡，则将自身特殊召唤
function c55762976.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果发动条件：自己的连接怪兽战斗破坏对方怪兽，且该对方怪兽原本攻击力大于0
function c55762976.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=nil
	if ec then
		bc=ec:GetBattleTarget()
		e:SetLabelObject(bc)
	end
	return bc and bc:GetBaseAttack()>0 and ec:IsType(TYPE_LINK) and ec:IsControler(tp) and ec:IsRelateToBattle()
		and ec:IsStatus(STATUS_OPPO_BATTLE)
end
-- ②号效果的目标选择与操作信息设置：将战斗破坏的对方怪兽设为效果对象，并设置伤害数值与操作信息
function c55762976.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetLabelObject()
	-- 将战斗破坏的对方怪兽设为效果对象
	Duel.SetTargetCard(bc)
	local dam=bc:GetBaseAttack()
	if dam<0 then dam=0 end
	-- 设置伤害的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的参数为该怪兽的原本攻击力
	Duel.SetTargetParam(dam)
	-- 设置伤害的操作信息，包含对象玩家和伤害数值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- ②号效果的处理：给与对方该对方怪兽原本攻击力数值的伤害
function c55762976.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的被破坏怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获取当前连锁中设定的目标玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetBaseAttack()
		if dam<0 then dam=0 end
		-- 因效果给与目标玩家对应数值的伤害
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
-- ③号效果发动条件：自己的表侧表示连接怪兽和对方的表侧表示怪兽进行战斗的攻击宣言时
function c55762976.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local ac=Duel.GetAttacker()
	-- 获取被攻击的怪兽
	local tc=Duel.GetAttackTarget()
	if not ac:IsControler(tp) then ac,tc=tc,ac end
	return ac and ac:IsControler(tp) and ac:IsFaceup() and ac:IsType(TYPE_LINK) and tc and tc:IsControler(1-tp) and tc:IsFaceup()
end
-- 过滤条件：表侧表示存在且仍处于战斗状态的怪兽
function c55762976.atkfilter(c)
	return c:IsFaceup() and c:IsRelateToBattle()
end
-- ③号效果的处理：将进行战斗的双方怪兽的攻击力变成3000
function c55762976.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local ac=Duel.GetAttacker()
	-- 获取被攻击的怪兽
	local tc=Duel.GetAttackTarget()
	local g=Group.FromCards(ac,tc):Filter(c55762976.atkfilter,nil)
	local gc=g:GetFirst()
	while gc do
		-- 那些双方怪兽的攻击力变成3000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		gc:RegisterEffect(e1)
		gc=g:GetNext()
	end
end
