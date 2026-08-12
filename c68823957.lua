--サブテラーの刀匠
-- 效果：
-- ①：只让自己场上的里侧表示怪兽1只成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时，把手卡·场上的这张卡送去墓地，以那只里侧表示怪兽以外的自己场上1只怪兽为对象才能发动。那个对象转移为作为正确对象的那只怪兽。
-- ②：只要自己场上有里侧表示怪兽存在，这张卡不会被战斗·效果破坏。
function c68823957.initial_effect(c)
	-- ①：只让自己场上的里侧表示怪兽1只被选择作为对方怪兽的攻击对象时，把手卡·场上的这张卡送去墓地，以那只里侧表示怪兽以外的自己场上1只怪兽为对象才能发动。那个对象转移为作为正确对象的那只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68823957,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCost(c68823957.ccost)
	e1:SetTarget(c68823957.cbtg)
	e1:SetOperation(c68823957.cbop)
	c:RegisterEffect(e1)
	-- ①：只让自己场上的里侧表示怪兽1只成为对方的效果的对象时，把手卡·场上的这张卡送去墓地，以那只里侧表示怪兽以外的自己场上1只怪兽为对象才能发动。那个对象转移为作为正确对象的那只怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68823957,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCondition(c68823957.cecon)
	e2:SetCost(c68823957.ccost)
	e2:SetTarget(c68823957.cetg)
	e2:SetOperation(c68823957.ceop)
	c:RegisterEffect(e2)
	-- ②：只要自己场上有里侧表示怪兽存在，这张卡不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(c68823957.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
end
-- 发动代价（Cost）：把手卡·场上的这张卡送去墓地
function c68823957.ccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：可以成为效果对象的怪兽
function c68823957.cbfilter(c,e)
	return c:IsCanBeEffectTarget(e)
end
-- 被选择作为攻击对象时效果的靶子（Target）函数：检查是否满足发动条件，并选择转移攻击的目标怪兽
function c68823957.cbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c68823957.cbfilter(chkc,e) end
	-- 获取攻击怪兽的可攻击对象卡片组
	local ag=Duel.GetAttacker():GetAttackableTarget()
	-- 获取当前的攻击对象（被攻击的怪兽）
	local at=Duel.GetAttackTarget()
	ag:RemoveCard(at)
	-- 在chk==0时，检查是否是对方怪兽攻击自己场上的里侧表示怪兽
	if chk==0 then return Duel.GetAttacker():IsControler(1-tp) and at:IsControler(tp) and at:IsFacedown()
		and ag:IsExists(c68823957.cbfilter,1,e:GetHandler(),e) end
	-- 给玩家发送提示信息：请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=ag:FilterSelect(tp,c68823957.cbfilter,1,1,e:GetHandler(),e)
	-- 将选择的怪兽设置为效果的对象
	Duel.SetTargetCard(g)
end
-- 被选择作为攻击对象时效果的运行（Operation）函数：将攻击对象转移为选择的怪兽
function c68823957.cbop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用此效果，且攻击怪兽不免疫此效果
	if tc:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 将攻击对象转移为该怪兽
		Duel.ChangeAttackTarget(tc)
	end
end
-- 成为效果对象时效果的发动条件（Condition）函数：检查是否是对方的效果只以自己场上1只里侧表示怪兽为对象
function c68823957.cecon(e,tp,eg,ep,ev,re,r,rp)
	if e==re or rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取触发连锁的效果的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsLocation(LOCATION_MZONE) and tc:IsFacedown()
end
-- 过滤条件：不是原对象怪兽，且是该连锁效果的正确对象
function c68823957.cefilter(c,ct,oc)
	-- 检查卡片是否不是原对象，且能成为该连锁效果的合法对象
	return oc~=c and Duel.CheckChainTarget(ct,c)
end
-- 成为效果对象时效果的靶子（Target）函数：选择自己场上1只其他怪兽作为转移对象
function c68823957.cetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c68823957.cefilter(chkc,ev,e:GetHandler()) end
	-- 在chk==0时，检查自己场上是否存在除原对象以外的、能成为该效果正确对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c68823957.cefilter,tp,LOCATION_MZONE,0,1,e:GetLabelObject(),ev,e:GetHandler()) end
	-- 给玩家发送提示信息：请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只除原对象以外的怪兽作为效果对象
	Duel.SelectTarget(tp,c68823957.cefilter,tp,LOCATION_MZONE,0,1,1,e:GetLabelObject(),ev,e:GetHandler())
end
-- 成为效果对象时效果的运行（Operation）函数：将对方效果的对象转移为新选择的怪兽
function c68823957.ceop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取新选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将触发连锁的效果的对象变更为新选择的怪兽
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end
-- 破坏抗性效果的适用条件（Condition）函数：检查自己场上是否存在里侧表示怪兽
function c68823957.indcon(e)
	-- 检查自己场上是否存在至少1只里侧表示怪兽
	return Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
