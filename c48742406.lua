--フェアリー・アーチャー
-- 效果：
-- 自己的主要阶段时，可以给与对方基本分自己场上表侧表示存在的光属性怪兽每1只400分伤害。这个效果发动的回合这张卡不能攻击。「妖精弓手」的效果1回合只能使用1次。
function c48742406.initial_effect(c)
	-- 效果原文：自己的主要阶段时，可以给与对方基本分自己场上表侧表示存在的光属性怪兽每1只400分伤害。这个效果发动的回合这张卡不能攻击。「妖精弓手」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48742406,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,48742406)
	e1:SetCost(c48742406.damcost)
	e1:SetTarget(c48742406.damtg)
	e1:SetOperation(c48742406.damop)
	c:RegisterEffect(e1)
end
-- 规则层面：检查此卡在本回合是否已经宣布过攻击，若未，则使此卡在本回合不能攻击。
function c48742406.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 规则层面：设置此卡在本回合不能攻击的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 规则层面：设置连锁处理时的目标玩家为对方玩家。
function c48742406.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：将目标玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 规则层面：设置本次连锁操作为伤害效果，对象为对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 规则层面：定义过滤函数，用于筛选场上表侧表示存在的光属性怪兽。
function c48742406.dfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 规则层面：计算满足条件的光属性怪兽数量，并对对方造成该数量乘以400的伤害。
function c48742406.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁的目标玩家（即对方玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 规则层面：统计自己场上表侧表示存在的光属性怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c48742406.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 规则层面：对目标玩家造成指定数值的伤害，伤害来源为效果。
	Duel.Damage(p,ct*400,REASON_EFFECT)
end
