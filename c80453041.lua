--ファントム・オブ・ユベル
-- 效果：
-- 「于贝尔」怪兽＋攻击力和守备力是0的恶魔族怪兽
-- 让自己的手卡·场上·墓地的上记的卡回到卡组·额外卡组的场合才能特殊召唤。这张卡不能作为融合素材。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：对方怪兽的效果发动时，把这张卡解放才能发动。那个效果变成「对方把自身的手卡·卡组·场上1只「于贝尔」怪兽破坏」。
local s,id,o=GetID()
-- 注册卡片效果与召唤手续的初始化函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「于贝尔」怪兽＋攻击力和守备力是0的恶魔族怪兽
	aux.AddFusionProcFunFun(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1a5),s.ffilter,1,true)
	-- 设定接触融合的特殊召唤手续：将自己手卡·场上·墓地的上述卡片回到卡组·额外卡组
	aux.AddContactFusionProcedure(c,s.cfilter,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,aux.ContactFusionSendToDeck(c))
	-- 让自己的手卡·场上·墓地的上记的卡回到卡组·额外卡组的场合才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 这张卡不能作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e3)
	-- ②：对方怪兽的效果发动时，把这张卡解放才能发动。那个效果变成「对方把自身的手卡·卡组·场上1只「于贝尔」怪兽破坏」。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.chcon)
	e4:SetCost(s.chcost)
	e4:SetTarget(s.chtg)
	e4:SetOperation(s.chop)
	c:RegisterEffect(e4)
end
-- 过滤融合素材中攻击力和守备力是0的恶魔族怪兽
function s.ffilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttack(0) and c:IsDefense(0)
end
-- 过滤接触融合素材中可以回到卡组或额外卡组的怪兽
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
-- 检查是否为对方玩家发动的怪兽效果
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 效果发动的代价处理函数：解放自身
function s.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为效果发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤用于被破坏的「于贝尔」怪兽
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1a5) and c:IsFaceupEx()
end
-- 效果发动的目标检查函数：对方手卡、场上、卡组是否存在可破坏的「于贝尔」怪兽
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方的手卡、场上、卡组是否存在至少1只「于贝尔」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,rp,0,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,1,e:GetHandler()) end
end
-- 效果执行函数：将对方发动的效果替换为指定的破坏效果
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 清空当前连锁的效果对象
	Duel.ChangeTargetCard(ev,g)
	-- 将当前连锁的效果处理函数替换为s.repop
	Duel.ChangeChainOperation(ev,s.repop)
end
-- 替换后的效果处理函数：对方玩家选择自身手卡、卡组、场上1只「于贝尔」怪兽破坏
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让对方玩家从其自身的手卡、场上、卡组中选择1只「于贝尔」怪兽
	local g=Duel.SelectMatchingCard(1-tp,s.filter,tp,0,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,1,1,nil)
	if g:GetCount()>0 then
		-- 破坏被选择的怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
