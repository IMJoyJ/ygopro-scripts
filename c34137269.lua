--時械神ハイロン
-- 效果：
-- 这张卡不能从卡组特殊召唤。
-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：这张卡进行战斗的战斗阶段结束时发动。自己基本分比对方少的场合，给与对方那个相差数值的伤害。
-- ④：自己准备阶段发动。这张卡回到持有者卡组。
function c34137269.initial_effect(c)
	-- 这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34137269,0))  --"不用解放作召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c34137269.ntcon)
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
	local e5=e3:Clone()
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e5)
	-- ③：这张卡进行战斗的战斗阶段结束时发动。自己基本分比对方少的场合，给与对方那个相差数值的伤害。
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
	-- ④：自己准备阶段发动。这张卡回到持有者卡组。
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
-- ①的召唤规则效果条件：当无需解放召唤时，怪兽等级≥5，且自己场上没有怪兽、存在可用怪兽区域，才允许不用解放作召唤。
function c34137269.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 检查这张卡的控制者场上主要怪兽区没有怪兽，满足“自己场上没有怪兽存在”的条件。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查这张卡的控制者场上存在可用的怪兽区域，确保可以不解放召唤。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- ③的发动条件：这张卡在本战斗阶段进行过战斗，满足“这张卡进行战斗的战斗阶段结束时”。
function c34137269.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- ③发动时处理：将对方玩家设为效果对象，并计算双方LP差作为预计伤害值；若自己不低则伤害为0。
function c34137269.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家（1-tp）设置为当前连锁的对象玩家。
	Duel.SetTargetPlayer(1-tp)
	local dam=0
	-- 若自己LP低于对方LP，则将伤害值设为对方LP与己方LP的差值。
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) then dam=Duel.GetLP(1-tp)-Duel.GetLP(tp) end
	-- 登记伤害效果操作信息：目标为对方玩家，预计伤害数值为dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- ③的效果处理：取得对象玩家，按当前LP差实际给予伤害；若差值为正则造成等量伤害。
function c34137269.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁登记的对象玩家（对方）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算当前对方LP与己方LP的差值，作为此次要造成的伤害值。
	local val=Duel.GetLP(1-tp)-Duel.GetLP(tp)
	if val>0 then
		-- 以效果原因给对象玩家造成 val 点伤害。
		Duel.Damage(p,val,REASON_EFFECT)
	end
end
-- ④的发动条件：当前回合玩家为本卡控制者，即自己的准备阶段。
function c34137269.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者（tp），以确保是己方准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- ④发动时目标处理：不需要选择对象，登记将这张卡送回卡组的操作信息。
function c34137269.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将这张卡自身（1张）送入持有者卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ④的效果处理：若这张卡仍与效果关联，则将其送回持有者卡组。
function c34137269.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果原因将这张卡送回持有者卡组，并标记需要洗牌。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
