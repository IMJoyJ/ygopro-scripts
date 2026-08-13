--フェアリー・アーチャー
-- 效果：
-- 自己的主要阶段时，可以给与对方基本分自己场上表侧表示存在的光属性怪兽每1只400分伤害。这个效果发动的回合这张卡不能攻击。「妖精弓手」的效果1回合只能使用1次。
function c48742406.initial_effect(c)
	-- 「自己的主要阶段时，可以给与对方基本分自己场上表侧表示存在的光属性怪兽每1只400分伤害。这个效果发动的回合这张卡不能攻击。「妖精弓手」的效果1回合只能使用1次。」
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
-- 效果发动代价处理：确认这张卡本回合尚未进行过攻击宣言；通过后给自己附加不能攻击的誓约效果（直到回合结束且不会被无效）。
function c48742406.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 目标处理：本效果不取卡片对象，将对方玩家设为对象玩家，并登记伤害类操作信息。
function c48742406.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设为当前连锁的效果对象玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 登记操作信息：该效果将造成伤害，对象为对方玩家，具体数值在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 过滤函数：判定卡片是否表侧表示且属性为光属性。
function c48742406.dfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果处理：获取对象玩家，统计自己场上表侧表示光属性怪兽的数量，并按每只400点给予伤害。
function c48742406.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回连锁中登记的对象玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 统计自己场上表侧表示的光属性怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c48742406.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 给予对象玩家数量×400点的效果伤害。
	Duel.Damage(p,ct*400,REASON_EFFECT)
end
