--天使の手鏡
-- 效果：
-- 把以场上1只怪兽为对象发动的对方的魔法，转移给其他正确的对象。
function c17653779.initial_effect(c)
	-- 把以场上1只怪兽为对象的对方的魔法，转移给其他正确的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c17653779.tgcon)
	e1:SetTarget(c17653779.tgtg)
	e1:SetOperation(c17653779.tgop)
	c:RegisterEffect(e1)
end
-- 判定对方发动的效果是否为“以场上1只怪兽为对象的魔法卡发动”：若发动者是己方、或不是魔法卡发动、或不带取对象标志，则返回false。
function c17653779.tgcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_SPELL)
		or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取对方发动的魔法效果当前选择的对象（原始目标怪兽）。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsLocation(LOCATION_MZONE)
end
-- 定义筛选函数：判断候选怪兽c是否能成为对方魔法效果的其他正确对象。
function c17653779.filter(c,ct)
	-- 调用Duel.CheckChainTarget检查候选卡c是否能成为连锁ct（对方魔法）的合法对象。
	return Duel.CheckChainTarget(ct,c)
end
-- 目标选择处理：若系统逐个询问候选对象，则判定其是否是除原对象外可成为对方魔法新对象的怪兽；若在发动时检查，则确认存在至少一个合法新目标；随后提示玩家选择一张符合条件的怪兽作为替换对象。
function c17653779.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc~=e:GetLabelObject() and chkc:IsLocation(LOCATION_MZONE) and c17653779.filter(chkc,ev) end
	-- 在效果发动时（chk==0）检查场上是否存在至少一张除原对象外、位于主要怪兽区且可作为对方魔法新对象的怪兽；若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c17653779.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetLabelObject(),ev) end
	-- 向玩家显示“请选择效果的对象”的提示，供目标选择时参考。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择一张符合条件的怪兽（非原对象、位于主要怪兽区、且可作为对方魔法新对象），并将其登记为当前连锁（天使的手镜）的对象。
	Duel.SelectTarget(tp,c17653779.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetLabelObject(),ev)
end
-- 效果处理阶段：获取当前连锁（天使的手镜）选择的新对象，若该对象仍与效果有关联，则将对方发动的魔法连锁ev的对象改为该新对象，从而完成转移。
function c17653779.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁（天使的手镜）在处理时登记的对象，即玩家之前选择用来替换目标的新怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:GetFirst():IsRelateToEffect(e) then
		-- 将对方魔法连锁ev的对象卡组替换为g，实现把魔法对象转移给新的正确对象。
		Duel.ChangeTargetCard(ev,g)
	end
end
