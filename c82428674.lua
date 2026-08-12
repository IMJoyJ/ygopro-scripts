--サイバネティック・オーバーフロー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地以及自己场上的表侧表示怪兽之中选「电子龙」任意数量除外（相同等级最多1只）。那之后，选除外数量的对方场上的卡破坏。
-- ②：场上的这张卡被效果破坏的场合才能发动。从卡组把1张「电子」魔法·陷阱卡或者「电子科技」魔法·陷阱卡加入手卡。
function c82428674.initial_effect(c)
	-- ①：从自己的手卡·墓地以及自己场上的表侧表示怪兽之中选「电子龙」任意数量除外（相同等级最多1只）。那之后，选除外数量的对方场上的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,82428674)
	e1:SetTarget(c82428674.target)
	e1:SetOperation(c82428674.activate)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被效果破坏的场合才能发动。从卡组把1张「电子」魔法·陷阱卡或者「电子科技」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,82428675)
	e2:SetCondition(c82428674.thcon)
	e2:SetTarget(c82428674.thtg)
	e2:SetOperation(c82428674.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选手卡、墓地或场上表侧表示的、等级在1以上且可以除外的「电子龙」
function c82428674.rmfilter(c)
	return (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and c:IsCode(70095154) and c:IsLevelAbove(1) and c:IsAbleToRemove()
end
-- ①号效果的发动准备与合法性检测函数
function c82428674.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡、墓地、场上是否存在至少1张满足条件的「电子龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c82428674.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,nil)
		-- 并且检查对方场上是否存在至少1张卡
		and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置操作信息：预计将自己手卡、墓地、场上的至少1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE)
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：预计破坏对方场上的至少1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①号效果的处理函数
function c82428674.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的卡片作为可选的破坏对象
	local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	local ct=dg:GetCount()
	-- 获取自己手卡、墓地、场上所有满足条件的「电子龙」作为可选的除外对象
	local g=Duel.GetMatchingGroup(c82428674.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,nil)
	if ct==0 or g:GetCount()==0 then return end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 设置子卡片组检查函数，约束所选卡片的等级必须互不相同
	aux.GCheckAdditional=aux.dlvcheck
	-- 让玩家选择1到对方场上卡片数量张等级互不相同的「电子龙」
	local rg=g:SelectSubGroup(tp,aux.TRUE,false,1,ct)
	-- 重置子卡片组检查函数，避免影响后续的选择逻辑
	aux.GCheckAdditional=nil
	-- 将选中的「电子龙」表侧表示除外，并记录实际除外的卡片数量
	local rc=Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	if rc>0 then
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=dg:Select(tp,rc,rc,nil)
		-- 闪烁显示选中的要破坏的卡片
		Duel.HintSelection(sg)
		-- 因效果破坏选中的对方场上的卡片
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- ②号效果的发动条件：场上的这张卡被效果破坏
function c82428674.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and bit.band(r,REASON_EFFECT)~=0
end
-- 过滤函数：筛选卡组中可以加入手牌的「电子」或「电子科技」魔法·陷阱卡
function c82428674.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x94,0x93) and c:IsAbleToHand()
end
-- ②号效果的发动准备与合法性检测函数
function c82428674.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「电子」或「电子科技」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c82428674.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的处理函数
function c82428674.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「电子」或「电子科技」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c82428674.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
