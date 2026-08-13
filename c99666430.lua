--人造人間－サイコ・レイヤー
-- 效果：
-- 6星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽不能把效果发动，不能攻击宣言。
-- ②：场上有陷阱卡存在的场合才能发动。自己场上1只怪兽解放，选场上1张表侧表示的卡破坏。
function c99666430.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续，需要2只6星怪兽作为超量素材叠放（无素材限制）。
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽不能把效果发动，不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99666430,0))  --"得到控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,99666430)
	e1:SetCost(c99666430.ctrcost)
	e1:SetTarget(c99666430.ctrtg)
	e1:SetOperation(c99666430.ctrop)
	c:RegisterEffect(e1)
	-- ②：场上有陷阱卡存在的场合才能发动。自己场上1只怪兽解放，选场上1张表侧表示的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99666430,1))  --"选卡破坏"
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,99666431)
	e2:SetCondition(c99666430.descon)
	e2:SetTarget(c99666430.destg)
	e2:SetOperation(c99666430.desop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：检查并从这张卡上取除1个超量素材（REASON_COST）。
function c99666430.ctrcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的对象过滤：选择的对象必须是表侧表示且控制权可以被变更的怪兽。
function c99666430.ctrfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- ①效果的发动目标处理：从对方场上选择1只表侧表示且控制权可变更的怪兽作为对象，并设置改变控制权的操作信息。
function c99666430.ctrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c99666430.ctrfilter(chkc) end
	-- 发动时检查对方场上是否存在至少1只满足条件的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c99666430.ctrfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 发送提示消息，要求玩家选择要改变控制权的怪兽（HINTMSG_CONTROL提示文本）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上表侧表示怪兽中选择1只，并将它设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c99666430.ctrfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：本次效果将改变控制权，对象为g（1张）。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- ①效果处理：取得对象怪兽，若其仍与效果相关，则获得其控制权直到结束阶段，并给它附加不能发动效果和不能攻击宣言的限制。
function c99666430.ctrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果相关，且成功获得控制权（持续到结束阶段），才继续附加限制效果。
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
		-- 这个效果得到控制权的怪兽不能把效果发动
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 不能攻击宣言
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 用于判断一张卡是否为表侧表示的陷阱卡（②效果的场地条件用）。
function c99666430.confilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP)
end
-- ②效果的发动条件：双方场上存在表侧表示的陷阱卡时满足。
function c99666430.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1张表侧表示的陷阱卡。
	return Duel.IsExistingMatchingCard(c99666430.confilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 解放筛选函数：判断某只怪兽作为解放对象后，场上仍存在至少1张表侧表示卡可供破坏。
function c99666430.rlfilter(c,tp)
	-- 检查除该怪兽外，场上是否还有表侧表示的卡。
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- ②效果的发动目标处理：确认可以解放1只符合条件的怪兽，并预登记可破坏的对象范围为场上所有表侧表示的卡（数量1）。
function c99666430.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认效果处理时能够解放1只满足条件的怪兽。
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c99666430.rlfilter,1,REASON_EFFECT,false,nil,tp) end
	-- 获取场上所有表侧表示的卡，作为可被破坏的候选集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 登记破坏操作信息：将破坏g中的1张表侧表示卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：选择1只怪兽解放，解放成功后再选择场上1张表侧表示的卡破坏。
function c99666430.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示消息，要求玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只满足“解放后场上仍有表侧表示卡”条件的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroupEx(tp,c99666430.rlfilter,1,1,REASON_EFFECT,false,nil,tp)
	if g:GetCount()==0 then
		-- 如果没有满足特殊条件的怪兽，则退化为从所有可解放的卡中选择1只，确保效果能处理。
		g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_EFFECT,false,nil)
	end
	if g:GetCount()>0 then
		-- 显示并记录被选为解放对象的卡片动画。
		Duel.HintSelection(g)
		-- 执行解放，若解放成功（返回非0）则继续处理破坏部分。
		if Duel.Release(g,REASON_EFFECT)~=0 then
			-- 发送提示消息，要求玩家选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 让玩家从双方场上表侧表示的卡中选择1张作为破坏对象。
			local dg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if dg:GetCount()>0 then
				-- 显示并记录被选为破坏对象的卡片动画。
				Duel.HintSelection(dg)
				-- 将选择的卡片破坏（效果破坏）。
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end
