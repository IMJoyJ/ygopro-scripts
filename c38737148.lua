--ライトレイ ダイダロス
-- 效果：
-- 这张卡不能通常召唤。自己墓地的光属性怪兽是4只以上的场合才能特殊召唤。1回合1次，选择场上2张卡和1张场地魔法卡才能发动。选择的卡破坏。
function c38737148.initial_effect(c)
	c:EnableReviveLimit()
	-- 特殊召唤条件效果，用于限制该卡只能通过特定条件特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38737148.spcon)
	c:RegisterEffect(e1)
	-- 特殊召唤条件效果，用于限制该卡只能通过特定条件特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 起动效果，1回合1次，选择场上2张卡和1张场地魔法卡才能发动。选择的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38737148,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c38737148.destg)
	e3:SetOperation(c38737148.desop)
	c:RegisterEffect(e3)
end
-- 检查当前控制者是否满足特殊召唤条件，包括场上是否有空位且自己墓地有4只以上光属性怪兽
function c38737148.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前控制者场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少4只光属性怪兽
		and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,4,nil,ATTRIBUTE_LIGHT)
end
-- 用于筛选可以被选择为目标的卡，确保场上存在至少2张卡可以成为目标
function c38737148.desfilter(c)
	-- 检查场上是否存在至少2张卡可以成为目标
	return Duel.IsExistingTarget(nil,0,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c)
end
-- 设置效果的目标选择逻辑，选择1张场地魔法卡和2张场上卡作为破坏对象
function c38737148.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足选择目标的条件，即场上存在至少1张场地魔法卡可以被选择
	if chk==0 then return Duel.IsExistingTarget(c38737148.desfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1张场地魔法卡作为目标
	local g1=Duel.SelectTarget(tp,c38737148.desfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择2张场上卡作为目标
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,g1:GetFirst())
	g1:Merge(g2)
	-- 设置效果处理时要破坏的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- 效果处理函数，将选定的卡进行破坏
function c38737148.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡组进行破坏处理，破坏原因为效果
	Duel.Destroy(g,REASON_EFFECT)
end
