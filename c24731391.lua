--サイバース・マジシャン
-- 效果：
-- 「电脑网仪式」降临。
-- ①：只要这张卡在怪兽区域存在，自己受到的全部伤害变成一半。
-- ②：只要自己场上有连接怪兽存在，对方不能选择自己场上的其他怪兽作为攻击对象，也不能作为效果的对象。
-- ③：只在这张卡和连接怪兽进行战斗的伤害计算时让这张卡的攻击力上升1000。
-- ④：这张卡被对方的效果破坏的场合才能发动。从卡组把1只电子界族怪兽加入手卡。
function c24731391.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己受到的全部伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c24731391.val)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有连接怪兽存在，对方不能选择自己场上的其他怪兽作为攻击对象，也不能作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetCondition(c24731391.atcon)
	e2:SetValue(c24731391.atlimit)
	c:RegisterEffect(e2)
	-- ②：只要自己场上有连接怪兽存在，对方不能选择自己场上的其他怪兽作为攻击对象，也不能作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c24731391.atcon)
	e3:SetTarget(c24731391.tglimit)
	-- 设置效果值为aux.tgoval函数，用于判断目标是否能成为对方效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：只在这张卡和连接怪兽进行战斗的伤害计算时让这张卡的攻击力上升1000。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetCondition(c24731391.atkcon)
	e4:SetValue(1000)
	c:RegisterEffect(e4)
	-- ④：这张卡被对方的效果破坏的场合才能发动。从卡组把1只电子界族怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(24731391,0))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c24731391.thcon)
	e5:SetTarget(c24731391.thtg)
	e5:SetOperation(c24731391.thop)
	c:RegisterEffect(e5)
end
-- 将受到的伤害值减半
function c24731391.val(e,re,dam,r,rp,rc)
	return math.floor(dam/2)
end
-- 过滤出连接怪兽
function c24731391.filter(c)
	return c:IsType(TYPE_LINK)
end
-- 判断自己场上是否存在连接怪兽
function c24731391.atcon(e)
	-- 检查自己场上是否存在至少1只连接怪兽
	return Duel.IsExistingMatchingCard(c24731391.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 设置不能成为攻击对象的过滤函数，排除自身
function c24731391.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 设置不能成为效果对象的过滤函数，排除自身
function c24731391.tglimit(e,c)
	return c~=e:GetHandler()
end
-- 判断是否处于伤害计算阶段且战斗对象为连接怪兽
function c24731391.atkcon(e)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 当前阶段为伤害计算阶段且存在战斗对象且该对象为连接怪兽
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and bc and bc:IsType(TYPE_LINK)
end
-- 过滤出电子界族的怪兽
function c24731391.thfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断该卡是否因对方效果被破坏且为己方控制者
function c24731391.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 设置连锁处理信息，确定从卡组检索电子界族怪兽加入手牌
function c24731391.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的电子界族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c24731391.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，指定将要处理的卡为1张手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行从卡组检索电子界族怪兽并加入手牌的操作
function c24731391.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张电子界族怪兽
	local g=Duel.SelectMatchingCard(tp,c24731391.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
