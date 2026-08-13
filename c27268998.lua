--メタル・デビルゾアX
-- 效果：
-- 这张卡不能通常召唤，用把5星以上的恶魔族怪兽解放发动的「金属化·强化反射装甲」的效果可以特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1张「金属化」陷阱卡在自己场上盖放，这张卡回到卡组。
-- ②：1回合最多2次，对方把魔法·怪兽的效果发动时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 注册本卡的初始效果：先登记卡名相关代码并附加苏生限制，然后创建①效果（手卡展示自己为cost，盖放卡组「金属化」陷阱并洗回手卡的起动效果）和②效果（对方发动魔法·怪兽效果时取对象破坏的诱发即时效果）并注册到卡片。
function s.initial_effect(c)
	-- 登记本卡记载的「金属化·强化反射装甲」的卡号89812483，用于相关联动判定。
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
-- 定义用于「金属化·强化反射装甲」特殊召唤手续的素材过滤函数：需要解放1只5星以上的恶魔族怪兽。
function s.mfilter(ft,lv,race,att)
	return ft==1 and lv>=5 and bit.band(race,RACE_FIEND)==RACE_FIEND
end
s.Metallization_material=s.mfilter
-- ①效果的发动cost：检查这张手卡当前不是公开状态，发动时通过展示手卡来满足cost条件。
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 筛选卡组中可盖放的「金属化」陷阱卡：卡名带有金属化字段、是陷阱卡且可以放置到魔陷区。
function s.setfilter(c)
	return c:IsSetCard(0x1ba) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的发动条件和目标判定：确认自己魔陷区有空位、卡组存在符合条件的「金属化」陷阱卡、且这张手卡能返回卡组，满足后才能发动且不取对象。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件的一部分：确认自己场上魔法陷阱区存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件的一部分：确认卡组中至少存在1张符合筛选条件的「金属化」陷阱卡可供盖放。
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		and c:IsAbleToDeck() end
end
-- ①效果处理：从卡组选择1张「金属化」陷阱卡盖放到自己场上；若盖放成功且本卡仍与效果关联，则将本卡洗回卡组。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认魔陷区仍有空位，若没有空位则本次效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为“请选择要盖放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从卡组中选出1张满足筛选条件的「金属化」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断是否成功选到卡、盖放是否成功，且原手卡仍与当前效果关联，若都满足则执行回卡组操作。
	if tc and Duel.SSet(tp,tc)~=0 and c:IsRelateToEffect(e) then
		-- 将这张手卡以效果原因送回持有者卡组并洗牌，实现“这张卡回到卡组”。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的发动条件：对方玩家发动魔法或怪兽效果时（ep为对方且效果类型包含魔法或怪兽）才允许发动。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_MONSTER)
end
-- ②效果的取对象目标处理：选择对方场上1只表侧表示怪兽作为对象，并设置破坏的操作信息；同时确认至少存在可选对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动条件之一：对方场上有1只表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只表侧表示怪兽，并将其登记为本连锁的效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息，标明将破坏1张卡，用于星尘龙等卡的发动检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得选择的对象怪兽，若对象仍与效果关联且是怪兽，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
