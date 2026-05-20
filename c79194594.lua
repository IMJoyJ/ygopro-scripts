--シンセシス・ミュートリアス
-- 效果：
-- 属性不同的「秘异三变」怪兽×2
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡融合召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：对方把效果发动时才能发动。这个回合，表侧表示的这张卡不受那个效果以及相同种类（怪兽·魔法·陷阱）的对方的效果影响。
-- ③：融合召唤的这张卡被对方破坏的场合才能发动。选除外的1张自己的「秘异三变」卡加入手卡。
function c79194594.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：需要2只属性不同的「秘异三变」怪兽作为素材
	aux.AddFusionProcFunRep(c,c79194594.ffilter,2,true)
	-- ①：这张卡融合召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79194594,0))  --"卡片破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,79194594)
	e1:SetCondition(c79194594.descon)
	e1:SetTarget(c79194594.destg)
	e1:SetOperation(c79194594.desop)
	c:RegisterEffect(e1)
	-- ②：对方把效果发动时才能发动。这个回合，表侧表示的这张卡不受那个效果以及相同种类（怪兽·魔法·陷阱）的对方的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79194594,1))  --"效果免疫"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,79194595)
	e2:SetCondition(c79194594.immcon)
	e2:SetOperation(c79194594.immop)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被对方破坏的场合才能发动。选除外的1张自己的「秘异三变」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79194594,2))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,79194596)
	e3:SetCondition(c79194594.thcon)
	e3:SetTarget(c79194594.thtg)
	e3:SetOperation(c79194594.thop)
	c:RegisterEffect(e3)
end
-- 过滤融合素材：属于「秘异三变」系列，且与已选素材的属性不同
function c79194594.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x157) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 效果①的发动条件：这张卡融合召唤成功
function c79194594.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①的靶向/目标选择：以场上1张卡为对象
function c79194594.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为破坏对象的目标卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的效果处理：破坏作为对象的卡
function c79194594.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选中的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②的发动条件：对方发动卡或效果时
function c79194594.immcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 效果②的效果处理：给这张卡添加不受对方相同种类效果影响的免疫效果
function c79194594.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，表侧表示的这张卡不受那个效果以及相同种类（怪兽·魔法·陷阱）的对方的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c79194594.efilter)
		e1:SetLabel(re:GetActiveType())
		c:RegisterEffect(e1)
	end
end
-- 免疫效果的过滤条件：对方发动的、且与触发效果相同种类的效果
function c79194594.efilter(e,te)
	return te:IsActiveType(e:GetLabel()) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- 效果③的发动条件：融合召唤的这张卡被对方破坏
function c79194594.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果③的检索过滤条件：除外的、表侧表示的「秘异三变」卡
function c79194594.thfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x157) and c:IsFaceup()
end
-- 效果③的靶向/目标选择：检查并设置将除外的「秘异三变」卡加入手牌的操作信息
function c79194594.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查除外区是否存在可以加入手牌的「秘异三变」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c79194594.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置效果处理信息：将除外区的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- 效果③的效果处理：选除外的1张自己的「秘异三变」卡加入手牌
function c79194594.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择除外的1张「秘异三变」卡
	local g=Duel.SelectMatchingCard(tp,c79194594.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
