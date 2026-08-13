--アロマポット
-- 效果：
-- ①：只要反转过的这张卡在怪兽区域表侧表示存在，这张卡不会被战斗破坏。
-- ②：反转过的这张卡在怪兽区域表侧表示存在的场合，每次双方的结束阶段发动。自己回复500基本分。
function c21452275.initial_effect(c)
	-- 反转过的这张卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c21452275.flipop)
	c:RegisterEffect(e1)
	-- ①：只要反转过的这张卡在怪兽区域表侧表示存在，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c21452275.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：反转过的这张卡在怪兽区域表侧表示存在的场合，每次双方的结束阶段发动。自己回复500基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c21452275.reccon)
	e3:SetTarget(c21452275.rectg)
	e3:SetOperation(c21452275.recop)
	c:RegisterEffect(e3)
end
-- 这张卡反转成功时，给自身记录一个‘已反转’的标记，用于后续判定；该标记在卡片离场等标准重置时清除。
function c21452275.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(21452275,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 作为‘不会被战斗破坏’效果的条件：判断这张卡是否带有所记录的‘已反转’标记（即已反转且标记未被重置）。
function c21452275.indcon(e)
	return e:GetHandler():GetFlagEffect(21452275)~=0
end
-- 作为回复效果的发动条件：判断这张卡是否带有所记录的‘已反转’标记，且位于怪兽区域表侧表示（由Effect的范围和类型保证）。
function c21452275.reccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(21452275)~=0
end
-- 回复效果的发动目标处理：选择回复对象为这张卡的控制者，回复数值为500，并登记操作信息以便系统检测。
function c21452275.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将这次回复效果的对象玩家设定为发动效果的一方（自己）。
	Duel.SetTargetPlayer(tp)
	-- 将这次回复效果的对象参数设定为500，表示回复量。
	Duel.SetTargetParam(500)
	-- 登记操作信息：本连锁将进行效果回复，对玩家tp回复500基本分（对象未确定，count=0）。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 回复效果处理：从连锁信息中取出之前设定的对象玩家和回复数值，让该玩家回复对应的基本分。
function c21452275.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的回复对象玩家和回复数值（之前通过SetTargetPlayer/SetTargetParam设置）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果这一原因为对象玩家回复指定数值的基本分（500）。
	Duel.Recover(p,d,REASON_EFFECT)
end
