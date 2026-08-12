--宵闇のルーチェ
-- 效果：
-- 自己墓地的恶魔族·天使族怪兽×3
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己的左端·右端的主要怪兽区域的怪兽不会被效果破坏。
-- ②：以对方场上1张卡为对象才能发动。从卡组把1只恶魔族·天使族怪兽送去墓地，作为对象的卡破坏。
-- ③：自己场上的其他卡被效果破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化函数：设置融合召唤手续并注册三个效果——②效果（取对方场上1张卡为对象的起动效果，从卡组送恶魔族·天使族怪兽去墓地并破坏对象卡）、③效果（自己场上卡被效果破坏时触发的取对象破坏效果）、①效果（使两端主要怪兽区域怪兽不被效果破坏的永续效果）
function s.initial_effect(c)
	-- 为这张卡设置融合召唤手续：以自己墓地的3只恶魔族·天使族怪兽为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()
	-- ②：以对方场上1张卡为对象才能发动。从卡组把1只恶魔族·天使族怪兽送去墓地，作为对象的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"从卡组送去墓地"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ③：自己场上的其他卡被效果破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"场上的卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon2)
	e2:SetTarget(s.destg2)
	e2:SetOperation(s.desop2)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，自己的左端·右端的主要怪兽区域的怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 融合素材过滤函数：这张卡的持有者是自己、种族为天使族或恶魔族且位于墓地的怪兽可作为融合素材
function s.ffilter(c,fc)
	return c:GetOwner()==fc:GetControler() and c:IsRace(RACE_FAIRY+RACE_FIEND)
		and c:IsLocation(LOCATION_GRAVE)
end
-- 送去墓地候选过滤函数：天使族或恶魔族且可以送去墓地的怪兽
function s.tgfilter(c)
	return c:IsRace(RACE_FAIRY+RACE_FIEND) and c:IsAbleToGrave()
end
-- ②效果的对象选择函数：可选对象为对方场上的卡，并检查发动条件是否满足
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动条件检查：对方场上存在至少1张可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
		-- 并检查自己卡组存在至少1只可以送去墓地的恶魔族·天使族怪兽
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家提示「请选择要破坏的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡作为这个效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：确定要破坏的卡为作为对象的卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：预计从自己卡组把1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：取得对象卡，从卡组选1只恶魔族·天使族怪兽送去墓地，成功送去墓地且对象卡仍与这个连锁关联的场合，把对象卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 向玩家提示「请选择要送去墓地的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组选择1只可以送去墓地的恶魔族·天使族怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 把选择的怪兽送去墓地，并确认实际送去了墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0
		and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		and tc:IsRelateToChain() then
		-- 把作为对象的卡以效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 触发条件过滤函数：被破坏前是自己场上的卡且是被效果破坏的卡
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_EFFECT)
end
-- ③效果的发动条件：本次被破坏的卡中存在自己场上被效果破坏的其他的卡（不含这张卡本身）
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
-- ③效果的对象选择函数：可选对象为场上的卡，选择1张作为对象并设置破坏的操作信息
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检查：场上存在至少1张可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示「请选择要破坏的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为这个效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：确定要破坏的卡为作为对象的卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果的处理：取得对象卡，若其仍与这个连锁关联则把它破坏
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 把作为对象的卡以效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ①效果的适用对象过滤函数：自己主要怪兽区域中位于左端（0号位）或右端（4号位）的怪兽不会被效果破坏
function s.indtg(e,c)
	return c:GetSequence()==0 or c:GetSequence()==4
end
