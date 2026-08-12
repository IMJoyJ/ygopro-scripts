--百万喰らいのグラットン
-- 效果：
-- 这张卡不能通常召唤。从自己的手卡·场上·额外卡组把卡5张以上里侧表示除外的场合才能特殊召唤。
-- ①：这张卡的攻击力·守备力上升里侧表示除外中的卡数量×100。
-- ②：这张卡只要在怪兽区域存在，不能解放，也不能作为融合·同调·超量召唤的素材。
-- ③：1回合1次，这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽里侧表示除外。
function c63845230.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 从自己的手卡·场上·额外卡组把卡5张以上里侧表示除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c63845230.spcon)
	e2:SetTarget(c63845230.sptg)
	e2:SetOperation(c63845230.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击力·守备力上升里侧表示除外中的卡数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c63845230.val)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ②：这张卡只要在怪兽区域存在，不能解放
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UNRELEASABLE_SUM)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e7:SetValue(c63845230.fuslimit)
	c:RegisterEffect(e7)
	local e8=e5:Clone()
	e8:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e8)
	local e9=e5:Clone()
	e9:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e9)
	-- ③：1回合1次，这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽里侧表示除外。
	local ea=Effect.CreateEffect(c)
	ea:SetDescription(aux.Stringid(63845230,0))
	ea:SetCategory(CATEGORY_REMOVE)
	ea:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	ea:SetCode(EVENT_BATTLE_START)
	ea:SetCountLimit(1)
	ea:SetTarget(c63845230.rmtg)
	ea:SetOperation(c63845230.rmop)
	c:RegisterEffect(ea)
end
-- 限制不能作为融合召唤的素材
function c63845230.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 特殊召唤规则的条件检查函数
function c63845230.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 若怪兽区无空位，则检查是否有足够数量的场上怪兽可以作为除外消耗以空出位置，否则不能特殊召唤
	if ft<=0 and Duel.GetMatchingGroupCount(Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE,0,c,POS_FACEDOWN)<=-ft then return false end
	-- 获取手卡、场上、额外卡组中可以作为消耗里侧表示除外的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA,0,c,POS_FACEDOWN)
	-- 检查是否能选出5张以上且能满足怪兽区域空位要求的卡片进行除外
	return g:CheckSubGroup(aux.mzctcheck,5,#g,tp)
end
-- 特殊召唤规则的消耗选择（Target）函数
function c63845230.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡、场上、额外卡组中可以作为消耗里侧表示除外的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA,0,c,POS_FACEDOWN)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择5张以上且能满足怪兽区域空位要求的卡片
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,5,#g,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行（Operation）函数
function c63845230.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡片里侧表示除外作为特殊召唤的消耗
	Duel.Remove(g,POS_FACEDOWN,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 计算攻击力·守备力上升数值的辅助函数
function c63845230.val(e,c)
	-- 返回双方除外区里侧表示卡片数量乘以100的值
	return Duel.GetMatchingGroupCount(Card.IsFacedown,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)*100
end
-- 伤害步骤开始时除外对方怪兽效果的发动准备与合法性检查
function c63845230.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) and tc:IsAbleToRemove(tp,POS_FACEDOWN) end
	-- 设置连锁处理信息为除外1只战斗的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end
-- 伤害步骤开始时除外对方怪兽效果的实际处理
function c63845230.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToBattle() then
		-- 将进行战斗的对方怪兽里侧表示除外
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
