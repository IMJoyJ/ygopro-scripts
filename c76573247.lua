--エーリアン・ベーダー
-- 效果：
-- 这张卡1回合只有1次，可以移动到没有使用的相邻的怪兽卡区域。这张卡的正对面没有对方的怪兽·魔法·陷阱卡存在的场合，这张卡可以直接攻击对方玩家。
function c76573247.initial_effect(c)
	-- 这张卡1回合只有1次，可以移动到没有使用的相邻的怪兽卡区域。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76573247,0))  --"移动位置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c76573247.seqcon)
	e1:SetTarget(c76573247.seqtg)
	e1:SetOperation(c76573247.seqop)
	c:RegisterEffect(e1)
	-- 这张卡的正对面没有对方的怪兽·魔法·陷阱卡存在的场合，这张卡可以直接攻击对方玩家。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c76573247.dircon)
	c:RegisterEffect(e2)
end
-- 检查自身是否处于主要怪兽区域，且其左侧或右侧相邻的怪兽区域是否为空置状态
function c76573247.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	if seq>4 then return false end
	-- 检查自身左侧相邻的怪兽区域是否可用
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 检查自身右侧相邻的怪兽区域是否可用
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 移动位置效果的发动准备，计算并让玩家选择相邻的可用怪兽区域
function c76573247.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local seq=e:GetHandler():GetSequence()
	local flag=0
	-- 若左侧相邻区域可用，则将该位置标记加入可选范围
	if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	-- 若右侧相邻区域可用，则将该位置标记加入可选范围
	if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家在可选的相邻怪兽区域中选择一个位置
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag)
	local nseq=math.log(s,2)
	e:SetLabel(nseq)
	-- 在界面上高亮显示玩家选择的区域
	Duel.Hint(HINT_ZONE,tp,s)
end
-- 移动位置效果的执行，将自身移动到选择的相邻怪兽区域
function c76573247.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq=e:GetLabel()
	-- 检查自身是否仍在场、控制权未改变、处于主要怪兽区且目标区域仍可用，否则不处理
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:GetSequence()>4 or not Duel.CheckLocation(tp,LOCATION_MZONE,seq) then return end
	-- 将此卡移动到指定的怪兽区域
	Duel.MoveSequence(c,seq)
end
-- 检查此卡正对面的纵列上是否存在对方的卡片，若没有则满足直接攻击条件
function c76573247.dircon(e)
	return e:GetHandler():GetColumnGroup():FilterCount(Card.IsControler,nil,1-e:GetHandlerPlayer())==0
end
