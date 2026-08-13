--寄生虫パラサイド
-- 效果：
-- 反转：把这张卡表面向上混进对方卡组洗切。对方抽到这张卡时，这张卡在对方场上表侧守备表示特殊召唤，给与对方基本分1000分伤害。之后，只要这张卡表侧表示在场上存在，对方场上表侧表示存在的怪兽全部变成昆虫族。
function c27911549.initial_effect(c)
	-- 启用卡组翻转检测的全局标记，使卡在卡组中的表侧/里侧状态可被追踪，用于实现这张卡表面向上混入对方卡组。
	Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
	-- 反转：把这张卡表面向上混进对方卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27911549,0))  --"进入对方卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c27911549.target)
	e1:SetOperation(c27911549.operation)
	c:RegisterEffect(e1)
end
-- 反转效果的发动条件判定：无不发条件，合法即可发动；同时登记将这张卡送回卡组的操作信息。
function c27911549.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息：这张卡将被送回卡组（数量1，目标玩家0，位置为卡组），供相关效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 反转效果处理：若这张卡仍与效果相关且未被战斗破坏，则将其送回对方卡组并洗切，使其表面向上；若成功在卡组中，则再给这张卡注册一个“对方抽到这张卡时特殊召唤并造成伤害”的诱发效果。
function c27911549.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_BATTLE_DESTROYED) then return end
	-- 以效果原因把这张卡送到对方（1-tp）的卡组，SEQ_DECKSHUFFLE表示洗牌前暂时放在底端，并标记需要洗卡组。
	Duel.SendtoDeck(c,1-tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if not c:IsLocation(LOCATION_DECK) then return end
	-- 洗切对方（1-tp）的卡组，使正面朝上的这张卡随机混入卡组。
	Duel.ShuffleDeck(1-tp)
	c:ReverseInDeck()
	-- 对方抽到这张卡时，这张卡在对方场上表侧守备表示特殊召唤，给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27911549,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DRAW)
	e1:SetTarget(c27911549.sptg)
	e1:SetOperation(c27911549.spop)
	e1:SetReset(RESET_EVENT+0x1de0000)
	c:RegisterEffect(e1)
end
-- 抽卡诱发效果的发动条件：这张卡仍与效果相关（即在对方卡组中且正面朝上），并设置特殊召唤的操作信息。
function c27911549.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	-- 设置操作信息：这张卡将被特殊召唤（数量1，目标玩家0），供相关效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 诱发效果处理：若此卡仍与效果相关，则将其表侧守备表示特殊召唤到对方场上；成功后给对方1000伤害，并注册一个永续效果使对方场上表侧怪兽变成昆虫族。
function c27911549.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤到抽到这张卡的玩家（即对方）场上，并判断是否召唤成功。
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
			-- 给与对方（抽到这张卡的玩家）1000点效果伤害。
			Duel.Damage(tp,1000,REASON_EFFECT)
			-- 之后，只要这张卡表侧表示在场上存在，对方场上表侧表示存在的怪兽全部变成昆虫族。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,LOCATION_MZONE,0)
			e1:SetValue(RACE_INSECT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
