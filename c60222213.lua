--時械神ラフィオン
-- 效果：
-- 这张卡不能从卡组特殊召唤。
-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：这张卡进行战斗的战斗阶段结束时发动。选这个回合和这张卡进行过战斗的对方场上1只表侧表示怪兽，给与对方那个攻击力数值的伤害。
-- ④：自己准备阶段发动。这张卡回到持有者卡组。
function c60222213.initial_effect(c)
	-- 这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60222213,0))  --"不用解放作召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c60222213.ntcon)
	c:RegisterEffect(e2)
	-- ②：这张卡不会被战斗·效果破坏。
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
	-- ③：这张卡进行战斗的战斗阶段结束时发动。选这个回合和这张卡进行过战斗的对方场上1只表侧表示怪兽，给与对方那个攻击力数值的伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c60222213.damcon)
	e6:SetTarget(c60222213.damtg)
	e6:SetOperation(c60222213.damop)
	c:RegisterEffect(e6)
	-- ④：自己准备阶段发动。这张卡回到持有者卡组。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(60222213,1))
	e7:SetCategory(CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c60222213.tdcon)
	e7:SetTarget(c60222213.tdtg)
	e7:SetOperation(c60222213.tdop)
	c:RegisterEffect(e7)
end
-- 判断这张卡能否不用解放作召唤：若c为空则允许；否则要求召唤方式是免解放、等级≥5、自己场上没有怪兽且主要怪兽区有空位。
function c60222213.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 检查自己场上没有怪兽。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查主要怪兽区有空位可以放置怪兽。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 筛选对方场上表侧表示且在本回合与这张卡进行过战斗的怪兽。
function c60222213.damfilter(c,e)
	return c:IsFaceup() and e:GetHandler():GetBattledGroup():IsContains(c)
end
-- 发动条件：这张卡本回合进行过战斗（战斗组中存在怪兽）。
function c60222213.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 该效果发动时的目标阶段：无需指定目标，直接允许发动（目标在效果处理时选择）。
function c60222213.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 效果处理：选择对方场上1只与这张卡战斗过的表侧表示怪兽，给予对方该怪兽攻击力数值的伤害。
function c60222213.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向操作者显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择1只满足damfilter的表侧表示怪兽（即与这张卡进行过战斗的表侧表示怪兽）。
	local g=Duel.SelectMatchingCard(tp,c60222213.damfilter,tp,0,LOCATION_MZONE,1,1,nil,e)
	local tc=g:GetFirst()
	if tc and c:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 给对方造成所选怪兽攻击力数值的伤害。
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
-- ④效果的发动条件：当前回合玩家是自己，即自己的准备阶段。
function c60222213.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（这张卡的控制者）。
	return Duel.GetTurnPlayer()==tp
end
-- 效果发动时允许发动，并登记将这张卡返回持有者卡组的操作信息。
function c60222213.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记效果处理时会将这张卡返回卡组的操作信息，供其他效果连锁时参考。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果相关，则将其返回持有者卡组并洗切。
function c60222213.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡返回持有者卡组，并洗切卡组。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
