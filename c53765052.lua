--原罪のディアベルゼ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，③的效果1回合只能使用1次。
-- ①：自己或对方的墓地有「罪宝」卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方不能把没有盖放的魔法·陷阱卡发动。
-- ③：这张卡在怪兽区域存在的状态，场上有魔法·陷阱卡被盖放的场合，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：①特殊召唤条件、②对方不能发动非盖放魔法陷阱、③盖放时破坏对象卡
function s.initial_effect(c)
	-- ①：自己或对方的墓地有「罪宝」卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方不能把没有盖放的魔法·陷阱卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	-- ③：这张卡在怪兽区域存在的状态，场上有魔法·陷阱卡被盖放的场合，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SSET)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 判断是否满足特殊召唤条件，需满足场上存在空位且自己或对方墓地有罪宝卡
function s.spcon(e,c)
	if c==nil then return true end
	-- 判断场上是否有足够的怪兽区域空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 判断自己或对方墓地是否存在罪宝卡
		Duel.IsExistingMatchingCard(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,1,nil,0x19e)
end
-- 限制对方不能发动非盖放的魔法陷阱卡
function s.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local c=re:GetHandler()
	return not c:IsLocation(LOCATION_SZONE)
end
-- 设置破坏效果的发动条件，需确保己方和对方场上各有一张卡可作为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断己方场上是否存在可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判断对方场上是否存在可破坏的卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择己方场上的1张卡作为破坏对象
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息，指定将要破坏的卡为2张
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 执行破坏效果，从连锁信息中获取目标卡组并进行破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡组中与效果相关的卡进行破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
