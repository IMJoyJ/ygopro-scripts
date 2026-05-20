--重爆撃禽 ボム・フェネクス
-- 效果：
-- 机械族怪兽＋炎族怪兽
-- 自己的主要阶段时，可以给与对方基本分场上存在的卡每1张300分伤害。这个效果发动的回合这张卡不能攻击。这个效果1回合只能使用1次。
function c6602300.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为机械族怪兽和炎族怪兽各1只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),aux.FilterBoolFunction(Card.IsRace,RACE_PYRO),true)
	-- 自己的主要阶段时，可以给与对方基本分场上存在的卡每1张300分伤害。这个效果发动的回合这张卡不能攻击。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6602300,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c6602300.damcost)
	e2:SetTarget(c6602300.damtg)
	e2:SetOperation(c6602300.damop)
	c:RegisterEffect(e2)
end
-- 检查自身本回合是否未宣言攻击，并使自身在本回合内不能攻击，作为效果发动的Cost
function c6602300.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 自己的主要阶段时，可以给与对方基本分场上存在的卡每1张300分伤害。这个效果发动的回合这张卡不能攻击。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1,true)
end
-- 伤害效果的发动准备，设置目标玩家为对方，并注册伤害操作信息
function c6602300.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上（怪兽区和魔法与陷阱区）存在的卡片总数
	local ct=Duel.GetFieldGroupCount(tp,0xc,0xc)
	-- 将当前连锁的对象玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的操作信息为给与对方玩家场上卡片数量×300的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- 伤害效果的实际处理，获取目标玩家和场上卡片数量，并给与对方对应数值的伤害
function c6602300.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取效果处理时双方场上存在的卡片总数
	local ct=Duel.GetFieldGroupCount(tp,0xc,0xc)
	-- 因效果给与目标玩家场上卡片数量×300的伤害
	Duel.Damage(p,ct*300,REASON_EFFECT)
end
