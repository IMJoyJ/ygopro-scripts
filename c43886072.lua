--プランキッズ・バウワウ
-- 效果：
-- 「调皮宝贝」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡所连接区的「调皮宝贝」怪兽的攻击力上升1000。
-- ②：对方回合把这张卡解放，以连接怪兽以外的自己墓地2张「调皮宝贝」卡为对象才能发动（同名卡最多1张）。那些卡加入手卡。此外，这个回合自己场上的「调皮宝贝」怪兽不会被对方的效果破坏。
function c43886072.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，需要2个满足「调皮宝贝」属性的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x120),2,2)
	-- ①：这张卡所连接区的「调皮宝贝」怪兽的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c43886072.atktg)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	-- ②：对方回合把这张卡解放，以连接怪兽以外的自己墓地2张「调皮宝贝」卡为对象才能发动（同名卡最多1张）。那些卡加入手卡。此外，这个回合自己场上的「调皮宝贝」怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43886072,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,43886072)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c43886072.thcon)
	e2:SetCost(c43886072.thcost)
	e2:SetTarget(c43886072.thtg)
	e2:SetOperation(c43886072.thop)
	c:RegisterEffect(e2)
end
-- 判断目标怪兽是否在连接区且为「调皮宝贝」怪兽
function c43886072.atktg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(0x120)
end
-- 判断是否为对方回合
function c43886072.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤满足条件的卡片：正面表示或在墓地、可作为费用除外、拥有效果25725326
function c43886072.excostfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(25725326,tp)
end
-- 检查移除卡片后剩余卡片是否至少包含2种不同卡名
function c43886072.costfilter(c,tp,g)
	local tg=g:Clone()
	tg:RemoveCard(c)
	return tg:GetClassCount(Card.GetCode)>=2
end
-- 处理效果的费用支付，选择满足条件的卡片进行解放或除外
function c43886072.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	-- 获取满足条件的卡片组，包括场上和墓地中的卡片
	local g=Duel.GetMatchingGroup(c43886072.excostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	-- 获取墓地中满足条件的卡片组
	local tg=Duel.GetMatchingGroup(c43886072.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if e:GetHandler():IsReleasable() then g:AddCard(e:GetHandler()) end
	if chk==0 then
		e:SetLabel(100)
		return g:IsExists(c43886072.costfilter,1,nil,tp,tg)
	end
	local cg=g:Filter(c43886072.costfilter,nil,tp,tg)
	local tc
	if #cg>1 then
		-- 提示玩家选择要解放或代替解放除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25725326,0))  --"请选择要解放或代替解放除外的卡"
		tc=cg:Select(tp,1,1,nil):GetFirst()
	else
		tc=cg:GetFirst()
	end
	local te=tc:IsHasEffect(25725326,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将卡片除外作为费用
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 将卡片解放作为费用
		Duel.Release(tc,REASON_COST)
	end
end
-- 过滤满足条件的卡片：为「调皮宝贝」属性、非连接怪兽、可成为效果对象、可加入手牌
function c43886072.thfilter(c,e)
	return c:IsSetCard(0x120) and not c:IsType(TYPE_LINK)
		and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
-- 设置效果的目标卡片，选择2张不同卡名的「调皮宝贝」卡加入手牌
function c43886072.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetLabel()==100 end
	e:SetLabel(0)
	-- 获取墓地中满足条件的卡片组
	local g=Duel.GetMatchingGroup(c43886072.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从满足条件的卡片中选择2张不同卡名的卡片
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 设置当前连锁的目标卡片
	Duel.SetTargetCard(sg)
	-- 设置当前连锁的操作信息，指定将卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
end
-- 处理效果的发动，将目标卡片加入手牌并设置效果使自己场上的「调皮宝贝」怪兽不会被对方效果破坏
function c43886072.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片组，并筛选出与效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 将卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	-- 使自己场上的「调皮宝贝」怪兽不会被对方的效果破坏
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c43886072.indtg)
	-- 设置效果值为判断是否为对方玩家的函数
	e1:SetValue(aux.indoval)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断目标怪兽是否为「调皮宝贝」怪兽
function c43886072.indtg(e,c)
	return c:IsSetCard(0x120)
end
