--ウォークライ・ディグニティ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「战吼」怪兽存在的场合，可以从以下效果选择1个发动。
-- ●对方场上的怪兽把效果发动时才能发动。那个效果无效。
-- ●自己·对方的战斗阶段，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个效果无效。
function c47882774.initial_effect(c)
	-- 创建效果，设置为发动时无效对方效果，且只能在自己场上存在「战吼」怪兽时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47882774,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,47882774+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c47882774.actcon)
	e1:SetTarget(c47882774.acttg)
	e1:SetOperation(c47882774.actop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否存在表侧表示的「战吼」怪兽
function c47882774.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15f)
end
-- 效果发动条件判断，包括对方发动连锁、连锁可被无效、己方场上有「战吼」怪兽，以及满足两种触发条件之一
function c47882774.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否由对方发动且该连锁效果可以被无效
	return ep==1-tp and Duel.IsChainDisablable(ev)
		-- 检查自己场上是否存在至少1张表侧表示的「战吼」怪兽
		and Duel.IsExistingMatchingCard(c47882774.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断连锁是否为对方场上的怪兽效果发动
		and ((re:IsActiveType(TYPE_MONSTER) and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE)
			-- 判断当前阶段是否为战斗阶段（开始到结束）且对方发动的是怪兽或魔法/陷阱卡的效果
			or (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
				and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))))
end
-- 设置效果的目标信息，将被无效的连锁效果作为操作对象
function c47882774.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，标记该效果会无效对方的连锁效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理函数，使连锁效果无效
function c47882774.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用引擎函数使指定连锁的效果无效
	Duel.NegateEffect(ev)
end
