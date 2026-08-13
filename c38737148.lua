--ライトレイ ダイダロス
-- 效果：
-- 这张卡不能通常召唤。自己墓地的光属性怪兽是4只以上的场合才能特殊召唤。1回合1次，选择场上2张卡和1张场地魔法卡才能发动。选择的卡破坏。
function c38737148.initial_effect(c)
	c:EnableReviveLimit()
	-- 自己墓地的光属性怪兽是4只以上的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38737148.spcon)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 1回合1次，选择场上2张卡和1张场地魔法卡才能发动。选择的卡破坏。
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
-- 特殊召唤规则条件：检查自己墓地是否存在4只以上光属性怪兽，且主要怪兽区有空位时才能从手牌特殊召唤。
function c38737148.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否存在空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少4只光属性怪兽。
		and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,4,nil,ATTRIBUTE_LIGHT)
end
-- 选对象的辅助过滤器：用于确保在选取场地魔法卡后，场上还存在至少2张其他卡可选择。
function c38737148.desfilter(c)
	-- 检查场上除c外是否存在至少2张能成为效果对象的卡。
	return Duel.IsExistingTarget(nil,0,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c)
end
-- 发动时选择对象：先选择1张场地魔法卡，再选择场上另外2张卡，合并为对象组，并设置破坏的操作信息。
function c38737148.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：场上是否存在1张场地魔法卡，且以其为对象后还能选择场上另外2张卡。
	if chk==0 then return Duel.IsExistingTarget(c38737148.desfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) end
	-- 弹出'请选择要破坏的卡'的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场地区域的1张场地魔法卡作为对象（同时确保场上还有2张其他卡可选）。
	local g1=Duel.SelectTarget(tp,c38737148.desfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,1,nil)
	-- 弹出'请选择要破坏的卡'的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上除已选场地魔法卡外的2张卡作为对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,g1:GetFirst())
	g1:Merge(g2)
	-- 设置本次连锁将破坏的对象组及数量，供后续效果处理时使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- 效果处理：将取对象阶段选择的卡中仍与该效果相关的卡全部破坏。
function c38737148.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取取对象阶段选择的卡，并筛选出仍与该效果相关的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因将这些卡破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
