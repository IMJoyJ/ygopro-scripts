--超戦士カオス・ソルジャー
-- 效果：
-- 「超战士的仪式」降临。自己对「超战士 混沌战士」1回合只能有1次特殊召唤。
-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「暗黑骑士 盖亚」怪兽特殊召唤。
function c54484652.initial_effect(c)
	c:SetSPSummonOnce(54484652)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件为自身战斗破坏对方怪兽并送去墓地
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
-- 伤害效果的发动准备
function c54484652.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 将被破坏的对方怪兽设为效果处理的对象
	Duel.SetTargetCard(bc)
	local dam=bc:GetBaseAttack()
	if dam<0 then dam=0 end
	-- 将对方玩家设为受到伤害的目标玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将计算出的原本攻击力数值设为伤害参数
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息为给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的实际处理
function c54484652.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的被破坏怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获取当前连锁中设定的目标玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetBaseAttack()
		if dam<0 then dam=0 end
		-- 以效果伤害的方式给与目标玩家对应数值的伤害
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
-- 检查此卡是否因战斗破坏，或者在己方场上被对方的效果破坏并送去墓地
function c54484652.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
end
-- 过滤条件：属于「暗黑骑士 盖亚」系列且可以特殊召唤的怪兽
function c54484652.spfilter(c,e,tp)
	return c:IsSetCard(0xbd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备
function c54484652.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方怪兽区域是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、卡组、墓地是否存在至少1只满足条件的「暗黑骑士 盖亚」怪兽
		and Duel.IsExistingMatchingCard(c54484652.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从手卡、卡组、墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 特殊召唤效果的实际处理
function c54484652.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时己方怪兽区域没有空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡、卡组、墓地中选择1只满足条件且不受王家长眠之谷影响的「暗黑骑士 盖亚」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c54484652.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
