--K9－ØØ号 “Hound”
-- 效果：
-- 5星怪兽×2
-- ①：这张卡在特殊召唤的回合不会被战斗以及对方的效果破坏。
-- ②：只要这张卡在怪兽区域存在，每次对方把怪兽的效果发动，这张卡的攻击力上升500。
-- ③：自己·对方的准备阶段，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡除外。
local s,id,o=GetID()
-- 初始化函数：注册XYZ召唤手续、特殊召唤回合的破坏抗性、对方发动怪兽效果时升攻、以及准备阶段除外卡片的效果
function s.initial_effect(c)
	-- 设置XYZ召唤手续：5星怪兽×2
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：这张卡在特殊召唤的回合不会被战斗以及对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡在特殊召唤的回合不会被战斗以及对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	-- 设置不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，每次对方把怪兽的效果发动，这张卡的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，每次对方把怪兽的效果发动，这张卡的攻击力上升500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
	-- ③：自己·对方的准备阶段，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡除外。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"除外"
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCost(s.rmcost)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
end
-- 判定这张卡是否处于特殊召唤的回合
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler()
	return ec:IsStatus(STATUS_SPSUMMON_TURN)
end
-- 在对方发动效果时，为自身注册一个在连锁处理结束时重置的Flag，用于判定升攻
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 判定是否为对方发动的怪兽效果，且自身已注册对应的Flag
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and c:GetFlagEffect(id)~=0
end
-- 对方怪兽效果处理完毕后，使这张卡的攻击力上升500
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上展示这张卡发动效果的动画提示
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	-- ②：只要这张卡在怪兽区域存在，每次对方把怪兽的效果发动，这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 准备阶段除外效果的Cost：把这张卡1个超量素材取除
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 准备阶段除外效果的Target：以场上1张卡为对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 判定场上是否存在可以被除外的卡作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1张可以被除外的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息为“除外1张卡”
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 准备阶段除外效果的Operation：将选择的对象卡片除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		-- 将目标卡片表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
