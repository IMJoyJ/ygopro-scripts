--そよ風の精霊
-- 效果：
-- 只要这张卡在自己场上表侧攻击表示存在，每次自己的准备阶段回复1000基本分。
function c53530069.initial_effect(c)
	-- 只要这张卡在自己场上表侧攻击表示存在，每次自己的准备阶段回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53530069,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c53530069.condition)
	e1:SetTarget(c53530069.target)
	e1:SetOperation(c53530069.operation)
	c:RegisterEffect(e1)
end
-- 回复效果的发动条件判断：若当前为效果控制者的准备阶段，且此卡在自己场上为表侧攻击表示，则满足条件。
function c53530069.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足条件：当前回合玩家为效果控制者tp，且效果持有者（此卡）为攻击表示。
	return tp==Duel.GetTurnPlayer() and e:GetHandler():IsAttackPos()
end
-- 回复效果的目标设定：将回复对象玩家设为tp，回复数值设为1000，并登记对应的操作信息，以便后续处理及连锁判断。
function c53530069.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为tp，即回复基本分的玩家为此卡的控制者。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1000，表示回复的基本分数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：本效果将让玩家tp回复1000基本分，类别为CATEGORY_RECOVER，用于连锁和效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 回复效果的实际处理：若此卡仍为表侧攻击表示且与发动时的效果仍有关联，则执行回复操作。
function c53530069.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设定的对象玩家p和回复数值d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	if c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e) then
		-- 以效果为原因，使玩家p回复d点基本分，完成实际回复。
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
