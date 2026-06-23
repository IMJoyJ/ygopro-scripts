--覇魔導士アーカナイト・マジシャン
-- 效果：
-- 魔法师族同调怪兽＋魔法师族怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡融合召唤成功的场合发动。给这张卡放置2个魔力指示物。
-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×1000。
-- ③：1回合1次，可以把自己场上1个魔力指示物取除，从以下效果选择1个发动。
-- ●以场上1张卡为对象才能发动。那张卡破坏。
-- ●自己从卡组抽1张。
function c21113684.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足条件的同调怪兽和魔法师族怪兽作为融合素材
	aux.AddFusionProcFun2(c,c21113684.ffilter,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),true)
	-- 这张卡的攻击力上升这张卡的魔力指示物数量×1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c21113684.attackup)
	c:RegisterEffect(e2)
	-- ①：这张卡融合召唤成功的场合发动。给这张卡放置2个魔力指示物
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21113684,0))  --"放置魔力指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c21113684.addcc)
	e3:SetTarget(c21113684.addct)
	e3:SetOperation(c21113684.addc)
	c:RegisterEffect(e3)
	-- ③：1回合1次，可以把自己场上1个魔力指示物取除，从以下效果选择1个发动。●以场上1张卡为对象才能发动。那张卡破坏
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(21113684,1))  --"场上1张卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCost(c21113684.cost)
	e4:SetTarget(c21113684.destg)
	e4:SetOperation(c21113684.desop)
	c:RegisterEffect(e4)
	-- ③：1回合1次，可以把自己场上1个魔力指示物取除，从以下效果选择1个发动。●自己从卡组抽1张
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(21113684,2))  --"抽1张卡"
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e5:SetCost(c21113684.cost)
	e5:SetTarget(c21113684.drtg)
	e5:SetOperation(c21113684.drop)
	c:RegisterEffect(e5)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetCode(EFFECT_SPSUMMON_CONDITION)
	e6:SetValue(c21113684.splimit)
	c:RegisterEffect(e6)
end
c21113684.material_type=TYPE_SYNCHRO
-- 当此卡从额外卡组特殊召唤时，必须使用融合召唤方式
function c21113684.splimit(e,se,sp,st)
	if e:GetHandler():IsLocation(LOCATION_EXTRA) then
		return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
	end
	return true
end
-- 过滤满足同调类型且为魔法师族的融合素材怪兽
function c21113684.ffilter(c)
	return c:IsFusionType(TYPE_SYNCHRO) and c:IsRace(RACE_SPELLCASTER)
end
-- 返回此卡魔力指示物数量乘以1000的攻击力
function c21113684.attackup(e,c)
	return c:GetCounter(0x1)*1000
end
-- 判断此卡是否为融合召唤方式特殊召唤
function c21113684.addcc(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 设置连锁操作信息，表示将放置2个魔力指示物
function c21113684.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将放置2个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x1)
end
-- 若此卡与效果相关，则放置2个魔力指示物
function c21113684.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 支付1个魔力指示物作为cost，发动效果
function c21113684.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以移除1个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_COST) end
	-- 向对方提示此卡发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 移除己方1个魔力指示物作为cost
	Duel.RemoveCounter(tp,1,0,0x1,1,REASON_COST)
end
-- 设置破坏效果的目标选择
function c21113684.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可作为破坏对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，表示将破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 若目标卡与效果相关，则将其破坏
function c21113684.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 设置抽卡效果的目标选择
function c21113684.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息，表示将抽卡的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息，表示将抽卡的数量
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息，表示将抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果
function c21113684.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
