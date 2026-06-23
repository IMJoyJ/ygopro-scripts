--双天将 金剛
-- 效果：
-- 「双天拳之熊罴」＋「双天」怪兽×2
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ②：这张卡攻击的伤害计算后才能发动。选对方场上1只怪兽回到持有者手卡。
-- ③：自己场上有融合怪兽2只以上存在，场上的这张卡为对象的对方的魔法·陷阱卡的效果发动时才能发动。那个发动无效。
function c33026283.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为85360035的怪兽和2个满足过滤条件的怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,85360035,aux.FilterBoolFunction(Card.IsFusionSetCard,0x14f),2,true,true)
	-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c33026283.matcheck)
	c:RegisterEffect(e0)
	-- ②：这张卡攻击的伤害计算后才能发动。选对方场上1只怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(c33026283.actcon)
	c:RegisterEffect(e1)
	-- ③：自己场上有融合怪兽2只以上存在，场上的这张卡为对象的对方的魔法·陷阱卡的效果发动时才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33026283,0))  --"破坏怪兽"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c33026283.thcon)
	e2:SetTarget(c33026283.thtg)
	e2:SetOperation(c33026283.thop)
	c:RegisterEffect(e2)
	-- 为融合素材中包含效果怪兽的融合召唤注册标志位
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33026283,1))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,33026283)
	e3:SetCondition(c33026283.discon)
	e3:SetTarget(c33026283.distg)
	e3:SetOperation(c33026283.disop)
	c:RegisterEffect(e3)
end
-- 当攻击怪兽为自身或被攻击怪兽为自身时触发
function c33026283.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_EFFECT) then
		c:RegisterFlagEffect(85360035,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
end
-- 判断是否为攻击怪兽或被攻击怪兽
function c33026283.actcon(e)
	-- 判断是否为攻击怪兽
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- 过滤满足条件的怪兽
function c33026283.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 设置操作信息，指定将目标怪兽送入手牌
	return Duel.GetAttacker()==e:GetHandler()
end
-- 选择满足条件的怪兽
function c33026283.thfilter(c)
	return c:IsAbleToHand() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 提示选择要送入手牌的怪兽
function c33026283.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从对方场上选择满足条件的怪兽
	local g=Duel.GetMatchingGroup(c33026283.thfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息，指定将目标怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 将选中的怪兽送入手牌
function c33026283.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要送入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c33026283.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		-- 显示选中的怪兽被选为对象
		Duel.HintSelection(g)
		-- 将选中的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤满足条件的融合怪兽
function c33026283.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 判断连锁是否可以被无效
function c33026283.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 获取连锁的目标卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断连锁的目标是否包含自身，且为魔法或陷阱卡
	return tg and tg:IsContains(c) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(c33026283.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 设置操作信息，指定使发动无效
function c33026283.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 使连锁发动无效
function c33026283.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效
	Duel.NegateActivation(ev)
end
