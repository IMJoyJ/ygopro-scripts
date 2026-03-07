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
	-- 这张卡不会被战斗·效果破坏
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
	-- 这张卡的战斗发生的双方的战斗伤害变成0
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- 这张卡的战斗发生的双方的战斗伤害变成0
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
-- 检查召唤条件：等级5以上、自己场上无怪兽、对方场上有怪兽、自己主要怪兽区有空位
function c33015627.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 检查自己场上怪兽数量是否为0
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上怪兽数量是否大于0
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己主要怪兽区是否有可用的空位
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 检查这张卡在本回合是否进行过战斗（GetBattledGroupCount>0）
function c33015627.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 设置伤害效果的目标玩家为对方，伤害数值为2000，并记录操作信息
function c33015627.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果对象玩家设置为对方玩家（1-tp）
	Duel.SetTargetPlayer(1-tp)
	-- 将效果参数设置为2000（伤害数值）
	Duel.SetTargetParam(2000)
	-- 设置连锁操作信息：效果分类为伤害，目标玩家为对方，数值为2000
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- 执行伤害效果处理，给予对方2000点伤害
function c33015627.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和伤害数值参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给予目标玩家2000点伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 检查当前是否为发动玩家的准备阶段
function c33015627.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家并检查是否等于发动玩家
	return Duel.GetTurnPlayer()==tp
end
-- 设置回卡组效果的操作信息，对象为这张卡
function c33015627.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：效果分类为回卡组，对象为这张卡，数量1
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 将这张卡返回持有者卡组并洗切
function c33015627.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以效果原因返回持有者卡组并洗切（SEQ_DECKSHUFFLE表示洗切）
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
