--中生代化石マシン スカルワゴン
-- 效果：
-- 自己墓地的岩石族怪兽＋5·6星的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ②：这张卡战斗破坏对方怪兽时才能发动。给与对方800伤害。
-- ③：把墓地的这张卡除外，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c83656563.initial_effect(c)
	-- 记录该卡在卡片效果中记载了「化石融合」（卡号59419719）的卡名
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，需要满足过滤条件1和过滤条件2的怪兽各1只作为素材
	aux.AddFusionProcFun2(c,c83656563.matfilter1,c83656563.matfilter2,true)
	-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为必须满足「化石融合」的特殊召唤条件
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。给与对方800伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83656563,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 设置效果触发条件为这张卡战斗破坏对方怪兽
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c83656563.damtg)
	e3:SetOperation(c83656563.damop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(83656563,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,83656563)
	-- 设置效果发动的Cost为将墓地的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c83656563.destg)
	e4:SetOperation(c83656563.desop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤条件1：自己墓地的岩石族怪兽
function c83656563.matfilter1(c,fc)
	return c:IsRace(RACE_ROCK) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(fc:GetControler())
end
-- 融合素材过滤条件2：5·6星的怪兽
function c83656563.matfilter2(c,fc)
	return c:IsLevel(5,6)
end
-- 伤害效果的发动准备与目标确认函数
function c83656563.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的参数为800点
	Duel.SetTargetParam(800)
	-- 设置当前连锁的操作信息为给与对方玩家800点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 伤害效果的执行函数
function c83656563.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤场上的魔法·陷阱卡
function c83656563.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动准备与对象选择函数
function c83656563.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c83656563.filter(chkc) end
	-- 检查场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c83656563.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给发动效果的玩家发送选择要破坏的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c83656563.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行函数
function c83656563.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
