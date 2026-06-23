--トライゲート・ウィザード
-- 效果：
-- 衍生物以外的怪兽2只以上
-- ①：得到和这张卡互相连接的怪兽数量的以下效果。
-- ●1只以上：和这张卡互相连接的怪兽在和对方怪兽进行战斗的场合，那只怪兽给与对方的战斗伤害变成2倍。
-- ●2只以上：1回合1次，以场上1张卡为对象才能发动。那张卡除外。
-- ●3只：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并除外。
function c32617464.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2个非衍生物的怪兽作为连接素材
	aux.AddLinkProcedure(c,c32617464.matfilter,2)
	c:EnableReviveLimit()
	-- ●1只以上：和这张卡互相连接的怪兽在和对方怪兽进行战斗的场合，那只怪兽给与对方的战斗伤害变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c32617464.damtg)
	-- 设置战斗伤害变为2倍
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
	-- ●2只以上：1回合1次，以场上1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32617464,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c32617464.rmcon)
	e2:SetTarget(c32617464.rmtg)
	e2:SetOperation(c32617464.rmop)
	c:RegisterEffect(e2)
	-- ●3只：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32617464,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c32617464.negcon)
	-- 设置效果目标为处理连锁无效化和除外的操作
	e3:SetTarget(aux.nbtg)
	e3:SetOperation(c32617464.negop)
	c:RegisterEffect(e3)
end
-- 连接素材过滤器，排除衍生物类型
function c32617464.matfilter(c)
	return not c:IsLinkType(TYPE_TOKEN)
end
-- 判断是否为与该卡互相连接且参与战斗的怪兽
function c32617464.damtg(e,c)
	local lg=e:GetHandler():GetMutualLinkedGroup()
	return lg:IsContains(c) and c:GetBattleTarget()~=nil and c:GetBattleTarget():GetControler()==1-e:GetHandlerPlayer()
end
-- 判断该卡是否已连接至少2只怪兽
function c32617464.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>=2
end
-- 选择场上一张可除外的卡作为效果对象
function c32617464.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 检查是否有满足条件的卡可作为效果对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上一张可除外的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，记录将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行将目标卡除外的操作
function c32617464.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 无效化并除外对方发动的效果
function c32617464.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确保该卡未在战斗中被破坏、可无效连锁且已连接至少3只怪兽
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and c:GetMutualLinkedGroupCount()>=3
end
-- 处理连锁无效化和除外操作
function c32617464.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效化连锁并确认效果发动者存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将连锁中的卡除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
