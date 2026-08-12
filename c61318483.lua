--ゴーストリック・フロスト
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，对方怪兽的直接攻击宣言时才能发动。那只对方怪兽变成里侧守备表示，这张卡从手卡里侧守备表示特殊召唤。
function c61318483.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c61318483.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61318483,0))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c61318483.postg)
	e2:SetOperation(c61318483.posop)
	c:RegisterEffect(e2)
	-- 此外，对方怪兽的直接攻击宣言时才能发动。那只对方怪兽变成里侧守备表示，这张卡从手卡里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61318483,1))  --"变成里侧守备"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c61318483.spcon)
	e3:SetTarget(c61318483.sptg)
	e3:SetOperation(c61318483.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「鬼计」怪兽
function c61318483.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制效果的启用条件：自己场上不存在表侧表示的「鬼计」怪兽（此时不能召唤）
function c61318483.sumcon(e)
	-- 检查自己场上是否不存在表侧表示的「鬼计」怪兽
	return not Duel.IsExistingMatchingCard(c61318483.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 变成里侧守备表示效果的发动检查与靶向函数，限制每回合只能发动一次，并设置改变表示形式的操作信息
function c61318483.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(61318483)==0 end
	c:RegisterFlagEffect(61318483,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：将自身改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果的执行函数，若自身在场上表侧表示则将其转为里侧守备表示
function c61318483.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身改变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 特殊召唤效果的发动条件：对方怪兽直接攻击宣言时
function c61318483.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	-- 检查攻击怪兽是否由对方控制，且攻击对象为空（即直接攻击）
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 特殊召唤效果的发动检查与靶向函数，确认攻击怪兽可转为里侧守备表示、自身可特殊召唤且有可用怪兽区域
function c61318483.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	-- 在发动检查时，确认攻击怪兽可以转为里侧表示，且自己场上有空余的怪兽区域
	if chk==0 then return at:IsCanTurnSet() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置操作信息：将手牌中的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：将攻击怪兽改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,at,1,0,0)
end
-- 特殊召唤效果的执行函数，先将对方攻击怪兽转为里侧守备表示，若成功则将手牌中的这张卡里侧守备表示特殊召唤并向对方确认
function c61318483.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	-- 若攻击怪兽仍由对方控制、处于战斗状态且表侧表示，则将其转为里侧守备表示，并判断是否成功
	if at:IsControler(1-tp) and at:IsRelateToBattle() and at:IsFaceup() and Duel.ChangePosition(at,POS_FACEDOWN_DEFENSE)>0 then
		if not c:IsRelateToEffect(e) then return end
		-- 将这张卡以里侧守备表示特殊召唤到自己场上，并判断是否成功
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
			-- 向对方玩家展示并确认这张里侧特殊召唤的卡
			Duel.ConfirmCards(1-tp,c)
		end
	end
end
