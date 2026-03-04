--ギガンティック“チャンピオン”サルガス
-- 效果：
-- 8星怪兽×2只以上
-- 「巨大喷流“冠军”尾宿五」1回合1次也能在自己场上的「护宝炮妖」超量怪兽上面重叠来超量召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡持有超量素材的场合才能发动。从卡组把1张「护宝炮妖」卡或者「兽带斗神」卡加入手卡。
-- ②：场上的超量素材被取除的场合，以场上1张卡为对象才能发动。那张卡破坏或回到手卡。
function c11132674.initial_effect(c)
	-- 启用全局标记，用于检测超量素材被去除的事件
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	aux.AddXyzProcedure(c,nil,8,2,c11132674.ovfilter,aux.Stringid(11132674,0),99,c11132674.xyzop)  --"是否在「护宝炮妖」超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡持有超量素材的场合才能发动。从卡组把1张「护宝炮妖」卡或者「兽带斗神」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11132674,1))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,11132674)
	e1:SetCondition(c11132674.srcon)
	e1:SetTarget(c11132674.srtg)
	e1:SetOperation(c11132674.srop)
	c:RegisterEffect(e1)
	-- ②：场上的超量素材被取除的场合，以场上1张卡为对象才能发动。那张卡破坏或回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11132674,2))  --"场上1张卡破坏或回到持有者手卡"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DETACH_MATERIAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11132675)
	e2:SetCondition(c11132674.descon)
	e2:SetTarget(c11132674.destg)
	e2:SetOperation(c11132674.desop)
	c:RegisterEffect(e2)
end
-- 判断怪兽是否为「护宝炮妖」超量怪兽
function c11132674.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ)
end
-- 超量召唤时的处理函数，用于检查是否已使用过效果
function c11132674.xyzop(e,tp,chk)
	-- 检查玩家是否已使用过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,11132674)==0 end
	-- 注册标识效果，防止此效果在回合内重复使用
	Duel.RegisterFlagEffect(tp,11132674,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 效果①的发动条件：此卡持有超量素材
function c11132674.srcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>0
end
-- 检索卡组中「护宝炮妖」或「兽带斗神」卡的过滤函数
function c11132674.srfilter(c)
	return c:IsSetCard(0x155,0x179) and c:IsAbleToHand()
end
-- 效果①的发动时处理函数，设置检索目标
function c11132674.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11132674.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动处理函数，执行检索并加入手牌
function c11132674.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c11132674.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：有超量素材被去除
function c11132674.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end
-- 效果②的发动时处理函数，设置目标
function c11132674.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可作为目标的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏或送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择场上的一张卡作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- 效果②的发动处理函数，执行破坏或送回手牌
function c11132674.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsAbleToHand()
		-- 玩家选择将目标卡送回手牌或破坏
		and Duel.SelectOption(tp,aux.Stringid(11132674,3),aux.Stringid(11132674,4))==1 then  --"破坏"
		-- 将目标卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	else
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
