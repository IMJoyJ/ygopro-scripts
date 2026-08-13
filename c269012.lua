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
	-- 不会被效果破坏。
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
	-- ②：自己或者对方的10星以上的怪兽战斗破坏怪兽送去墓地的场合发动。破坏的怪兽的控制者受到1000伤害。
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
	-- ③：场上的这张卡被效果破坏送去墓地时才能发动。从卡组把1只神属性怪兽加入手卡。
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
-- 该筛选函数判断怪兽是否为10星以上，作为①效果保护对象的过滤条件。
function c269012.target(e,c)
	return c:IsLevelAbove(10)
end
-- ②效果发动条件：被战斗破坏的怪兽在墓地且是怪兽，其战斗破坏来源（攻击怪兽）与那次战斗相关且等级为10星以上。
function c269012.damcon(e,tp,eg,ep,ev,re,r,rp)
	local des=eg:GetFirst()
	local rc=des:GetReasonCard()
	return des:IsLocation(LOCATION_GRAVE) and des:IsType(TYPE_MONSTER) and rc:IsRelateToBattle() and rc:IsLevelAbove(10)
end
-- 伤害效果的目标设定：将受到伤害的玩家设为被破坏怪兽的原控制者，伤害值设为1000，并登记伤害效果的操作信息。
function c269012.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local damp=eg:GetFirst():GetPreviousControler()
	-- 将被破坏怪兽的原控制者设置为当前连锁的对象玩家，即伤害的承受者。
	Duel.SetTargetPlayer(damp)
	-- 将连锁参数设置为1000，表示造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：本次连锁处理将造成伤害，对象玩家为damp，伤害值为1000。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,damp,1000)
end
-- 伤害效果处理：从连锁信息中取出之前设定的对象玩家和伤害值，对那名玩家造成1000点效果伤害。
function c269012.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的对象玩家和参数（伤害值），分别存入p和v。
	local p,v=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对玩家p造成v点伤害。
	Duel.Damage(p,v,REASON_EFFECT)
end
-- ③发动条件：此卡因效果破坏而送去墓地，且之前位于场上。
function c269012.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索筛选条件：卡组中满足神属性、怪兽卡且能够加入手卡的卡。
function c269012.filter(c)
	return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的目标设定：发动时检查卡组中是否存在符合条件的怪兽；若存在，则登记操作信息为从卡组检索加入手卡。
function c269012.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认卡组中有无满足过滤条件的神属性怪兽，若无则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c269012.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：效果处理时从卡组将1张卡加入手卡，检索区域为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：提示玩家选择1张符合条件的卡，将其加入手卡，并让对手确认。
function c269012.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，提示玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选出1张符合条件的神属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c269012.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（nil表示返回持有者手卡），原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
