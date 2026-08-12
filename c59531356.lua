--中生代化石騎士 スカルナイト
-- 效果：
-- 岩石族怪兽＋5·6星的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：这张卡的攻击破坏怪兽时才能发动。这张卡只再1次可以继续攻击。
-- ③：把墓地的这张卡除外，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c59531356.initial_effect(c)
	-- 注册该卡片记有卡名「化石融合」
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 注册融合召唤手续：岩石族怪兽＋5·6星的怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),c59531356.matfilter,true)
	-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为只能通过「化石融合」的效果从额外卡组特殊召唤
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ②：这张卡的攻击破坏怪兽时才能发动。这张卡只再1次可以继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(59531356,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c59531356.atcon)
	e3:SetOperation(c59531356.atop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(59531356,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,59531356)
	-- 设置发动成本为将墓地的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c59531356.drytg)
	e4:SetOperation(c59531356.dryop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤条件：等级为5或6的怪兽
function c59531356.matfilter(c)
	return c:IsLevel(5,6)
end
-- 连续攻击效果的发动条件判定函数
function c59531356.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定当前攻击怪兽是自身、自身因战斗破坏了对方怪兽且可以继续进行攻击
	return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable()
end
-- 连续攻击效果的处理函数
function c59531356.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使这张卡可以再进行1次攻击
	Duel.ChainAttack()
end
-- 破坏效果的发动准备与目标选择函数
function c59531356.drytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 破坏效果的执行函数
function c59531356.dryop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 破坏该目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
