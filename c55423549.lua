--黒き魔族－レオ・ウィザード
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：双方在原本等级是4星以下而攻击力或守备力比1350大的怪兽从手卡召唤的场合，必须把1只怪兽解放来上级召唤。
-- ②：这张卡和光属性怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只攻击力1350的怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 必须把1只怪兽解放来上级召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e0:SetCondition(s.ttcon)
	e0:SetOperation(s.ttop)
	e0:SetValue(SUMMON_TYPE_ADVANCE)
	-- ①：双方在原本等级是4星以下而攻击力或守备力比1350大的怪兽从手卡召唤的场合，必须把1只怪兽解放来上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e1:SetTarget(s.eftg)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	-- ②：这张卡和光属性怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只攻击力1350的怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"卡组检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 检查是否满足上级召唤的解放怪兽条件
function s.ttcon(e,c,minc)
	if c==nil then return true end
	local min,max=c:GetTributeRequirement()
	-- 检查召唤所需的最少解放怪兽数量是否不大于1，且场上是否存在至少1只可解放的怪兽
	return min<=1 and Duel.CheckTribute(c,1)
end
-- 执行解放1只怪兽进行上级召唤的操作
function s.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择1只用于上级召唤的解放怪兽
	local g=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(g)
	-- 将选中的怪兽作为召唤素材解放
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤原本等级在4星以下且原本攻击力或守备力在1351以上的怪兽
function s.eftg(e,c)
	return c:GetOriginalLevel()<=4 and (c:IsAttackAbove(1351) or c:IsDefenseAbove(1351))
end
-- 伤害步骤开始时破坏效果的发动条件检查与操作信息设置
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是自身，则将目标设定为被攻击的怪兽
	if tc==c then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsAttribute(ATTRIBUTE_LIGHT) end
	-- 设置连锁处理中的操作信息为破坏该战斗对手怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 伤害步骤开始时破坏效果的执行函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是自身，则将目标设定为被攻击的怪兽
	if tc==c then tc=Duel.GetAttackTarget() end
	-- 若该怪兽仍处于战斗状态，则用效果将其破坏
	if tc:IsRelateToBattle() then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 检查此卡是否因战斗或效果被破坏
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤卡组中攻击力为1350且能加入手牌的怪兽
function s.thfilter(c)
	return c:IsAttack(1350) and c:IsAbleToHand()
end
-- 检索效果的发动条件检查与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的攻击力1350的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数，将卡片加入手牌并展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 用效果将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
