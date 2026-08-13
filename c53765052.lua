--原罪のディアベルゼ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，③的效果1回合只能使用1次。
-- ①：自己或对方的墓地有「罪宝」卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方不能把没有盖放的魔法·陷阱卡发动。
-- ③：这张卡在怪兽区域存在的状态，场上有魔法·陷阱卡被盖放的场合，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册①满足墓地有「罪宝」时从手卡特殊召唤的规则效果（1回合1次）、②对方不能发动未盖放魔陷的永续效果、③魔陷被盖放时以双方场上各1张为对象破坏的诱发效果（1回合1次）。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己或对方的墓地有「罪宝」卡存在的场合，这张卡可以从手卡特殊召唤。
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
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡在怪兽区域存在的状态，场上有魔法·陷阱卡被盖放的场合，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
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
-- 特殊召唤规则效果的条件：该卡控制者的主要怪兽区域有空位，且自己或对方墓地存在「罪宝」卡。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查该卡的控制者的主要怪兽区域是否有空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己或对方墓地是否存在至少1张「罪宝」卡（卡名含有0x19e字段）。
		Duel.IsExistingMatchingCard(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,1,nil,0x19e)
end
-- EFFECT_CANNOT_ACTIVATE的判定函数：对方发动的效果为魔法·陷阱卡的发动，且该卡不在魔法与陷阱区域（即未经盖放）时，禁止发动。
function s.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local c=re:GetHandler()
	return not c:IsLocation(LOCATION_SZONE)
end
-- ③效果的发动条件与对象选取准备：连锁处理中不接受其他对象；发动条件检查时确认自己场上和对方场上各存在1张可选对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：自己场上有1张以上可作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		-- 发动条件检查：对方场上有1张以上可作为对象的卡；两项均满足才可发动。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，要求该玩家选择要破坏的卡（用于选择自己场上的对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的1张卡作为效果对象（要破坏的卡之一）。
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 显示选择提示，要求该玩家选择要破坏的卡（用于选择对方场上的对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为效果对象（要破坏的卡之一）。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置本次连锁的操作信息：将此前选好的对象组g1（含自己1张和对方1张）作为破坏对象，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- ③效果处理：取得连锁记录的对象，筛选出仍与该效果有关联的卡，若有则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得效果发动时选择的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将筛选后的对象卡以效果原因破坏。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
