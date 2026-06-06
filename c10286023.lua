--魔救の奇石－ドラガイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「魔救」卡的效果特殊召唤成功的场合才能发动。自己从卡组抽1张。
-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只水属性同调怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，这张卡回到卡组最上面。
function c10286023.initial_effect(c)
	-- ①：这张卡用「魔救」卡的效果特殊召唤成功的场合才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10286023,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,10286023)
	e1:SetCondition(c10286023.drcon)
	e1:SetTarget(c10286023.drtg)
	e1:SetOperation(c10286023.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只水属性同调怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，这张卡回到卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10286023,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,10286024)
	e2:SetTarget(c10286023.dttg)
	e2:SetOperation(c10286023.dtop)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否是由「魔救」卡的效果特殊召唤成功
function c10286023.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0x140)
end
-- ①之效果的靶向判定与操作信息注册
function c10286023.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定当前玩家是否能够抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1张
	Duel.SetTargetParam(1)
	-- 注册抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①之效果的效果处理：执行抽卡
function c10286023.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中抽卡效果的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 由效果让目标玩家抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤出自己场上表侧表示或自己墓地中，且可回到额外卡组的水属性同调怪兽
function c10286023.texfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- ②之效果的发动准备：进行取对象和注册操作信息
function c10286023.dttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c10286023.texfilter(chkc) and chkc~=c end
	-- 判定场上或墓地是否存在符合条件的自己水属性同调怪兽，且此卡可以回到卡组
	if chk==0 then return Duel.IsExistingTarget(c10286023.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c) and c:IsAbleToDeck() end
	-- 提示玩家选择作为效果对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上或墓地1只符合条件的水属性同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c10286023.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c)
	-- 注册将选择的对象怪兽送回额外卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 注册将此卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- ②之效果的效果处理：同调怪兽返回额外卡组且此卡回到卡组最上面
function c10286023.dtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的同调怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断对象同调怪兽是否仍适用此效果，将其送回额外卡组，并在其成功回到额外卡组且此卡也仍适用此效果时执行后续处理
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) and c:IsRelateToEffect(e) then
		-- 将此卡送回卡组最上面
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
