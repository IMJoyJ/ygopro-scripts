--シフトチェンジ
-- 效果：
-- 自己场上的怪兽1只成为对方的魔法·陷阱卡的效果的对象时或者成为对方怪兽的攻击对象时才能发动。那个对象转移为自己场上1只作为正确对象的其他怪兽。
function c59560625.initial_effect(c)
	-- 自己场上的怪兽1只成为对方怪兽的攻击对象时才能发动。那个对象转移为自己场上1只作为正确对象的其他怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59560625,0))  --"改变对方的效果的对象"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c59560625.condition1)
	e1:SetTarget(c59560625.target1)
	e1:SetOperation(c59560625.activate1)
	c:RegisterEffect(e1)
	-- 自己场上的怪兽1只成为对方的魔法·陷阱卡的效果的对象时才能发动。那个对象转移为自己场上1只作为正确对象的其他怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59560625,1))  --"改变对方的战斗对象"
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c59560625.condition2)
	e2:SetTarget(c59560625.target2)
	e2:SetOperation(c59560625.activate2)
	c:RegisterEffect(e2)
end
-- 攻击对象转移效果的发动条件判定
function c59560625.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合（对方怪兽进行攻击宣言）
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤出可以成为效果对象的卡片
function c59560625.filter1(c,e)
	return c:IsCanBeEffectTarget(e)
end
-- 攻击对象转移效果的发动准备与目标选择
function c59560625.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local ag=eg:GetFirst():GetAttackableTarget()
	-- 获取当前的攻击对象（被攻击的怪兽）
	local at=Duel.GetAttackTarget()
	if chk==0 then return ag:IsExists(c59560625.filter1,1,at,e) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=ag:FilterSelect(tp,c59560625.filter1,1,1,at,e)
	-- 将选择的怪兽设为本效果的对象
	Duel.SetTargetCard(g)
end
-- 攻击对象转移效果的执行
function c59560625.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果选定的转移目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查转移目标是否仍适用，且攻击怪兽不免疫此卡的效果
	if tc:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 将攻击对象转移为选定的怪兽
		Duel.ChangeAttackTarget(tc)
	end
end
-- 效果对象转移效果的发动条件判定
function c59560625.condition2(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取对方发动的魔法·陷阱卡效果的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE)
end
-- 过滤出能作为该连锁效果的正确对象的怪兽
function c59560625.filter2(c,ct)
	-- 检查怪兽是否是该连锁效果的正确对象
	return Duel.CheckChainTarget(ct,c)
end
-- 效果对象转移效果的发动准备与目标选择
function c59560625.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc~=e:GetLabelObject() and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c59560625.filter2(chkc,ev) end
	-- 检查自己场上是否存在除原对象以外、可以作为该效果正确对象的其他怪兽
	if chk==0 then return Duel.IsExistingTarget(c59560625.filter2,tp,LOCATION_MZONE,0,1,e:GetLabelObject(),ev) end
	-- 提示玩家选择要转移到的新对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只作为正确对象的其他怪兽并设为本效果的对象
	Duel.SelectTarget(tp,c59560625.filter2,tp,LOCATION_MZONE,0,1,1,e:GetLabelObject(),ev)
end
-- 效果对象转移效果的执行
function c59560625.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果选定的新对象怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:GetFirst():IsRelateToEffect(e) then
		-- 将对方魔法·陷阱卡效果的对象转移为新选择的怪兽
		Duel.ChangeTargetCard(ev,g)
	end
end
