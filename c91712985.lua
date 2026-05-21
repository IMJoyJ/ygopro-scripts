--時械神カミオン
-- 效果：
-- 这张卡不能从卡组特殊召唤。
-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：这张卡进行战斗的战斗阶段结束时发动。选对方场上1张卡回到持有者卡组，给与对方500伤害。不能对应这个效果的发动让卡的效果发动。
-- ④：自己准备阶段发动。这张卡回到持有者卡组。
function c91712985.initial_effect(c)
	-- 这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91712985,0))  --"不用解放作召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c91712985.ntcon)
	c:RegisterEffect(e2)
	-- ②：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
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
	-- ③：这张卡进行战斗的战斗阶段结束时发动。选对方场上1张卡回到持有者卡组，给与对方500伤害。不能对应这个效果的发动让卡的效果发动。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(91712985,1))
	e6:SetCategory(CATEGORY_TODECK+CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c91712985.tdcon)
	e6:SetTarget(c91712985.tdtg)
	e6:SetOperation(c91712985.tdop)
	c:RegisterEffect(e6)
	-- ④：自己准备阶段发动。这张卡回到持有者卡组。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(91712985,2))
	e7:SetCategory(CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c91712985.rtdcon)
	e7:SetTarget(c91712985.rtdtg)
	e7:SetOperation(c91712985.rtdop)
	c:RegisterEffect(e7)
end
-- 不用解放作召唤的判定条件
function c91712985.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 判定自己场上的怪兽数量是否为0
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判定自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判定这张卡在本次战斗阶段中是否进行过战斗
function c91712985.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 战斗阶段结束时效果的发动准备与连锁限制
function c91712985.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上可以回到卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 设置操作信息：将对方场上的1张卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		-- 设置操作信息：给与对方500点伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	end
	-- 限制连锁，使得双方不能对应这个效果的发动来发动卡的效果
	Duel.SetChainLimit(aux.FALSE)
end
-- 战斗阶段结束时效果的执行：选对方场上1张卡回到卡组，并给与对方500伤害
function c91712985.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择对方场上1张可以回到卡组的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功将选中的卡送回卡组或额外卡组
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 给与对方500点效果伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
-- 准备阶段回到卡组效果的发动条件判定
function c91712985.rtdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段回到卡组效果的发动准备
function c91712985.rtdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将自身送回持有者卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 准备阶段回到卡组效果的执行
function c91712985.rtdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡送回持有者卡组并洗牌
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
