--プランキッズ・ロアゴン
-- 效果：
-- 「调皮宝贝」怪兽2只以上
-- 这张卡不用连接召唤不能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：把这张卡解放才能发动。对方场上的魔法·陷阱卡全部破坏。这个效果在对方回合也能发动。
-- ②：这张卡被对方送去墓地的场合，以连接怪兽以外的自己墓地1张卡为对象才能发动。那张卡加入手卡。
function c70875686.initial_effect(c)
	-- 设置连接召唤手续：需要2只以上的「调皮宝贝」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x120),2)
	c:EnableReviveLimit()
	-- 这张卡不用连接召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该怪兽只能通过连接召唤的方式特殊召唤
	e0:SetValue(aux.linklimit)
	c:RegisterEffect(e0)
	-- ①：把这张卡解放才能发动。对方场上的魔法·陷阱卡全部破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70875686,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c70875686.descost)
	e1:SetTarget(c70875686.destg)
	e1:SetOperation(c70875686.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方送去墓地的场合，以连接怪兽以外的自己墓地1张卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70875686,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,70875686)
	e2:SetCondition(c70875686.thcon)
	e2:SetTarget(c70875686.thtg)
	e2:SetOperation(c70875686.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上或墓地可以作为代替解放而除外的「调皮宝贝」卡片
function c70875686.excostfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(25725326,tp)
end
-- 效果①的发动代价（Cost）处理函数，处理解放自身或使用其他卡片代替解放
function c70875686.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上及墓地中可以代替解放而除外的卡片组
	local g=Duel.GetMatchingGroup(c70875686.excostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	if e:GetHandler():IsReleasable() then g:AddCard(e:GetHandler()) end
	if chk==0 then return #g>0 end
	local tc
	if #g>1 then
		-- 提示玩家选择要解放或代替解放除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25725326,0))  --"请选择要解放或代替解放除外的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	local te=tc:IsHasEffect(25725326,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将代替解放的卡片除外
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 解放作为发动代价的怪兽
		Duel.Release(tc,REASON_COST)
	end
end
-- 过滤魔法·陷阱卡
function c70875686.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的发动检测与效果处理范围确定（Target）函数
function c70875686.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c70875686.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有的魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(c70875686.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏操作的信息，包含要破坏的卡片组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果①的效果处理（Operation）函数
function c70875686.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(c70875686.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏获取到的所有魔法·陷阱卡
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 效果②的发动条件（Condition）函数，检测是否被对方送去墓地且原本控制者为自己
function c70875686.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤连接怪兽以外且能加入手牌的卡片
function c70875686.thfilter(c)
	return not c:IsType(TYPE_LINK) and c:IsAbleToHand()
end
-- 效果②的发动检测与取对象（Target）函数
function c70875686.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c70875686.thfilter(chkc) end
	-- 检查自己墓地是否存在连接怪兽以外的卡片
	if chk==0 then return Duel.IsExistingTarget(c70875686.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张连接怪兽以外的卡作为效果对象
	local g=Duel.SelectTarget(tp,c70875686.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置回收卡片至手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理（Operation）函数
function c70875686.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
