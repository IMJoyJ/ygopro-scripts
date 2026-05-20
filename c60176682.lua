--魔風衝撃波
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有「门之守护神」怪兽存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。自己的卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只加入手卡。
function c60176682.initial_effect(c)
	-- 注册卡片记有「雷魔神-桑迦」、「风魔神-修迦」、「水魔神-斯迦」的卡片密码
	aux.AddCodeList(c,25955164,62340868,98434877)
	-- ①：自己场上有「门之守护神」怪兽存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60176682,0))  --"卡片破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c60176682.condition)
	e1:SetTarget(c60176682.target)
	e1:SetOperation(c60176682.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。自己的卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60176682,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,60176682)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c60176682.thtg)
	e2:SetOperation(c60176682.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「门之守护神」怪兽
function c60176682.filter(c)
	return c:IsSetCard(0x1052) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上存在「门之守护神」怪兽
function c60176682.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「门之守护神」怪兽
	return Duel.IsExistingMatchingCard(c60176682.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的对象选择与发动准备
function c60176682.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 检查场上是否存在除这张卡以外的卡可以作为对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置效果处理信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的效果处理（破坏选中的卡）
function c60176682.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将选中的卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤条件：卡组或除外状态的「雷魔神-桑迦」、「风魔神-修迦」、「水魔神-斯迦」
function c60176682.thfilter(c)
	return c:IsFaceupEx() and c:IsCode(25955164,62340868,98434877) and c:IsAbleToHand()
end
-- 效果②的发动准备
function c60176682.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或除外状态是否存在可以加入手卡的目标怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c60176682.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	-- 设置效果处理信息为从卡组或除外状态将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- 效果②的效果处理（将目标怪兽加入手卡）
function c60176682.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或除外状态选择1张目标怪兽
	local g=Duel.SelectMatchingCard(tp,c60176682.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
