--ウズヒメの御巫
-- 效果：
-- 3星「御巫」怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张装备魔法卡加入手卡。
-- ②：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受。
-- ③：这张卡进行攻击的伤害步骤结束时，把这张卡1个超量素材取除才能发动。这张卡可以继续攻击。
local s,id,o=GetID()
-- 初始化卡片效果，注册超量召唤手续、苏生限制以及4个卡片效果
function s.initial_effect(c)
	-- 设置超量召唤手续：等级3的「御巫」怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x18d),3,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张装备魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这张卡的战斗发生的对自己的战斗伤害由对方代受。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡进行攻击的伤害步骤结束时，把这张卡1个超量素材取除才能发动。这张卡可以继续攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"继续攻击"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(s.atcon)
	e4:SetCost(s.atcost)
	e4:SetOperation(s.atop)
	c:RegisterEffect(e4)
end
-- 过滤条件：卡组或墓地中的装备魔法卡
function s.thfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果①（检索/回收装备魔法）的发动准备与检测
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否存在可以加入手牌的装备魔法卡（受王家长眠之谷影响）
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从卡组或墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①（检索/回收装备魔法）的效果处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张满足条件的装备魔法卡（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③（追加攻击）的发动条件
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前进行攻击的怪兽是否是自身，且自身是否可以继续进行攻击
	return Duel.GetAttacker()==c and c:IsChainAttackable(0)
end
-- 效果③（追加攻击）的发动代价：取除这张卡的1个超量素材
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果③（追加攻击）的效果处理
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使这张卡可以再进行1次攻击
	Duel.ChainAttack()
end
