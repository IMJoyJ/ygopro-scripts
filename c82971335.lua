--フォーチュンレディ・アーシー
-- 效果：
-- 这张卡的攻击力·守备力变成这张卡的等级×400的数值。自己的准备阶段时，这张卡的等级上升1星（等级最多12星）。这张卡的等级上升时，给与对方基本分400分伤害。
function c82971335.initial_effect(c)
	-- 这张卡的攻击力·守备力变成这张卡的等级×400的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c82971335.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	-- 自己的准备阶段时，这张卡的等级上升1星（等级最多12星）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82971335,0))  --"等级上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c82971335.lvcon)
	e3:SetOperation(c82971335.lvop)
	c:RegisterEffect(e3)
	-- 这张卡的等级上升时，给与对方基本分400分伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(82971335,1))  --"伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_LEVEL_UP)
	e4:SetTarget(c82971335.damtg)
	e4:SetOperation(c82971335.damop)
	c:RegisterEffect(e4)
end
-- 返回这张卡的等级×400的数值
function c82971335.value(e,c)
	return c:GetLevel()*400
end
-- 准备阶段等级上升效果的发动条件：当前回合玩家是自己
function c82971335.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否是自己
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段等级上升效果的处理：若自身表侧表示存在且等级小于12，则等级上升1星
function c82971335.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelAbove(12) then return end
	-- 这张卡的等级上升1星（等级最多12星）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 等级上升时伤害效果的发动准备：设置伤害目标为对方，伤害数值为400
function c82971335.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为400
	Duel.SetTargetParam(400)
	-- 设置连锁的操作信息为给与对方400分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
-- 等级上升时伤害效果的实际处理：给与对方400分伤害
function c82971335.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
