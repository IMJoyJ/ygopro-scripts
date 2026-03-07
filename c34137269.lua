--時械神ハイロン
-- 效果：
-- 这张卡不能从卡组特殊召唤。
-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：这张卡进行战斗的战斗阶段结束时发动。自己基本分比对方少的场合，给与对方那个相差数值的伤害。
-- ④：自己准备阶段发动。这张卡回到持有者卡组。
function c34137269.initial_effect(c)
	-- 效果原文：这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文：①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34137269,0))  --"不用解放作召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c34137269.ntcon)
	c:RegisterEffect(e2)
	-- 效果原文：②：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e5)
	-- 效果原文：③：这张卡进行战斗的战斗阶段结束时发动。自己基本分比对方少的场合，给与对方那个相差数值的伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c34137269.damcon)
	e6:SetTarget(c34137269.damtg)
	e6:SetOperation(c34137269.damop)
	c:RegisterEffect(e6)
	-- 效果原文：④：自己准备阶段发动。这张卡回到持有者卡组。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(34137269,1))
	e7:SetCategory(CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c34137269.tdcon)
	e7:SetTarget(c34137269.tdtg)
	e7:SetOperation(c34137269.tdop)
	c:RegisterEffect(e7)
end
-- 满足条件时可以不用解放作召唤，且等级不低于5，场上没有怪兽，且有召唤空位。
function c34137269.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 判断场上是否没有怪兽。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判断是否有召唤空位。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判断是否参与过战斗。
function c34137269.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 设置伤害目标为对方玩家，并计算伤害值。
function c34137269.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	local dam=0
	-- 如果己方LP低于对方，则计算差值作为伤害值。
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) then dam=Duel.GetLP(1-tp)-Duel.GetLP(tp) end
	-- 设置连锁操作信息为对对方造成伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行伤害效果，若伤害值大于0则造成相应伤害。
function c34137269.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算己方与对方LP的差值。
	local val=Duel.GetLP(1-tp)-Duel.GetLP(tp)
	if val>0 then
		-- 对目标玩家造成相应数值的伤害。
		Duel.Damage(p,val,REASON_EFFECT)
	end
end
-- 判断是否为自己的准备阶段。
function c34137269.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者。
	return Duel.GetTurnPlayer()==tp
end
-- 设置将自身送回卡组的操作信息。
function c34137269.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为将自身送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 执行将自身送回卡组的效果。
function c34137269.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身送回卡组并洗牌。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
