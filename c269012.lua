--神縛りの塚
-- 效果：
-- ①：场上的10星以上的怪兽不会成为效果的对象，不会被效果破坏。
-- ②：自己或者对方的10星以上的怪兽战斗破坏怪兽送去墓地的场合发动。破坏的怪兽的控制者受到1000伤害。
-- ③：场上的这张卡被效果破坏送去墓地时才能发动。从卡组把1只神属性怪兽加入手卡。
function c269012.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：①：场上的10星以上的怪兽不会成为效果的对象，不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c269012.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e3)
	-- 效果原文：②：自己或者对方的10星以上的怪兽战斗破坏怪兽送去墓地的场合发动。破坏的怪兽的控制者受到1000伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(269012,0))  --"1000伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(c269012.damcon)
	e4:SetTarget(c269012.damtg)
	e4:SetOperation(c269012.damop)
	c:RegisterEffect(e4)
	-- 效果原文：③：场上的这张卡被效果破坏送去墓地时才能发动。从卡组把1只神属性怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(269012,1))  --"检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c269012.thcon)
	e5:SetTarget(c269012.thtg)
	e5:SetOperation(c269012.thop)
	c:RegisterEffect(e5)
end
-- 规则层面：判断目标怪兽是否为10星以上
function c269012.target(e,c)
	return c:IsLevelAbove(10)
end
-- 规则层面：判断被战斗破坏的怪兽是否为10星以上且其战斗相关卡存在于场上
function c269012.damcon(e,tp,eg,ep,ev,re,r,rp)
	local des=eg:GetFirst()
	local rc=des:GetReasonCard()
	return des:IsLocation(LOCATION_GRAVE) and des:IsType(TYPE_MONSTER) and rc:IsRelateToBattle() and rc:IsLevelAbove(10)
end
-- 规则层面：设置伤害效果的目标玩家为被战斗破坏怪兽的前控制者，并设置伤害值为1000
function c269012.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local damp=eg:GetFirst():GetPreviousControler()
	-- 规则层面：设置当前连锁处理的伤害对象为指定玩家
	Duel.SetTargetPlayer(damp)
	-- 规则层面：设置当前连锁处理的伤害值为1000
	Duel.SetTargetParam(1000)
	-- 规则层面：设置当前连锁操作信息为造成1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,damp,1000)
end
-- 规则层面：执行对指定玩家造成1000点伤害的效果
function c269012.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁处理的伤害对象和伤害值
	local p,v=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面：对指定玩家造成指定伤害值的伤害
	Duel.Damage(p,v,REASON_EFFECT)
end
-- 规则层面：判断此卡是否因效果破坏且从场上送去墓地
function c269012.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 规则层面：过滤函数，筛选神属性且为怪兽的卡
function c269012.filter(c)
	return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 规则层面：设置检索效果的目标为从卡组检索1只神属性怪兽加入手牌
function c269012.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c269012.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面：设置当前连锁操作信息为将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面：执行检索并加入手牌的效果
function c269012.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面：选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c269012.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面：确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
