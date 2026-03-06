--メタル・デビルゾアX
-- 效果：
-- 这张卡不能通常召唤，用把5星以上的恶魔族怪兽解放发动的「金属化·强化反射装甲」的效果可以特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放，这张卡回到卡组。
-- ②：1回合最多2次，对方把魔法·怪兽的效果发动时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 注册卡片效果，设置卡片的初始效果和两个效果（①盖放金属化陷阱卡，②破坏对方怪兽）
function s.initial_effect(c)
	-- 记录该卡与「金属化·强化反射装甲」（卡号89812483）的关联，用于效果判定
	aux.AddCodeList(c,89812483)
	c:EnableReviveLimit()
	-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放「金属化」陷阱卡"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：1回合最多2次，对方把魔法·怪兽的效果发动时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(2)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 定义用于判断解放怪兽是否满足条件的过滤函数（等级≥5且为恶魔族）
function s.mfilter(ft,lv,race,att)
	return ft==1 and lv>=5 and bit.band(race,RACE_FIEND)==RACE_FIEND
end
s.Metallization_material=s.mfilter
-- 设置效果①的发动费用：确认手牌的这张卡对对方公开
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 定义用于筛选「金属化」陷阱卡的过滤函数（属于金属化系列、是陷阱卡、可以盖放）
function s.setfilter(c)
	return c:IsSetCard(0x1ba) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 设置效果①的发动条件：场上存在空魔陷区、卡组存在「金属化」陷阱卡、此卡可送入卡组
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在空魔陷区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组是否存在满足条件的「金属化」陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		and c:IsAbleToDeck() end
end
-- 执行效果①的操作：选择并盖放一张「金属化」陷阱卡，然后将此卡送入卡组
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查场上是否还有空魔陷区，若无则不执行后续操作
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的「金属化」陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择一张满足条件的「金属化」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功盖放陷阱卡且此卡仍有效，则将其送入卡组
	if tc and Duel.SSet(tp,tc)~=0 and c:IsRelateToEffect(e) then
		-- 将此卡送入卡组并洗牌
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 设置效果②的发动条件：对方发动魔法或怪兽效果时触发
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_MONSTER)
end
-- 设置效果②的发动目标：选择对方场上一只表侧表示怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少一只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上一只表侧表示怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表明将要破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果②的操作：破坏指定的对方怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
