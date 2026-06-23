--ダメージ・トランスレーション
-- 效果：
-- 这个回合自己受到的效果伤害变成一半数值。这个回合的结束阶段时，和受到的效果伤害次数相同数量在自己场上把「幽灵衍生物」（恶魔族·暗·1星·攻/守0）守备表示特殊召唤。
function c35268887.initial_effect(c)
	-- 这个回合自己受到的效果伤害变成一半数值。这个回合的结束阶段时，和受到的效果伤害次数相同数量在自己场上把「幽灵衍生物」（恶魔族·暗·1星·攻/守0）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c35268887.activate)
	c:RegisterEffect(e1)
	if not c35268887.global_check then
		c35268887.global_check=true
		c35268887[0]=0
		c35268887[1]=0
		-- 检测到玩家受到效果伤害时，记录该玩家受到的效果伤害次数。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(c35268887.checkop)
		-- 将效果ge1注册给全局环境，使其在场上的伤害事件发生时触发。
		Duel.RegisterEffect(ge1,0)
		-- 在每个玩家的抽卡阶段开始时，将记录的伤害次数清零。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c35268887.clear)
		-- 将效果ge2注册给全局环境，使其在每个玩家的抽卡阶段开始时触发。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 当玩家受到效果伤害时，增加该玩家的伤害计数。
function c35268887.checkop(e,tp,eg,ep,ev,re,r,rp)
	if bit.band(r,REASON_EFFECT)~=0 then
		c35268887[ep]=c35268887[ep]+1
	end
end
-- 在每个玩家的抽卡阶段开始时，将伤害计数清零。
function c35268887.clear(e,tp,eg,ep,ev,re,r,rp)
	c35268887[0]=0
	c35268887[1]=0
end
-- 发动时，设置自身受到的效果伤害减半；并设置在结束阶段触发的特殊召唤效果。
function c35268887.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 设置自身受到的效果伤害减半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c35268887.val)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将效果e1注册给玩家，使其在场上的效果伤害发生时触发。
	Duel.RegisterEffect(e1,tp)
	-- 设置在结束阶段触发的特殊召唤效果。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(35268887,0))  --"特殊召唤Token"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetTarget(c35268887.tokentg)
	e2:SetOperation(c35268887.tokenop)
	e2:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将效果e2注册给玩家，使其在结束阶段触发。
	Duel.RegisterEffect(e2,tp)
end
-- 当受到效果伤害时，将伤害值减半。
function c35268887.val(e,re,dam,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then
		return math.floor(dam/2)
	else return dam end
end
-- 判断是否可以特殊召唤衍生物：伤害次数大于0，且未被青眼精灵龙效果限制，且场上空位足够，且可以特殊召唤幽灵衍生物。
function c35268887.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=c35268887[tp]
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
		-- 判断场上是否有足够的空位来特殊召唤衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		-- 判断是否可以特殊召唤幽灵衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,35268888,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：本次处理将特殊召唤衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	-- 设置操作信息：本次处理将特殊召唤幽灵衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
-- 判断是否可以执行特殊召唤：伤害次数大于1且被青眼精灵龙效果限制，或场上空位不足，或无法特殊召唤幽灵衍生物。
function c35268887.tokenop(e,tp,eg,ep,ev,re,r,rp)
	local ct=c35268887[tp]
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if (ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133))
		-- 判断场上是否有足够的空位来特殊召唤衍生物。
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<ct
		-- 判断是否可以特殊召唤幽灵衍生物。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,35268888,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then return end
	for i=1,ct do
		-- 创建幽灵衍生物。
		local token=Duel.CreateToken(tp,35268888)
		-- 将幽灵衍生物特殊召唤到场上。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
