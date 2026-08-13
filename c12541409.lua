--インフェルニティ・サプレッション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己手卡是0张的场合，这张卡在盖放的回合也能发动。
-- ①：自己场上有「永火」怪兽存在，对方把怪兽的效果发动时才能发动。那个效果无效。那之后，可以给与对方那只怪兽的等级×100伤害。
function c12541409.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「永火」怪兽存在，对方把怪兽的效果发动时才能发动。那个效果无效。那之后，可以给与对方那只怪兽的等级×100伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12541409,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,12541409+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c12541409.condition)
	e1:SetTarget(c12541409.target)
	e1:SetOperation(c12541409.activate)
	c:RegisterEffect(e1)
	-- 自己手卡是0张的场合，这张卡在盖放的回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12541409,2))  --"适用「永火压制」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(c12541409.actcon)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选出表侧表示且字段为「永火」（0xb）的怪兽，用于检查自己场上是否存在符合条件的「永火」怪兽。
function c12541409.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb)
end
-- 发动条件判定：己方场上有表侧「永火」怪兽、对方发动了怪兽效果、且该连锁效果能被无效时，才允许发动这张卡。
function c12541409.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方怪兽区不存在符合条件的表侧「永火」怪兽，则不满足发动条件，直接返回 false（结束条件判断）。
	if not Duel.IsExistingMatchingCard(c12541409.confilter,tp,LOCATION_MZONE,0,1,nil) then return end
	-- 进一步确认发动条件：连锁的发动者是对方（ep==1-tp）、被连锁的效果是怪兽效果（re:IsActiveType(TYPE_MONSTER)）、且该效果可以被无效（Duel.IsChainDisablable(ev)）。
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 目标处理：该效果不取对象，只要满足条件即可发动；在发动时登记操作信息，表示要将对方发动的那个怪兽效果无效。
function c12541409.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将当前连锁的触发效果（eg，即对方发动的那个怪兽效果）设为将要被无效的对象，category 为 CATEGORY_DISABLE，数量为1，以便其他卡效果联动判定。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理：取得对方发动那只怪兽，先无效其效果；如果无效成功且该怪兽等级≥1，则询问是否给予伤害，选择是则造成等级×100的伤害。
function c12541409.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 判断分支：只有对方怪兽效果被成功无效、该怪兽拥有等级且玩家选择给予伤害时，才执行后续的伤害处理。
	if Duel.NegateEffect(ev) and rc:IsLevelAbove(1) and Duel.SelectYesNo(tp,aux.Stringid(12541409,1)) then  --"是否给与伤害？"
		-- 中断当前效果处理，使无效效果的结算与后续伤害结算分成两段处理，避免二者被视作同一时点。
		Duel.BreakEffect()
		local lv=rc:GetLevel()
		if not rc:IsRelateToEffect(re) then lv=rc:GetOriginalLevel() end
		-- 给与对方玩家那只怪兽当前等级×100的效果伤害（实际伤害值受其他效果影响，但此处直接调用伤害处理）。
		Duel.Damage(1-tp,lv*100,REASON_EFFECT)
	end
end
-- 「盖放回合可发动」效果的发动条件：该卡控制者的手牌数量为0。
function c12541409.actcon(e)
	-- 检查效果控制者（e:GetHandlerPlayer()）手牌区域（LOCATION_HAND）的卡数是否等于0，是则满足“手卡是0张”的条件。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
