--悪魔の手鏡
-- 效果：
-- 使对方发动的以1张魔法·陷阱卡为对象的魔法移向另外1个正确的对象。
function c58607704.initial_effect(c)
	-- 使对方发动的以1张魔法·陷阱卡为对象的魔法移向另外1个正确的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c58607704.tgcon)
	e1:SetTarget(c58607704.tgtg)
	e1:SetOperation(c58607704.tgop)
	c:RegisterEffect(e1)
end
-- 判断触发连锁的是否为对方发动的取对象的魔法卡
function c58607704.tgcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_SPELL)
		or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取触发连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsOnField() and tc:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义合法目标过滤函数：必须是魔法·陷阱卡，且是触发连锁的正确对象
function c58607704.filter(c,ct)
	-- 判断卡片是否为魔法·陷阱卡，且是否能成为触发连锁的正确对象
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.CheckChainTarget(ct,c)
end
-- 效果发动的对象选择阶段
function c58607704.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc~=e:GetLabelObject() and chkc:IsOnField() and c58607704.filter(chkc,ev) end
	-- 检查场上是否存在除原对象以外的、可作为触发连锁正确对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c58607704.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetLabelObject(),ev) end
	-- 设置选择卡片时的提示信息为“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1个除原对象以外的、可作为触发连锁正确对象的场上的魔法·陷阱卡作为本卡的对象
	Duel.SelectTarget(tp,c58607704.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetLabelObject(),ev)
end
-- 效果处理阶段，将触发连锁的对象变更为新选择的对象
function c58607704.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本卡所选择的对象卡片组（即新对象）
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g and g:GetFirst():IsRelateToEffect(e) then
		-- 将触发连锁的对象变更为新选择的对象
		Duel.ChangeTargetCard(ev,g)
	end
end
