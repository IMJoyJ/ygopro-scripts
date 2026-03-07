--暗黒界の懲罰
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己或者对方把怪兽召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。那之后，从手卡选1只恶魔族怪兽丢弃。
-- ②：自己场上的「暗黑界」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
local s,id,o=GetID()
-- 创建并注册效果，使该卡在召唤或特殊召唤时可以发动，同时设置其为永续效果并注册代替破坏效果
function s.initial_effect(c)
	-- ①：自己或者对方把怪兽召唤·特殊召唤之际才能发动。那个无效，那些怪兽破坏。那之后，从手卡选1只恶魔族怪兽丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCountLimit(1,id)
	-- 判断当前是否没有正在进行的连锁，确保效果只能在空闲时机发动
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)
	-- ②：自己场上的「暗黑界」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数，用于判断手牌中是否存在恶魔族且可因效果丢弃的卡片
function s.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsDiscardable(REASON_EFFECT)
end
-- 设置效果的发动条件，检查手牌中是否存在满足条件的恶魔族怪兽，并设置连锁操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁操作信息，将无效召唤的效果分类加入操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置连锁操作信息，将破坏的效果分类加入操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
	-- 设置连锁操作信息，将丢弃手牌的效果分类加入操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
end
-- 执行效果操作，使召唤无效并破坏怪兽，然后选择并丢弃手牌
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在召唤的怪兽无效
	Duel.NegateSummon(eg)
	-- 破坏怪兽，若无怪兽被破坏则返回
	if Duel.Destroy(eg,REASON_EFFECT)==0 then return end
	-- 提示玩家选择丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的恶魔族怪兽丢弃
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 将选中的恶魔族怪兽送入墓地并标记为丢弃
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 定义代替破坏的过滤函数，判断场上是否满足条件的暗黑界怪兽
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x6) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and not c:IsReason(REASON_REPLACE) and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 设置代替破坏效果的发动条件，检查是否可以发动并询问玩家是否发动
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 设置代替破坏效果的值，返回是否满足代替破坏条件
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏效果的操作，将此卡从墓地除外
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从墓地除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
