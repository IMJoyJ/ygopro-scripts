--所有者の刻印
-- 效果：
-- ①：场上的全部怪兽的控制权回归原本持有者。
function c9720537.initial_effect(c)
	-- 开启全局洗脑解除标记检查（用于处理控制权回归原本持有者的效果）
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
	-- ①：场上的全部怪兽的控制权回归原本持有者。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c9720537.target)
	e1:SetOperation(c9720537.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选当前控制者不等于原本持有者的怪兽
function c9720537.filter(c)
	return c:GetControler()~=c:GetOwner()
end
-- 效果发动时的目标选择与合法性检查函数
function c9720537.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只控制权被改变的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9720537.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果处理函数：使场上所有怪兽的控制权回归原本持有者
function c9720537.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上怪兽区的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	local tg=Group.CreateGroup()
	local tc=g:GetFirst()
	while tc do
		if not tc:IsImmuneToEffect(e) and tc:GetFlagEffect(9720537)==0 then
			tc:RegisterFlagEffect(9720537,RESET_EVENT+RESETS_STANDARD,0,1)
			tg:AddCard(tc)
		end
		tc=g:GetNext()
	end
	tg:KeepAlive()
	-- ①：场上的全部怪兽的控制权回归原本持有者。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果影响的目标为带有当前卡片代号Flag的怪兽
	e1:SetTarget(aux.TargetEqualFunction(Card.GetFlagEffect,1,9720537))
	e1:SetLabelObject(tg)
	-- 将洗脑解除效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
	-- ①：场上的全部怪兽的控制权回归原本持有者。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetLabelObject(e1)
	-- 注册一个在连锁处理结束时触发的全局效果，用于延迟重置
	Duel.RegisterEffect(e2,tp)
	-- ①：场上的全部怪兽的控制权回归原本持有者。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetLabelObject(e2)
	-- 将当前连锁的ID保存到效果的Label中，以便后续比对
	e3:SetLabel(Duel.GetChainInfo(0,CHAININFO_CHAIN_ID))
	e3:SetOperation(c9720537.reset)
	-- 注册用于在当前连锁处理完毕后重置相关效果和Flag的全局效果
	Duel.RegisterEffect(e3,tp)
end
-- 重置函数：在当前连锁处理完毕后，清除怪兽身上的Flag并重置临时注册的全局效果
function c9720537.reset(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前处理完毕的连锁ID是否与本卡发动的连锁ID一致
	if Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)==e:GetLabel() then
		local e2=e:GetLabelObject()
		local e1=e2:GetLabelObject()
		local tg=e1:GetLabelObject()
		-- 遍历受影响的怪兽卡片组
		for tc in aux.Next(tg) do
			tc:ResetFlagEffect(9720537)
		end
		tg:DeleteGroup()
		e1:Reset()
		e2:Reset()
		e:Reset()
	end
end
