--タイラント・ウィング
-- 效果：
-- ①：以场上1只龙族怪兽为对象才能把这张卡发动。这张卡当作攻击力·守备力上升400的装备卡使用给那只怪兽装备。
-- ②：用这张卡的效果把这张卡装备的怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ③：用这张卡的效果把这张卡装备的怪兽向对方怪兽攻击的回合的结束阶段发动。这张卡破坏。
function c57470761.initial_effect(c)
	-- ①：以场上1只龙族怪兽为对象才能把这张卡发动。这张卡当作攻击力·守备力上升400的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置发动条件为伤害步骤中伤害计算前以外的时机
	e1:SetCondition(aux.dscon)
	e1:SetCost(c57470761.cost)
	e1:SetTarget(c57470761.target)
	e1:SetOperation(c57470761.activate)
	c:RegisterEffect(e1)
end
-- 陷阱卡发动时的Cost处理，用于处理留在场上的状态以及连锁被无效时的送去墓地处理
function c57470761.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作攻击力·守备力上升400的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以场上1只龙族怪兽为对象才能把这张卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c57470761.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁无效时将卡送去墓地的效果注册给全局环境
	Duel.RegisterEffect(e2,tp)
end
-- 连锁无效时的操作：取消送去墓地的确定状态，使其正常送去墓地
function c57470761.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：场上表侧表示的龙族怪兽
function c57470761.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 效果发动的靶向选择（取对象）与合法性检测
function c57470761.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c57470761.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检测场上是否存在可以作为装备对象的表侧表示龙族怪兽
		and Duel.IsExistingTarget(c57470761.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择1只符合条件的龙族怪兽作为对象
	Duel.SelectTarget(tp,c57470761.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息：包含装备分类，数量为1
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果发动的处理：将自身装备给目标怪兽，并赋予各项装备效果
function c57470761.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取发动时选择的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 这张卡当作攻击力·守备力上升400的装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c57470761.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 攻击力·守备力上升400
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(400)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e3)
		-- ②：用这张卡的效果把这张卡装备的怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_EQUIP)
		e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e4:SetValue(1)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e4)
		-- ③：用这张卡的效果把这张卡装备的怪兽向对方怪兽攻击的回合的结束阶段发动。这张卡破坏。
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e7:SetCode(EVENT_BATTLE_START)
		e7:SetRange(LOCATION_SZONE)
		e7:SetOperation(c57470761.regop)
		e7:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e7)
		-- ③：用这张卡的效果把这张卡装备的怪兽向对方怪兽攻击的回合的结束阶段发动。这张卡破坏。
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_EQUIP)
		e8:SetRange(LOCATION_SZONE)
		e8:SetOperation(c57470761.resetop)
		e8:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e8)
		-- ③：用这张卡的效果把这张卡装备的怪兽向对方怪兽攻击的回合的结束阶段发动。这张卡破坏。
		local e9=Effect.CreateEffect(c)
		e9:SetCategory(CATEGORY_DESTROY)
		e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e9:SetCode(EVENT_PHASE+PHASE_END)
		e9:SetRange(LOCATION_SZONE)
		e9:SetCountLimit(1)
		e9:SetCondition(c57470761.descon)
		e9:SetTarget(c57470761.destg)
		e9:SetOperation(c57470761.desop)
		e9:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e9)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制：只能装备给自身效果选择的怪兽，或者自己场上的龙族怪兽
function c57470761.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_DRAGON)
end
-- 战斗开始时的处理：如果装备怪兽向对方怪兽发动攻击，则给这张卡添加一个标记，用于在回合结束时触发破坏效果
function c57470761.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec:IsRelateToBattle() then return end
	local bc=ec:GetBattleTarget()
	-- 判定是否为装备怪兽向对方场上的怪兽发动攻击
	if bc and bc:IsControler(1-tp) and Duel.GetAttacker()==ec then
		c:RegisterFlagEffect(57470761,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 重新装备时的处理：清除攻击过对方怪兽的标记
function c57470761.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsContains(c) then
		c:ResetFlagEffect(57470761)
	end
end
-- 破坏效果的发动条件：这张卡带有攻击过对方怪兽的标记
function c57470761.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(57470761)~=0
end
-- 破坏效果的靶向与操作信息设置
function c57470761.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息：包含破坏分类，对象为这张卡自身，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 破坏效果的执行：如果这张卡仍在场，则将其破坏
function c57470761.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 因效果将这张卡自身破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
