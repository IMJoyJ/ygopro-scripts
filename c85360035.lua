--双天拳の熊羆
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「双天」怪兽为对象才能发动。那只怪兽破坏，从卡组把1张「双天」魔法卡加入手卡。
-- ②：这张卡在墓地存在的状态，效果怪兽为素材作融合召唤的自己场上的表侧表示的「双天」融合怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡加入手卡。
function c85360035.initial_effect(c)
	-- ①：以自己场上1只「双天」怪兽为对象才能发动。那只怪兽破坏，从卡组把1张「双天」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85360035,0))  --"「双天」魔法卡加入手卡"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,85360035)
	e1:SetTarget(c85360035.target)
	e1:SetOperation(c85360035.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，效果怪兽为素材作融合召唤的自己场上的表侧表示的「双天」融合怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85360035,1))  --"这张卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+85360035)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,85360036)
	e2:SetTarget(c85360035.thtg)
	e2:SetOperation(c85360035.thop)
	c:RegisterEffect(e2)
	if not c85360035.global_check then
		c85360035.global_check=true
		-- 这个卡名的①②的效果1回合各能使用1次。①：以自己场上1只「双天」怪兽为对象才能发动。那只怪兽破坏，从卡组把1张「双天」魔法卡加入手卡。②：这张卡在墓地存在的状态，效果怪兽为素材作融合召唤的自己场上的表侧表示的「双天」融合怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡加入手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_LEAVE_FIELD_P)
		ge1:SetCondition(c85360035.regcon)
		ge1:SetOperation(c85360035.regop)
		-- 注册全局效果，用于在场上卡片移动前检测破坏事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤条件：自己场上表侧表示的、以效果怪兽为素材融合召唤的「双天」融合怪兽，因战斗或对方的效果被破坏
function c85360035.cfilter(c,tp)
	return c:GetFlagEffect(85360035)~=0 and c:IsReason(REASON_DESTROY)
		and c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x14f) and c:IsType(TYPE_FUSION)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 检查是否有满足条件的「双天」融合怪兽被破坏，并记录被破坏怪兽的控制者
function c85360035.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c85360035.cfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c85360035.cfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 触发自定义事件，通知墓地中的此卡可以发动回收效果
function c85360035.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，传递被破坏的卡片组以及受影响的玩家信息
	Duel.RaiseEvent(eg,EVENT_CUSTOM+85360035,re,r,rp,ep,e:GetLabel())
end
-- 过滤条件：自己场上表侧表示的「双天」怪兽
function c85360035.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14f)
end
-- 过滤条件：卡组中可以加入手牌的「双天」魔法卡
function c85360035.thfilter(c)
	return c:IsSetCard(0x14f) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果①的发动准备：选择自己场上1只「双天」怪兽作为对象，并确认卡组中存在可检索的「双天」魔法卡
function c85360035.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c85360035.desfilter(chkc) end
	-- 检查自己场上是否存在可以作为破坏对象的表侧表示「双天」怪兽
	if chk==0 then return Duel.IsExistingTarget(c85360035.desfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否存在可以加入手牌的「双天」魔法卡
		and Duel.IsExistingMatchingCard(c85360035.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择自己场上1只表侧表示的「双天」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85360035.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：破坏作为对象的怪兽，若破坏成功，则从卡组将1张「双天」魔法卡加入手牌
function c85360035.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍适用此效果，并将其因效果破坏
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足条件的「双天」魔法卡
		local g=Duel.SelectMatchingCard(tp,c85360035.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的「双天」魔法卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 效果②的发动准备：确认墓地中的此卡可以加入手牌，并设置操作信息
function c85360035.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置操作信息：将墓地的此卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果②的处理：将墓地中的此卡加入手牌
function c85360035.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
