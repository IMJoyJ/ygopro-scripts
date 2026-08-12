--WW－ブリザード・ベル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有「风魔女」怪兽的场合，这张卡可以不用解放作召唤。
-- ②：自己场上有「风魔女-雪暴铃」以外的「风魔女」怪兽存在的场合，对方主要阶段，把手卡·场上的这张卡送去墓地才能发动。给与对方500伤害。
function c84851250.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有「风魔女」怪兽的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84851250,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c84851250.ntcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有「风魔女-雪暴铃」以外的「风魔女」怪兽存在的场合，对方主要阶段，把手卡·场上的这张卡送去墓地才能发动。给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84851250,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,84851250)
	e2:SetCondition(c84851250.damcon)
	e2:SetCost(c84851250.damcost)
	e2:SetTarget(c84851250.damtg)
	e2:SetOperation(c84851250.damop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「风魔女」怪兽
function c84851250.ntfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf0)
end
-- 不用解放作召唤的条件函数
function c84851250.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否为5星以上怪兽、召唤所需解放数是否为0，且怪兽区域有空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上的怪兽数量是否等于自己场上的「风魔女」怪兽数量（即没有怪兽或只有「风魔女」怪兽）
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==Duel.GetMatchingGroupCount(c84851250.ntfilter,tp,LOCATION_MZONE,0,nil)
end
-- 过滤自己场上表侧表示的「风魔女-雪暴铃」以外的「风魔女」怪兽
function c84851250.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf0) and not c:IsCode(84851250)
end
-- 给与伤害效果的发动条件函数
function c84851250.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「风魔女-雪暴铃」以外的「风魔女」怪兽
	if not Duel.IsExistingMatchingCard(c84851250.damfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 检查当前是否为对方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()==1-tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 给与伤害效果的代价函数
function c84851250.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 作为发动代价，将这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 给与伤害效果的确定目标函数
function c84851250.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为500
	Duel.SetTargetParam(500)
	-- 设置操作信息为给与对方500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 给与伤害效果的执行函数
function c84851250.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
