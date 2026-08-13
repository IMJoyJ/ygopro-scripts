--ウォークライ・ディグニティ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「战吼」怪兽存在的场合，可以从以下效果选择1个发动。
-- ●对方场上的怪兽把效果发动时才能发动。那个效果无效。
-- ●自己·对方的战斗阶段，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个效果无效。
function c47882774.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「战吼」怪兽存在的场合，可以从以下效果选择1个发动。●对方场上的怪兽把效果发动时才能发动。那个效果无效。●自己·对方的战斗阶段，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个效果无效。
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
-- 过滤条件：用于确认自己场上存在表侧表示的「战吼」怪兽卡，作为发动前提的判定条件之一。
function c47882774.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15f)
end
-- 整个发动条件：当对方发动效果且该效果可被无效时，若自己场上有表侧「战吼」怪兽，并满足“对方场上的怪兽效果发动”或“战斗阶段对方发动怪兽·魔法·陷阱效果”的任一情形，本卡才能发动。
function c47882774.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果发动者为对方，且该连锁效果可以被无效，满足无效类效果的基本条件。
	return ep==1-tp and Duel.IsChainDisablable(ev)
		-- 检查自己场上是否存在至少1只表侧表示的「战吼」怪兽，满足①的发动前提。
		and Duel.IsExistingMatchingCard(c47882774.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 对应第一个可选效果：对方场上的怪兽把效果发动时才能发动，即该效果是怪兽效果且从怪兽区域发动。
		and ((re:IsActiveType(TYPE_MONSTER) and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE)
			-- 当前为战斗阶段（战斗阶段开始到战斗阶段结束之间），用于判断第二个可选效果发动时机的阶段范围。
			or (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
				and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))))
end
-- 发动时的处理目标：无选择对象，直接宣告本次发动旨在无效那组连锁，并写入操作信息。
function c47882774.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次操作信息设置为“无效”分类，对象为当前连锁中正在发动的卡（eg），数量为1，供后续处理及卡组效果参照。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理时执行的动作：将目标连锁的效果无效化，完成效果无效的结算。
function c47882774.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.NegateEffect使连锁ev的效果无效，对应“那个效果无效”。
	Duel.NegateEffect(ev)
end
