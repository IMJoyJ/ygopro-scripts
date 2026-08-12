--インフェルノ
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只炎属性怪兽除外的场合可以特殊召唤。
-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方1500伤害。
function c74823665.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把1只炎属性怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c74823665.spcon)
	e1:SetTarget(c74823665.sptg)
	e1:SetOperation(c74823665.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方1500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74823665,0))  --"1500伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCondition(c74823665.damcon)
	e2:SetTarget(c74823665.damtg)
	e2:SetOperation(c74823665.damop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以作为特殊召唤Cost除外的炎属性怪兽
function c74823665.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判断函数，检查怪兽区域是否有空位以及墓地是否存在可除外的炎属性怪兽
function c74823665.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的炎属性怪兽
		and Duel.IsExistingMatchingCard(c74823665.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则的目标选择函数，用于在手牌特殊召唤时选择并记录要除外的怪兽
function c74823665.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足过滤条件的炎属性怪兽
	local g=Duel.GetMatchingGroup(c74823665.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送提示信息，提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作函数，将选定的怪兽除外
function c74823665.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽以特殊召唤原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 伤害效果的发动条件判断，检查自身是否仍在战斗中，且被战斗破坏的怪兽是否已送去墓地
function c74823665.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
-- 伤害效果的启动与目标设置函数，设定伤害对象为对方玩家，伤害数值为1500
function c74823665.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数（伤害数值）设置为1500
	Duel.SetTargetParam(1500)
	-- 设置当前连锁的操作信息，表示该效果会给与对方玩家1500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
-- 伤害效果的执行函数，获取目标玩家和伤害数值并执行伤害处理
function c74823665.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
