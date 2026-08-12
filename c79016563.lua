--バイナル・ソーサレス
-- 效果：
-- 衍生物以外的怪兽2只
-- ①：得到和这张卡互相连接的怪兽数量的以下效果。
-- ●1只以上：和这张卡互相连接的怪兽用和对方怪兽的战斗给与对方战斗伤害时才能发动。自己基本分回复那个数值。
-- ●2只：1回合1次，以自己场上2只表侧表示怪兽为对象才能发动。直到回合结束时，那2只怪兽之内1只的攻击力变成一半，另1只的攻击力上升那个数值。这个效果在对方回合也能发动。
function c79016563.initial_effect(c)
	-- 为这张卡添加连接召唤的手续，需要2只满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,c79016563.matfilter,2,2)
	c:EnableReviveLimit()
	-- ●1只以上：和这张卡互相连接的怪兽用和对方怪兽的战斗给与对方战斗伤害时才能发动。自己基本分回复那个数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79016563,0))  --"基本分回复"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c79016563.reccon)
	e1:SetTarget(c79016563.rectg)
	e1:SetOperation(c79016563.recop)
	c:RegisterEffect(e1)
	-- ●2只：1回合1次，以自己场上2只表侧表示怪兽为对象才能发动。直到回合结束时，那2只怪兽之内1只的攻击力变成一半，另1只的攻击力上升那个数值。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79016563,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c79016563.atkcon)
	e2:SetTarget(c79016563.atktg)
	e2:SetOperation(c79016563.atkop)
	c:RegisterEffect(e2)
end
-- 过滤连接素材，限制不能使用衍生物
function c79016563.matfilter(c)
	return not c:IsLinkType(TYPE_TOKEN)
end
-- 判定效果1的发动条件：给与对方战斗伤害的怪兽必须是与这张卡互相连接的怪兽
function c79016563.reccon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetMutualLinkedGroup()
	local tc=eg:GetFirst()
	return ep~=tp and lg:IsContains(tc) and tc:GetBattleTarget()~=nil
end
-- 效果1的发动准备：设置回复的对象玩家、回复数值，并声明回复的操作信息
function c79016563.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为战斗伤害的数值
	Duel.SetTargetParam(ev)
	-- 设置当前连锁的操作信息为回复自己与战斗伤害相同数值的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果1的效果处理：获取之前设定的对象玩家和数值，执行回复基本分的操作
function c79016563.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 判定效果2的发动条件：必须不在伤害计算后，且这张卡互相连接的怪兽数量在2只以上
function c79016563.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前时点是否允许在伤害步骤发动（非伤害步骤或伤害计算前）
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp)
		and e:GetHandler():GetMutualLinkedGroupCount()>=2
end
-- 过滤可以作为效果2对象的怪兽：必须是场上表侧表示且能成为效果对象的怪兽
function c79016563.tgfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 检查选中的怪兽组中是否至少有1只怪兽的攻击力在1以上（确保可以减半）
function c79016563.gcheck(g)
	return g:IsExists(Card.IsAttackAbove,1,nil,1)
end
-- 效果2的发动准备：选择自己场上2只表侧表示怪兽作为对象
function c79016563.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上所有满足条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c79016563.tgfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return g:CheckSubGroup(c79016563.gcheck,2,2) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c79016563.gcheck,false,2,2)
	-- 将选中的2只怪兽设为当前连锁的对象
	Duel.SetTargetCard(sg)
end
-- 效果2的效果处理：选择其中1只怪兽攻击力变成一半，另1只怪兽攻击力上升那个数值
function c79016563.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍合法存在于场上的对象怪兽
	local g=Duel.GetTargetsRelateToChain()
	if g:FilterCount(Card.IsFaceup,nil)<2 then return end
	-- 提示玩家选择其中1只攻击力要变成一半的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(79016563,2))  --"请选择要让攻击力变成一半的怪兽"
	local tc1=g:FilterSelect(tp,Card.IsAttackAbove,1,1,nil,1):GetFirst()
	local tc2=(g-tc1):GetFirst()
	local atk=tc1:GetAttack()
	-- 直到回合结束时，那2只怪兽之内1只的攻击力变成一半
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(math.ceil(atk/2))
	if tc1:RegisterEffect(e1) then
		-- 另1只的攻击力上升那个数值
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(math.ceil(atk/2))
		tc2:RegisterEffect(e2)
	end
end
