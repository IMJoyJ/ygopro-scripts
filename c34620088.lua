--ギミック・パペット－シャドーフィーラー
-- 效果：
-- 这张卡不会被战斗破坏。此外，这张卡在墓地存在，对方怪兽的直接攻击让自己受到战斗伤害时才能发动。这张卡从墓地表侧攻击表示特殊召唤，自己受到1000分伤害。「机关傀儡-暗影触摸者」的这个效果1回合只能使用1次。成为超量素材的这张卡被送去墓地的场合，不去墓地从游戏中除外。
function c34620088.initial_effect(c)
	-- 「这张卡不会被战斗破坏。」
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 「此外，这张卡在墓地存在，对方怪兽的直接攻击让自己受到战斗伤害时才能发动。这张卡从墓地表侧攻击表示特殊召唤，自己受到1000分伤害。『机关傀儡-暗影触摸者』的这个效果1回合只能使用1次。」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34620088,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,34620088)
	e2:SetCondition(c34620088.spcon)
	e2:SetTarget(c34620088.sptg)
	e2:SetOperation(c34620088.spop)
	c:RegisterEffect(e2)
	if not c34620088.global_check then
		c34620088.global_check=true
		-- 「成为超量素材的这张卡被送去墓地的场合，不去墓地从游戏中除外。」
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		ge1:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		-- 指定该重定向效果只对卡名为「机关傀儡-暗影触摸者」的卡生效，即当其作为超量素材时也会被此效果覆盖。
		ge1:SetTarget(aux.TargetBoolFunction(Card.IsCode,34620088))
		ge1:SetValue(LOCATION_REMOVED)
		-- 将重定向效果作为全场效果注册（owner为0），使双方场上成为超量素材的该卡被送去墓地时均改为除外。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 特殊召唤的发动条件函数：判定自己受到对方怪兽直接攻击造成的战斗伤害时满足发动条件。
function c34620088.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件为：受到战斗伤害的玩家是本效果控制者tp、造成伤害的怪兽是对方控制（eg中怪兽控制者为1-tp）且攻击目标是空（直接攻击）。
	return ep==tp and eg:GetFirst():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 特殊召唤的发动目标/合法性检查函数：发动时确认自己主要怪兽区有可用格，且墓地中的这张卡可以表侧攻击表示特殊召唤。
function c34620088.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0（发动时）检查自己场上是否有可用的主要怪兽区格子，用于从墓地特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置操作信息：本次效果包含特殊召唤，对象确定为这张卡自身（数量1），用于触发相关时点和检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次效果包含伤害，给玩家tp造成1000点伤害，数值确定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 效果处理函数：若这张卡仍与效果关联，则将其从墓地特殊召唤到己方主要怪兽区，成功后再对自己造成1000点伤害。
function c34620088.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断条件：这张卡仍与效果相关联，且以表侧攻击表示特殊召唤成功（返回非0）时，才执行后续的伤害处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)~=0 then
		-- 对自己（tp）造成1000点效果伤害，伤害原因为效果。
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end
