--M∀LICE IN UNDERGROUND
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从自己的手卡·卡组·墓地把1张「码丽丝」卡除外。
-- ②：只要自己的除外状态的「码丽丝」陷阱卡3种类以上存在，自己场上的「码丽丝」连接怪兽的攻击力上升3000。
-- ③：只要自己场上有「码丽丝」连接怪兽存在，对方怪兽只能选择「码丽丝」连接怪兽作为攻击对象。
local s,id,o=GetID()
-- 注册卡片效果：包含发动时的除外效果、场地区域的攻击力上升效果、以及限制对方攻击对象的效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从自己的手卡·卡组·墓地把1张「码丽丝」卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：只要自己的除外状态的「码丽丝」陷阱卡3种类以上存在，自己场上的「码丽丝」连接怪兽的攻击力上升3000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.atkcon)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(3000)
	c:RegisterEffect(e2)
	-- ③：只要自己场上有「码丽丝」连接怪兽存在，对方怪兽只能选择「码丽丝」连接怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.condition)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetValue(s.alimit)
	c:RegisterEffect(e4)
end
-- 过滤条件：属于「码丽丝」系列且可以被除外的卡
function s.filter(c)
	return c:IsSetCard(0x1bf) and c:IsAbleToRemove()
end
-- 卡片发动时的效果处理：可以从手卡、卡组、墓地选择1张「码丽丝」卡除外
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡、卡组、墓地中满足过滤条件且不受王家之谷影响的「码丽丝」卡片组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
	-- 若存在可除外的卡，则询问玩家是否选择除外
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把「码丽丝」卡除外？"
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片以表侧表示因效果除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤条件：除外状态的表侧表示「码丽丝」陷阱卡
function s.cfilter(c)
	return c:IsSetCard(0x1bf) and c:IsType(TYPE_TRAP) and c:IsFaceup()
end
-- 攻击力上升效果的判定条件：除外状态的「码丽丝」陷阱卡在3种类以上
function s.atkcon(e)
	-- 获取自己除外区满足过滤条件的「码丽丝」陷阱卡组
	local g=Duel.GetMatchingGroup(s.cfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)
	return g:GetClassCount(Card.GetCode)>=3
end
-- 攻击力上升效果的适用对象：自己场上的「码丽丝」连接怪兽
function s.atktg(e,c)
	return c:IsSetCard(0x1bf) and c:IsType(TYPE_LINK)
end
-- 过滤条件：场上表侧表示的「码丽丝」连接怪兽
function s.cfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x1bf)
end
-- 攻击限制效果的判定条件：自己场上存在「码丽丝」连接怪兽
function s.condition(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在至少1张表侧表示的「码丽丝」连接怪兽
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 攻击目标限制：不能选择里侧表示怪兽或非「码丽丝」连接怪兽作为攻击对象
function s.alimit(e,c)
	return c:IsFacedown() or not (c:IsType(TYPE_LINK) and c:IsSetCard(0x1bf))
end
