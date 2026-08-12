--女神の加護
-- 效果：
-- 自己回复3000基本分。自己场上表侧表示存在的这张卡从场上离开时，自己受到3000分伤害。
function c47060347.initial_effect(c)
	-- 自己回复3000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c47060347.rectg)
	e1:SetOperation(c47060347.recop)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的这张卡从场上离开时，自己受到3000分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c47060347.checkop)
	c:RegisterEffect(e2)
	-- 自己场上表侧表示存在的这张卡从场上离开时，自己受到3000分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetLabelObject(e2)
	e3:SetOperation(c47060347.leave)
	c:RegisterEffect(e3)
end
-- 设置连锁处理时的目标玩家为当前玩家
function c47060347.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理时的目标参数为3000
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息为回复3000基本分
	Duel.SetTargetParam(3000)
	-- 执行回复效果，使目标玩家回复指定数值的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,3000)
end
-- 获取连锁中目标玩家和目标参数并执行回复
function c47060347.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使指定玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 检查卡片是否处于无效状态或未就绪，若为则设置标签为1，否则为0
function c47060347.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsDisabled() or not c:IsStatus(STATUS_EFFECT_ENABLED) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 当卡片离开场上且满足条件时，对当前玩家造成3000伤害
function c47060347.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==0 and c:IsPreviousControler(tp) then
		-- 以效果原因使指定玩家受到3000分伤害
		Duel.Damage(tp,3000,REASON_EFFECT)
	end
end
