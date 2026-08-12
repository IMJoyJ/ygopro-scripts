--時械神メタイオン
-- 效果：
-- 这张卡不能从卡组特殊召唤。
-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡不会被战斗·效果破坏，攻击表示的这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：这张卡进行战斗的战斗阶段结束时发动。这张卡以外的场上的怪兽全部回到持有者手卡，给与对方回去数量×300伤害。
-- ④：自己准备阶段发动。这张卡回到持有者卡组。
function c74530899.initial_effect(c)
	-- 这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74530899,0))  --"不用解放召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c74530899.ntcon)
	c:RegisterEffect(e2)
	-- ②：这张卡不会被战斗·效果破坏
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
	e5:SetCondition(c74530899.damcon)
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e5)
	-- ③：这张卡进行战斗的战斗阶段结束时发动。这张卡以外的场上的怪兽全部回到持有者手卡，给与对方回去数量×300伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(74530899,1))  --"这张卡以外的怪兽返回手牌"
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c74530899.thcon)
	e6:SetTarget(c74530899.thtg)
	e6:SetOperation(c74530899.thop)
	c:RegisterEffect(e6)
	-- ④：自己准备阶段发动。这张卡回到持有者卡组。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(74530899,2))  --"这张卡回到卡组"
	e7:SetCategory(CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c74530899.tdcon)
	e7:SetTarget(c74530899.tdtg)
	e7:SetOperation(c74530899.tdop)
	c:RegisterEffect(e7)
end
-- 不用解放作召唤的判定条件
function c74530899.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 判定自己场上的怪兽数量是否为0
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判定自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判定这张卡是否处于攻击表示
function c74530899.damcon(e)
	return e:GetHandler():IsAttackPos()
end
-- 判定这张卡在当前回合是否进行过战斗
function c74530899.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 怪兽回手牌及伤害效果的发动准备与操作信息注册
function c74530899.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上除这张卡以外所有可以回到手牌的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置将这些怪兽送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	-- 设置给与对方回去数量×300伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*300)
end
-- 怪兽回手牌及伤害效果的执行函数
function c74530899.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡以外所有可以回到手牌的怪兽（排除已不在场上的自身）
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	if g:GetCount()==0 then return end
	-- 因效果将符合条件的怪兽全部送回持有者手卡
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 获取实际被送回手牌（或额外卡组）的怪兽卡组
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_EXTRA)
	-- 给与对方实际回去数量×300的伤害
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end
-- 判定当前是否为自己的回合
function c74530899.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 回到卡组效果的发动准备与操作信息注册
function c74530899.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将这张卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 回到卡组效果的执行函数
function c74530899.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果将这张卡送回持有者卡组并洗牌
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
