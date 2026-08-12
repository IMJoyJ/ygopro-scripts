--ギミック・パペット－シャドーフィーラー
-- 效果：
-- 这张卡不会被战斗破坏。此外，这张卡在墓地存在，对方怪兽的直接攻击让自己受到战斗伤害时才能发动。这张卡从墓地表侧攻击表示特殊召唤，自己受到1000分伤害。「机关傀儡-暗影触摸者」的这个效果1回合只能使用1次。成为超量素材的这张卡被送去墓地的场合，不去墓地从游戏中除外。
function c34620088.initial_effect(c)
	-- 这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 此外，这张卡在墓地存在，对方怪兽的直接攻击让自己受到战斗伤害时才能发动。这张卡从墓地表侧攻击表示特殊召唤，自己受到1000分伤害。「机关傀儡-暗影触摸者」的这个效果1回合只能使用1次。成为超量素材的这张卡被送去墓地的场合，不去墓地从游戏中除外。
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
		-- 成为超量素材的这张卡被送去墓地的场合，不去墓地从游戏中除外。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		ge1:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		-- 设置效果目标为超量素材区域的此卡
		ge1:SetTarget(aux.TargetBoolFunction(Card.IsCode,34620088))
		ge1:SetValue(LOCATION_REMOVED)
		-- 将该效果注册到全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 效果条件函数：判断是否为对方怪兽直接攻击造成的战斗伤害且自己受到伤害
function c34620088.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽的直接攻击让自己受到战斗伤害
	return ep==tp and eg:GetFirst():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果处理函数：判断是否满足特殊召唤条件
function c34620088.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置特殊召唤的卡为当前处理的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置造成1000分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 效果处理函数：执行特殊召唤并造成伤害
function c34620088.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡是否还在场上且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)~=0 then
		-- 对自身造成1000分伤害
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end
