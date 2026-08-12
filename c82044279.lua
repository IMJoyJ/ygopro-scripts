--クリアウィング・シンクロ・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：1回合1次，场上的其他的5星以上的怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ②：1回合1次，只以场上的5星以上的怪兽1只为对象的怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ③：这张卡的效果破坏怪兽的场合，这张卡的攻击力直到回合结束时上升这张卡的效果破坏的怪兽的原本攻击力数值。
function c82044279.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，场上的其他的5星以上的怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82044279,0))  --"5星以上的怪兽的效果发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c82044279.condition)
	e1:SetTarget(c82044279.target)
	e1:SetOperation(c82044279.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(82044279,1))  --"5星以上的怪兽1只为对象的怪兽的效果发动无效并破坏"
	e2:SetCondition(c82044279.condition2)
	c:RegisterEffect(e2)
	-- ③：这张卡的效果破坏怪兽的场合，这张卡的攻击力直到回合结束时上升这张卡的效果破坏的怪兽的原本攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c82044279.atkcon)
	e3:SetOperation(c82044279.atkop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：场上的其他5星以上怪兽的效果发动，且该发动可以被无效
function c82044279.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 获取当前连锁发生时的位置和等级
	local loc,level=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_LEVEL)
	return re:IsActiveType(TYPE_MONSTER) and rc~=c and level>=5 and loc==LOCATION_MZONE
		-- 且自身未被战斗破坏确定，且该连锁的发动可以被无效
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 效果②的发动条件：只以场上1只5星以上的怪兽为对象的怪兽的效果发动，且该发动可以被无效
function c82044279.condition2(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	local c=e:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and tc:IsFaceup() and tc:IsLevelAbove(5) and tc:IsLocation(LOCATION_MZONE)
		-- 且自身未被战斗破坏确定，且该连锁的发动可以被无效
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 效果①和②的发动准备：提示对方玩家，并设置无效发动与破坏的操作信息
function c82044279.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示所选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①和②的效果处理：使该发动无效并破坏
function c82044279.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效，且该卡在连锁中关系成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果③的发动条件：这张卡的效果破坏了怪兽
function c82044279.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and re and re:GetOwner()==e:GetHandler()
		and eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
-- 效果③的效果处理：计算被破坏怪兽的原本攻击力总和，并使这张卡的攻击力上升该数值
function c82044279.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsType,nil,TYPE_MONSTER)
	local c=e:GetHandler()
	local atk=0
	local tc=g:GetFirst()
	while tc do
		if tc:GetTextAttack()>0 then
			atk=atk+tc:GetTextAttack()
		end
		tc=g:GetNext()
	end
	if atk>0 then
		-- 这张卡的攻击力直到回合结束时上升这张卡的效果破坏的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
