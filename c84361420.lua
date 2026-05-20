--エッジ・ハンマー
-- 效果：
-- 把自己场上存在的1只「元素英雄 金刃侠」作为祭品。对方场上存在的1只怪兽破坏，给与对方基本分那只怪兽的原本攻击力数值的伤害。
function c84361420.initial_effect(c)
	-- 为卡片对象添加「元素英雄」系列怪兽列表，以便后续进行系列匹配检查。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 把自己场上存在的1只「元素英雄 金刃侠」作为祭品。对方场上存在的1只怪兽破坏，给与对方基本分那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c84361420.cost)
	e1:SetTarget(c84361420.target)
	e1:SetOperation(c84361420.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的代价（Cost）处理函数，用于检查并解放自己场上的「元素英雄 金刃侠」。
function c84361420.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查自己场上是否存在至少1只可解放的「元素英雄 金刃侠」。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,59793705) end
	-- 玩家从场上选择1只「元素英雄 金刃侠」作为解放的对象。
	local g=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,nil,59793705)
	-- 解放选中的怪兽作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 效果的目标选择（Target）处理函数，用于确认发动条件、选择对方场上的1只怪兽作为对象并设置操作信息。
function c84361420.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 步骤0：检查对方场上是否存在至少1只可以成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上的1只怪兽作为效果对象并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表明此效果包含破坏选中的怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，表明此效果包含给与对方玩家伤害的操作。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果运行（Operation）处理函数，执行破坏怪兽并给与对方伤害的具体效果。
function c84361420.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 尝试以效果破坏该怪兽，若成功破坏则执行后续伤害处理。
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			local dam=tc:GetBaseAttack()
			-- 给与对方玩家相当于该怪兽原本攻击力数值的伤害。
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
