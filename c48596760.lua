--闇の精霊 ルーナ
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只暗属性怪兽除外的场合可以特殊召唤。
-- ①：自己准备阶段发动。给与对方500伤害。
function c48596760.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把1只暗属性怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c48596760.spcon)
	e1:SetTarget(c48596760.sptg)
	e1:SetOperation(c48596760.spop)
	c:RegisterEffect(e1)
	-- ①：自己准备阶段发动。给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c48596760.damcon)
	e2:SetTarget(c48596760.damtg)
	e2:SetOperation(c48596760.damop)
	c:RegisterEffect(e2)
end
-- 定义额外怪兽筛选条件：必须是暗属性且可以作为代价从墓地除外。
function c48596760.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 判定特殊召唤手续是否满足：自己场上主要怪兽区有空位，且自己墓地存在1只暗属性且可以作为代价除外的怪兽。
function c48596760.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的主要怪兽区空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足spfilter条件的暗属性怪兽。
		and Duel.IsExistingMatchingCard(c48596760.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 执行特殊召唤手续的选择：从墓地筛选出可除外的暗属性怪兽，提示玩家选择1张作为除外的代价；若选择成功则将该卡存入效果对象，返回真，否则返回假。
function c48596760.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足spfilter条件（暗属性且可作为代价除外）的卡，存入候选组。
	local g=Duel.GetMatchingGroup(c48596760.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家显示“请选择要除外的卡”的提示，并指定移除语义。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤手续的代价处理：取出之前选择的卡片，将其表侧除外，完成召唤手续。
function c48596760.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 把选中的卡以表侧表示除外，除外的原因记为特殊召唤（REASON_SPSUMMON）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 判定①效果能否发动：当前回合玩家是这张卡的控制者（即自己的准备阶段）。
function c48596760.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家是自己，保证只在己方准备阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- ①效果的发动处理：无选择目标直接可发动，将对方玩家设为伤害对象，伤害值设为500，并设置操作信息供后续伤害处理。
function c48596760.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的对象玩家设为对方（1-tp），表示伤害的目标是对方。
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的对象参数设为500，作为伤害数值。
	Duel.SetTargetParam(500)
	-- 登记操作信息：效果分类为伤害，对象玩家为对方，参数为500，供相关效果检测（如精灵之镜）使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 执行①效果的伤害处理：从连锁信息中取出目标玩家和伤害值，给予对方玩家500点效果伤害。
function c48596760.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁记录的目标玩家（伤害对象）和伤害参数（500）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）对目标玩家造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
