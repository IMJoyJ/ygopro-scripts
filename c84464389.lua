--ヴァレルロード・FF・ドラゴン
-- 效果：
-- 暗属性连接怪兽＋暗属性怪兽
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从卡组把1只「弹丸」怪兽加入手卡。
-- ②：以自己场上1只暗属性怪兽为对象才能发动。自己的墓地·除外状态的1只暗属性连接怪兽当作攻击力上升500的装备魔法卡使用给作为对象的怪兽装备。
-- ③：这张卡作为连接素材送去墓地的场合，以场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，设置融合召唤手续以及①②③效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为：暗属性连接怪兽和暗属性怪兽各1只。
	aux.AddFusionProcFun2(c,s.mfilter,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),true)
	-- ①：这张卡融合召唤的场合才能发动。从卡组把1只「弹丸」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只暗属性怪兽为对象才能发动。自己的墓地·除外状态的1只暗属性连接怪兽当作攻击力上升500的装备魔法卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备效果"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为连接素材送去墓地的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤条件：暗属性的连接怪兽。
function s.mfilter(c)
	return c:IsFusionType(TYPE_LINK) and c:IsFusionAttribute(ATTRIBUTE_DARK)
end
-- ①效果的发动条件：这张卡融合召唤成功。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检索卡片过滤条件：卡组中可加入手牌的「弹丸」怪兽。
function s.thfilter(c)
	return c:IsSetCard(0x102) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动准备（检查卡组是否存在可检索的「弹丸」怪兽，并设置检索的操作信息）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足条件的「弹丸」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理（从卡组选择1只「弹丸」怪兽加入手牌并给对方确认）。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「弹丸」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的对象过滤条件：自己场上表侧表示的暗属性怪兽，且墓地或除外状态存在可装备的暗属性连接怪兽。
function s.eqfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
		-- 检查自己的墓地或除外状态是否存在至少1张满足装备条件的暗属性连接怪兽。
		and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp)
end
-- 装备卡过滤条件：墓地或除外状态的暗属性连接怪兽，且未被禁止使用、可以作为装备卡放置在魔法与陷阱区域。
function s.eqfilter2(c,tp)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_LINK) and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- ②效果的发动准备（检查魔法与陷阱区域是否有空位、场上是否有合法的暗属性怪兽作为对象，并选择对象）。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc,tp) end
	-- 检查自己场上的魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在至少1只满足条件的暗属性怪兽可以作为效果对象。
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的暗属性怪兽作为效果对象。
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置连锁处理的操作信息：有1张卡将离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- ②效果的实际处理（将墓地或除外状态的1只暗属性连接怪兽作为装备卡装备给对象怪兽，并使其攻击力上升500）。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 若魔法与陷阱区域没有空位，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and tc:IsFaceup() then
		-- 提示玩家选择要装备的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从自己墓地或除外状态选择1张满足条件的暗属性连接怪兽（受王家之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter2),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
		local ec=g:GetFirst()
		-- 若未选出卡或装备失败，则结束处理。
		if not ec or not Duel.Equip(tp,ec,tc) then return end
		-- 当作……装备魔法卡使用给作为对象的怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		ec:RegisterEffect(e1)
		-- 攻击力上升500
		local e2=Effect.CreateEffect(ec)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2)
	end
end
-- 装备限制：只能装备给作为对象的怪兽。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ③效果的发动条件：这张卡作为连接素材送去墓地。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- ③效果的发动准备（选择场上1张卡作为对象，并设置破坏的操作信息）。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少1张卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理的操作信息：破坏选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果的实际处理（破坏作为对象的卡）。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为破坏对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 将作为对象的卡因效果破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
