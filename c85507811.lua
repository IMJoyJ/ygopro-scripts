--E・HERO グロー・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·光辉青苔」
-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。结束阶段时这张卡回到额外卡组。把对方场上表侧表示存在的1张卡破坏，这张卡得到那张卡的种类的以下效果：这个效果1回合只有1次在自己的主要阶段一才能使用。
-- ●怪兽卡-这个回合，这张卡不能进行战斗。
-- ●魔法卡-这张卡可以直接攻击对方玩家。
-- ●陷阱卡-这张卡变成守备表示。
function c85507811.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合素材：「元素英雄 新宇侠」与「新空间侠·光辉青苔」
	aux.AddFusionProcCode2(c,89943723,17732278,false,false)
	-- 添加接触融合的特殊召唤手续，将场上的素材送回卡组
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c85507811.splimit)
	c:RegisterEffect(e1)
	-- 注册结束阶段时这张卡回到额外卡组的效果
	aux.EnableNeosReturn(c,c85507811.retop)
	-- 把对方场上表侧表示存在的1张卡破坏，这张卡得到那张卡的种类的以下效果：这个效果1回合只有1次在自己的主要阶段一才能使用。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(85507811,1))  --"破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCondition(c85507811.descon)
	e5:SetTarget(c85507811.destg)
	e5:SetOperation(c85507811.desop)
	c:RegisterEffect(e5)
end
c85507811.material_setcode=0x8
-- 限制该卡只能从额外卡组进行特殊召唤
function c85507811.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 结束阶段将这张卡送回额外卡组的具体操作函数
function c85507811.retop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 将自身送回额外卡组并洗牌
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 破坏效果的发动条件判定函数（只能在主要阶段1发动）
function c85507811.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 过滤条件：场上表侧表示的卡片
function c85507811.filter(c)
	return c:IsFaceup()
end
-- 破坏效果的靶向选择（Target）与合法性检测函数
function c85507811.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c85507811.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的表侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c85507811.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送选择要破坏的卡片的消息提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c85507811.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的具体执行函数，根据破坏卡的种类赋予自身对应效果
function c85507811.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的那张卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 因效果破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
		local c=e:GetHandler()
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		if tc:IsType(TYPE_MONSTER) then
			-- ●怪兽卡-这个回合，这张卡不能进行战斗。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		elseif tc:IsType(TYPE_SPELL) then
			-- ●魔法卡-这张卡可以直接攻击对方玩家。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		else
			-- 将自身变为表侧守备表示
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
end
