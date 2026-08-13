--魔鏡導士リフレクト・バウンダー
-- 效果：
-- 场上表侧攻击表示存在的这张卡被对方怪兽攻击的场合，那次伤害计算前给与对方基本分攻击怪兽的攻击力数值的伤害，那次伤害计算后这张卡破坏。
function c2851070.initial_effect(c)
	-- 场上表侧攻击表示存在的这张卡被对方怪兽攻击的场合，那次伤害计算前给与对方基本分攻击怪兽的攻击力数值的伤害
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2851070,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(c2851070.damcon)
	e1:SetTarget(c2851070.damtg)
	e1:SetOperation(c2851070.damop)
	c:RegisterEffect(e1)
	-- 那次伤害计算后这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2851070,1))  --"自坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c2851070.destg)
	e1:SetOperation(c2851070.desop)
	c:RegisterEffect(e1)
end
-- 伤害效果的发动条件：被攻击目标为本卡，且本卡在战斗前为表侧攻击表示。
function c2851070.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被攻击的怪兽（即攻击对象）。
	local c=Duel.GetAttackTarget()
	return c==e:GetHandler() and c:GetBattlePosition()==POS_FACEUP_ATTACK
end
-- 伤害效果发动时的目标设定处理：由于效果必发，检查通过；将受到伤害的玩家设为对方，并登记伤害操作信息。
function c2851070.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的伤害对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 登记伤害效果的操作信息：伤害类别为造成伤害，伤害对象为对方玩家，无确定目标卡。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 实际执行伤害效果：获取对象玩家，记录伤前LP；给予对方攻击怪兽当前攻击力数值的伤害；若对方LP减少，则为本卡注册一个标识，用于触发后续自坏效果。
function c2851070.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁登记的对象玩家（即受到伤害的玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 记录该玩家受伤前的生命值，用于判断伤害是否实际造成。
	local lp1=Duel.GetLP(p)
	-- 给对象玩家造成伤害，数值为攻击怪兽当前的攻击力，伤害原因为效果。
	Duel.Damage(p,Duel.GetAttacker():GetAttack(),REASON_EFFECT)
	-- 取得该玩家受伤后的生命值，用于比较是否减少。
	local lp2=Duel.GetLP(p)
	if lp2<lp1 then
		e:GetHandler():RegisterFlagEffect(2851070,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
-- 自坏效果的发动条件：检查本卡是否带有已造成伤害的标识；若满足则登记破坏本卡的操作信息。
function c2851070.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(2851070)~=0 end
	-- 登记破坏本卡的操作信息：类别为破坏，目标为本卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 实际执行自坏效果：若本卡与效果仍有关联，则将其破坏。
function c2851070.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果破坏本卡。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
