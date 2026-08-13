--時械神サンダイオン
-- 效果：
-- 这张卡不能从卡组特殊召唤。
-- ①：「时械神 桑达伊恩」在自己场上只能有1只表侧表示存在。
-- ②：只有对方场上才有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ③：这张卡不会被战斗·效果破坏，这张卡的战斗发生的双方的战斗伤害变成0。
-- ④：这张卡进行战斗的战斗阶段结束时发动。给与对方2000伤害。
-- ⑤：自己准备阶段发动。这张卡回到持有者卡组。
function c33015627.initial_effect(c)
	c:SetUniqueOnField(1,0,33015627)
	-- 这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 只有对方场上才有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33015627,0))  --"不用解放作召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c33015627.ntcon)
	c:RegisterEffect(e2)
	-- 这张卡不会被战斗破坏。
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
	-- 这张卡的战斗发生的对方的战斗伤害变成0。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- 这张卡的战斗发生的自己的战斗伤害变成0。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e8:SetValue(1)
	c:RegisterEffect(e8)
	-- 这张卡进行战斗的战斗阶段结束时发动。给与对方2000伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(33015627,1))
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c33015627.damcon)
	e6:SetTarget(c33015627.damtg)
	e6:SetOperation(c33015627.damop)
	c:RegisterEffect(e6)
	-- 自己准备阶段发动。这张卡回到持有者卡组。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(33015627,2))
	e7:SetCategory(CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c33015627.tdcon)
	e7:SetTarget(c33015627.tdtg)
	e7:SetOperation(c33015627.tdop)
	c:RegisterEffect(e7)
end
-- 不用解放作召唤的召唤规则条件：c为nil时表示该手续可用；否则需满足无解放（minc==0）且等级在5以上、自己场上无怪兽、对方场上有怪兽、自己主要怪兽区有空位。
function c33015627.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 自己的主要怪兽区没有怪兽（自己场上无怪兽）。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 对方的主要怪兽区存在怪兽（对方场上有怪兽）。
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 自己的主要怪兽区有空余格子可供召唤。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- ④的发动条件：这张卡在本战斗阶段进行过战斗（存在与这张卡战斗过的怪兽）。
function c33015627.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- ④发动时的目标处理：先通过合法性检查；在chk==1时，将对方玩家设为伤害对象，伤害值为2000，并登记伤害效果信息。
function c33015627.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为2000，即伤害数值。
	Duel.SetTargetParam(2000)
	-- 登记操作信息：本效果为不取对象的伤害效果，目标玩家为对方，伤害值为2000。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- ④效果处理：根据连锁登记的目标玩家和伤害参数，给对方造成2000点效果伤害。
function c33015627.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的目标玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害形式，对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- ⑤的发动条件：当前回合玩家是这张卡的控制者（即自己的准备阶段）。
function c33015627.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为本效果的控制者（tp）。
	return Duel.GetTurnPlayer()==tp
end
-- ⑤发动时的目标处理：通过合法性检查后，将这张卡本身设为回卡组的目标，并登记回卡组操作信息。
function c33015627.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本效果将使这张卡自身返回持有者卡组，属于回卡组效果。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ⑤效果处理：若这张卡仍与效果相关（未被无效且未离场），将其返回持有者卡组并洗牌。
function c33015627.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果原因将c送回持有者卡组，并洗切卡组。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
