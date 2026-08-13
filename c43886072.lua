--プランキッズ・バウワウ
-- 效果：
-- 「调皮宝贝」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡所连接区的「调皮宝贝」怪兽的攻击力上升1000。
-- ②：对方回合把这张卡解放，以连接怪兽以外的自己墓地2张「调皮宝贝」卡为对象才能发动（同名卡最多1张）。那些卡加入手卡。此外，这个回合自己场上的「调皮宝贝」怪兽不会被对方的效果破坏。
function c43886072.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡登记连接召唤手续：连接召唤时只能用2只「调皮宝贝」字段的怪兽作为连接素材（minc=2，maxc=2）。
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
	-- 这个卡名的②的效果1回合只能使用1次。②：对方回合把这张卡解放，以连接怪兽以外的自己墓地2张「调皮宝贝」卡为对象才能发动（同名卡最多1张）。那些卡加入手卡。此外，这个回合自己场上的「调皮宝贝」怪兽不会被对方的效果破坏。
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
-- ①效果的攻击力上升对象判定：该怪兽必须位于这张卡所连接的区域，且是「调皮宝贝」怪兽。
function c43886072.atktg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(0x120)
end
-- ②效果的发动条件判定：当前回合必须是对方回合（即这张卡的控制者不是回合玩家）。
function c43886072.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回“对方是当前回合玩家”的判定结果，满足时②效果才能在对方回合发动。
	return Duel.GetTurnPlayer()==1-tp
end
-- 收集可作为代替解放的代价卡：该卡需表侧表示于场上或位于墓地、能被除外作为代价，且拥有25725326号卡赋予的代替解放效果。
function c43886072.excostfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(25725326,tp)
end
-- 代价选择辅助判定：将某张候选代价卡从墓地对象候选组剔除后，剩余对象候选的卡名种类数仍不少于2，才能保证选出2张不同卡名作为对象。
function c43886072.costfilter(c,tp,g)
	local tg=g:Clone()
	tg:RemoveCard(c)
	return tg:GetClassCount(Card.GetCode)>=2
end
-- ②效果的代价处理：收集本卡和可代替解放/除外的候选卡，判断是否存在合法代价；让玩家选择1张作为代价，若该卡持有25725326的代替解放效果则除外（计入代替解放），否则将其解放（通常为这张卡自身）。同时在chk=0阶段用e:SetLabel(100)标记代价可以支付，供target步骤确认。
function c43886072.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	-- 取得自己场上表侧表示或墓地里所有可作为代替解放代价的候选卡集合（可除外作为代价且带有25725326代替效果）。
	local g=Duel.GetMatchingGroup(c43886072.excostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	-- 取得自己墓地中满足②效果对象条件的「调皮宝贝」卡集合：连接怪兽以外且可以成为效果对象、可以加入手卡。
	local tg=Duel.GetMatchingGroup(c43886072.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if e:GetHandler():IsReleasable() then g:AddCard(e:GetHandler()) end
	if chk==0 then
		e:SetLabel(100)
		return g:IsExists(c43886072.costfilter,1,nil,tp,tg)
	end
	local cg=g:Filter(c43886072.costfilter,nil,tp,tg)
	local tc
	if #cg>1 then
		-- 弹出选择提示，让玩家选择要将哪张卡作为代价解放或代替解放除外（使用25725326号卡设定的提示文本）。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25725326,0))  --"请选择要解放或代替解放除外的卡"
		tc=cg:Select(tp,1,1,nil):GetFirst()
	else
		tc=cg:GetFirst()
	end
	local te=tc:IsHasEffect(25725326,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将选中的代替代价卡表侧表示除外，原因标记为代价并视为代替解放，完成代价支付。
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 将选中的卡（通常是这张卡自身）解放，作为发动②效果的代价。
		Duel.Release(tc,REASON_COST)
	end
end
-- ②效果的对象过滤：该卡必须是「调皮宝贝」卡、不是连接怪兽、能被当前效果取为对象，并且能被加入手卡。
function c43886072.thfilter(c,e)
	return c:IsSetCard(0x120) and not c:IsType(TYPE_LINK)
		and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
-- ②效果的取对象处理：确认代价值已成立（e:GetLabel()==100），从墓地符合条件的「调皮宝贝」卡中让玩家选择2张卡名互不相同的卡，将它们设为连锁对象并登记加入手卡的操作信息。
function c43886072.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetLabel()==100 end
	e:SetLabel(0)
	-- 取得自己墓地中所有可作为②效果对象的「调皮宝贝」卡（非连接怪兽且满足可对象/可入手条件）。
	local g=Duel.GetMatchingGroup(c43886072.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 显示选择提示，提示玩家正在选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从候选卡中让玩家选择2张卡名互不相同的「调皮宝贝」卡作为对象（aux.dncheck用于校验卡名不同）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选中的2张卡登记为当前连锁的效果对象（取对象）。
	Duel.SetTargetCard(sg)
	-- 登记操作信息：连锁处理时将这些卡（数量为#sg）加入持有者手卡，分类为回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
end
-- ②效果处理：将仍与该效果关联的对象卡加入手卡；然后给自己场上设置一个回合结束前生效的领域效果，使自己场上的「调皮宝贝」怪兽不会被对方的效果破坏。
function c43886072.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出本次连锁的对象卡组，并滤除已与效果失去联系的卡（只处理仍然关联的对象）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 把过滤后的对象卡以效果原因送回其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	-- 此外，这个回合自己场上的「调皮宝贝」怪兽不会被对方的效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c43886072.indtg)
	-- 设置该保护效果的判定值：只有来自对方玩家的效果造成破坏时才适用（即对对方效果破坏免疫）。
	e1:SetValue(aux.indoval)
	-- 将上述保护效果注册给当前玩家，持续到结束阶段（由复位标记控制）。
	Duel.RegisterEffect(e1,tp)
end
-- 保护效果的适用对象判定：只有自己场上的「调皮宝贝」怪兽受到该效果破坏保护。
function c43886072.indtg(e,c)
	return c:IsSetCard(0x120)
end
