--超戦士カオス・ソルジャー
-- 效果：
-- 「超战士的仪式」降临。自己对「超战士 混沌战士」1回合只能有1次特殊召唤。
-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「暗黑骑士 盖亚」怪兽特殊召唤。
function c54484652.initial_effect(c)
	-- 记录该卡记载了「超战士的仪式」的卡名
	aux.AddCodeList(c,14094090)
	c:SetSPSummonOnce(54484652)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动条件为这张卡战斗破坏对方怪兽并送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c54484652.damtg)
	e1:SetOperation(c54484652.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「暗黑骑士 盖亚」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c54484652.spcon)
	e2:SetTarget(c54484652.sptg)
	e2:SetOperation(c54484652.spop)
	c:RegisterEffect(e2)
end
-- 伤害效果的的Target函数：把战斗破坏的对方怪兽作为效果的对象，并设置伤害的操作信息
function c54484652.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 将战斗破坏的对方怪兽设为连锁的对象
	Duel.SetTargetCard(bc)
	local dam=bc:GetBaseAttack()
	if dam<0 then dam=0 end
	-- 设置给与伤害的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置给与伤害的数值为该怪兽的原本攻击力
	Duel.SetTargetParam(dam)
	-- 设置操作信息为给与对方原本攻击力数值 of 伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的Operation函数：给与对方该战斗破坏怪兽原本攻击力数值的伤害
function c54484652.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的对象怪兽（即战斗破坏送去墓地的对方怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获取连锁中的对象玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetBaseAttack()
		if dam<0 then dam=0 end
		-- 给与对方原本攻击力数值的伤害
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
-- 特殊召唤效果的Condition函数：检测这张卡是否被战斗破坏，或者因对方效果破坏并送去墓地
function c54484652.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
end
-- 特殊召唤的卡片过滤函数：检测是否为「暗黑骑士 盖亚」怪兽且可以特殊召唤
function c54484652.spfilter(c,e,tp)
	return c:IsSetCard(0xbd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的Target函数：检测己方主要怪兽区域是否有空位，且手卡、卡组、墓地是否存在可特殊召唤的「暗黑骑士 盖亚」怪兽，并设置操作信息
function c54484652.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在检测阶段，检查己方主要怪兽区域是否还有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的手卡、卡组、墓地是否存在至少1张满足特殊召唤条件的「暗黑骑士 盖亚」怪兽
		and Duel.IsExistingMatchingCard(c54484652.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息为从手卡、卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 特殊召唤效果的Operation函数：从自己的手卡、卡组、墓地选择1只「暗黑骑士 盖亚」怪兽特殊召唤
function c54484652.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的空位，若无可特殊召唤的位置则直接结束效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡、卡组、墓地中选择1只不受王谷影响且满足条件的「暗黑骑士 盖亚」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c54484652.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
