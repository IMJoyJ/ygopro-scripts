--世壊挽歌
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从卡组把1只「吠陀」怪兽加入手卡。
-- ②：这张卡在墓地存在，场上有「维萨斯-斯塔弗罗斯特」存在的状态，自己场上的表侧表示的调整被战斗·效果破坏的场合，把这张卡除外，以那之内的1只为对象才能发动。那只怪兽加入手卡。
function c17462320.initial_effect(c)
	-- 记录此卡具有「维萨斯-斯塔弗罗斯特」的卡名信息
	aux.AddCodeList(c,56099748)
	-- ①：从卡组把1只「吠陀」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17462320,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c17462320.target)
	e1:SetOperation(c17462320.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，场上有「维萨斯-斯塔弗罗斯特」存在的状态，自己场上的表侧表示的调整被战斗·效果破坏的场合，把这张卡除外，以那之内的1只为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17462320,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,17462320)
	e2:SetCondition(c17462320.thcon)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c17462320.thtg)
	e2:SetOperation(c17462320.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检索满足条件的「吠陀」怪兽
function c17462320.thfilter(c)
	return c:IsSetCard(0x19a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时检查是否满足条件：卡组存在满足条件的「吠陀」怪兽
function c17462320.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：卡组存在满足条件的「吠陀」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c17462320.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：检索1张「吠陀」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择1张「吠陀」怪兽加入手牌并确认
function c17462320.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「吠陀」怪兽
	local g=Duel.SelectMatchingCard(tp,c17462320.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：检索场上的「维萨斯-斯塔弗罗斯特」
function c17462320.filter(c)
	return c:IsCode(56099748) and c:IsFaceup()
end
-- 过滤函数：判断被破坏的怪兽是否为表侧表示的调整
function c17462320.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_TUNER)~=0 and not c:IsType(TYPE_TOKEN)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果发动条件：场上有「维萨斯-斯塔弗罗斯特」存在，且有调整被战斗或效果破坏
function c17462320.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上有「维萨斯-斯塔弗罗斯特」存在
	return Duel.IsExistingMatchingCard(c17462320.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and eg:IsExists(c17462320.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤函数：判断怪兽是否可以成为效果对象且能加入手牌
function c17462320.tgfilter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
-- 效果处理时设置目标：选择满足条件的被破坏的调整
function c17462320.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(c17462320.cfilter,nil,tp):Filter(c17462320.tgfilter,nil,e)
	if chkc then return mg:IsContains(chkc) end
	if chk==0 then return mg:GetCount()>0 end
	local g=mg
	if mg:GetCount()>1 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=mg:Select(tp,1,1,nil)
	end
	-- 设置当前连锁处理的目标卡
	Duel.SetTargetCard(g)
	-- 设置连锁操作信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将目标怪兽加入手牌
function c17462320.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
