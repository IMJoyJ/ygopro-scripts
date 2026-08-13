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
	-- 自己场上表侧表示存在的这张卡从场上离开时
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c47060347.checkop)
	c:RegisterEffect(e2)
	-- 自己受到3000分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetLabelObject(e2)
	e3:SetOperation(c47060347.leave)
	c:RegisterEffect(e3)
end
-- 发动时的目标处理：判定发动条件成立，将对象玩家设为发动者自己、对象参数设为3000，并登记回复类效果的操作信息。
function c47060347.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为发动者自己，作为回复基本分的对象。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为3000，即回复的基本分数值。
	Duel.SetTargetParam(3000)
	-- 登记操作信息：本次连锁包含回复3000LP的效果类别，供相关卡牌进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,3000)
end
-- 效果处理时的操作：从连锁信息中取出发动时设定好的对象玩家和数值，执行基本分回复。
function c47060347.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁记录的对象玩家和对象参数，分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 令玩家p回复d点基本分，回复原因视为效果。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 离场前判定：若卡片处于无效状态或未准备就绪，则标记为1；否则标记为0，用于判断离场时是否应当触发伤害。
function c47060347.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsDisabled() or not c:IsStatus(STATUS_EFFECT_ENABLED) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 离场时处理：若此前标记为0（离场时效果有效）且离场前控制者为发动者本人，则给予发动者3000点伤害。
function c47060347.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==0 and c:IsPreviousControler(tp) then
		-- 给予玩家tp造成3000点效果伤害。
		Duel.Damage(tp,3000,REASON_EFFECT)
	end
end
