--B・F－神事弓のサチ
-- 效果：
-- 昆虫族调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。这张卡当作调整使用。
-- ②：1回合1次，让自己场上1张永续魔法卡回到手卡才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「蜂军」怪兽召唤。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。给与对方为自己的除外状态的「蜂军」怪兽数量×100伤害。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、当作调整的效果、增加召唤权的效果以及送墓伤害效果。
function s.initial_effect(c)
	-- 设置同调召唤手续：昆虫族调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"当作调整使用"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.tncon)
	e1:SetTarget(s.tntg)
	e1:SetOperation(s.tnop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，让自己场上1张永续魔法卡回到手卡才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「蜂军」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"召唤"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.excost)
	e2:SetTarget(s.extg)
	e2:SetOperation(s.exop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为同调素材送去墓地的场合才能发动。给与对方为自己的除外状态的「蜂军」怪兽数量×100伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- 检查发动条件：这张卡是否成功进行同调召唤。
function s.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 检查发动目标：这张卡当前是否不具有调整属性。
function s.tntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsType(TYPE_TUNER) end
end
-- 效果处理：使这张卡在场上表侧表示存在期间当作调整怪兽使用。
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsType(TYPE_TUNER) then
		-- 这张卡当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 过滤条件：自己场上表侧表示、可以回到手牌的永续魔法卡。
function s.cfilter(c)
	return c:IsFaceup() and c:IsAbleToHandAsCost()
		and bit.band(c:GetType(),TYPE_CONTINUOUS+TYPE_SPELL)==TYPE_CONTINUOUS+TYPE_SPELL
end
-- 检查并执行发动代价：本回合未发动过此效果，且将自己场上1张永续魔法卡回到手牌。
function s.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未获得过此召唤权，且场上是否存在可回到手牌的永续魔法卡。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择1张符合条件的永续魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选中的卡片作为发动代价送回持有者手牌。
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 检查发动目标：玩家当前是否可以进行通常召唤，且是否可以获得额外的召唤权。
function s.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能进行通常召唤以及是否能增加通常召唤次数。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) end
end
-- 效果处理：为玩家注册一个本回合内可以额外通常召唤1只「蜂军」怪兽的效果，并设置已使用该效果的标记。
function s.exop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「蜂军」怪兽召唤。/给与对方为自己的除外状态的「蜂军」怪兽数量×100伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))  --"使用「蜂军-神事弓之幸矢蜂」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(s.estg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将增加召唤权的效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个本回合已获得该额外召唤权的标记，持续到回合结束。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤额外召唤的目标：必须是「蜂军」怪兽。
function s.estg(e,c)
	return c:IsSetCard(0x12f)
end
-- 检查发动条件：这张卡作为同调素材送去墓地。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤条件：表侧表示除外状态的「蜂军」怪兽。
function s.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12f) and c:IsType(TYPE_MONSTER)
end
-- 检查发动目标：计算除外状态的「蜂军」怪兽数量并确定伤害数值，设置对方玩家为效果处理对象，并注册伤害操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算伤害值：除外状态的「蜂军」怪兽数量乘以100。
	local dam=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_REMOVED,0,nil)*100
	if chk==0 then return dam>0 end
	-- 将对方玩家设为伤害效果的目标玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁的操作信息，分类为伤害，目标为对方玩家，数值为计算出的伤害值。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理：计算除外状态的「蜂军」怪兽数量，并给与对方玩家对应数值的伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算除外状态的「蜂军」怪兽数量乘以100作为最终伤害值。
	local dam=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_REMOVED,0,nil)*100
	-- 获取当前连锁中设定的目标玩家。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 对目标玩家造成计算出的效果伤害。
	Duel.Damage(p,dam,REASON_EFFECT)
end
