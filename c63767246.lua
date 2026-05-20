--No.38 希望魁竜タイタニック・ギャラクシー
-- 效果：
-- 8星怪兽×2
-- ①：1回合1次，魔法卡的效果在场上发动时才能发动。那个效果无效，场上的那张卡作为这张卡的超量素材。
-- ②：对方的攻击宣言时，把这张卡1个超量素材取除才能发动。攻击对象转移为这张卡进行伤害计算。
-- ③：自己场上的其他的表侧表示的超量怪兽被战斗·效果破坏的场合，以自己场上1只超量怪兽为对象才能发动。那只怪兽的攻击力上升那些破坏的怪兽之内1只的原本攻击力数值。
function c63767246.initial_effect(c)
	-- 设置需要2只8星怪兽的超量召唤手续
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，魔法卡的效果在场上发动时才能发动。那个效果无效，场上的那张卡作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63767246,0))  --"魔法卡的效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c63767246.discon)
	e1:SetTarget(c63767246.distg)
	e1:SetOperation(c63767246.disop)
	c:RegisterEffect(e1)
	-- ②：对方的攻击宣言时，把这张卡1个超量素材取除才能发动。攻击对象转移为这张卡进行伤害计算。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63767246,1))  --"攻击对象转移为这张卡"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c63767246.cbcon)
	e2:SetCost(c63767246.cbcost)
	e2:SetOperation(c63767246.cbop)
	c:RegisterEffect(e2)
	-- 为单张卡片注册合并的延迟被破坏事件，用于监听自己场上的超量怪兽被破坏的时点
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,63767246,EVENT_DESTROYED)
	-- ③：自己场上的其他的表侧表示的超量怪兽被战斗·效果破坏的场合，以自己场上1只超量怪兽为对象才能发动。那只怪兽的攻击力上升那些破坏的怪兽之内1只的原本攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63767246,2))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(custom_code)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c63767246.atkcon)
	e3:SetTarget(c63767246.atktg)
	e3:SetOperation(c63767246.atkop)
	c:RegisterEffect(e3)
end
-- 设定这张卡的「No.」编号为38
aux.xyz_number[63767246]=38
-- 魔法效果无效效果的发动条件判定
function c63767246.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁触发时的卡片所在位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_SZONE)~=0
		-- 判定发动的效果是魔法卡的效果、该连锁可以被无效，且自身未被战斗破坏
		and re:IsActiveType(TYPE_SPELL) and Duel.IsChainDisablable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 魔法效果无效效果的发动准备与操作信息设置
function c63767246.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置包含“使效果无效”分类的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 魔法效果无效效果的效果处理
function c63767246.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 判定是否成功无效效果，且自身与目标卡均有效、目标卡可作为超量素材且自身为超量怪兽
	if Duel.NegateEffect(ev) and c:IsRelateToEffect(e) and rc:IsRelateToEffect(re) and rc:IsCanOverlay() and c:IsType(TYPE_XYZ) then
		rc:CancelToGrave()
		-- 将目标卡作为超量素材重叠在自身下方
		Duel.Overlay(c,Group.FromCards(rc))
	end
end
-- 转移攻击对象效果的发动条件判定
function c63767246.cbcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前为对方回合且当前的攻击对象不是自身
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()~=e:GetHandler()
end
-- 转移攻击对象效果的发动代价处理（取除1个超量素材）
function c63767246.cbcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 转移攻击对象效果的效果处理
function c63767246.cbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 获取当前进行攻击宣言的怪兽
		local at=Duel.GetAttacker()
		if at:IsAttackable() and not at:IsImmuneToEffect(e) then
			-- 强制令攻击怪兽与自身进行伤害计算
			Duel.CalculateDamage(at,c)
		end
	end
end
-- 过滤出自己场上因战斗或效果破坏的超量怪兽
function c63767246.atkfilter1(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsType(TYPE_XYZ) and c:GetBaseAttack()>0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 攻击力上升效果的发动条件判定，并保存被破坏的怪兽组
function c63767246.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c63767246.atkfilter1,nil,tp)
	if #g==0 then return false end
	g:KeepAlive()
	e:SetLabelObject(g)
	return true
end
-- 过滤出场上表侧表示的超量怪兽
function c63767246.atkfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 攻击力上升效果的选择对象与发动准备
function c63767246.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c63767246.atkfilter2(chkc) end
	-- 判定自己场上是否存在可以作为对象的表侧表示超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c63767246.atkfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的超量怪兽作为效果对象
	Duel.SelectTarget(tp,c63767246.atkfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 攻击力上升效果的效果处理
function c63767246.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果选中的对象怪兽
	local tc=Duel.GetFirstTarget()
	local g=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		if g:GetCount()>=2 then
			-- 提示玩家选择其中1只被破坏的怪兽以确定上升的攻击力数值
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			g=g:Select(tp,1,1,nil)
		end
		-- 那只怪兽的攻击力上升那些破坏的怪兽之内1只的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(g:GetFirst():GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	e:GetLabelObject():DeleteGroup()
end
