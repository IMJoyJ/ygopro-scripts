--魔界劇団－スーパー・プロデューサー
-- 效果：
-- 包含恶魔族怪兽的怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏。那之后，可以从以下效果选1个适用。
-- ●从卡组选1张「魔界剧场「奇幻剧场」」在自己的场地区域表侧表示放置。
-- ●从卡组选1只「魔界剧团」灵摆怪兽在自己的灵摆区域放置。
local s,id,o=GetID()
-- 初始化卡片的连接召唤手续（2只怪兽且含恶魔族）及①效果：自己·对方主要阶段以自己场上表侧表示卡为对象发动，破坏后可选择从卡组将「魔界剧场「奇幻剧场」」放置到场地区或「魔界剧团」灵摆怪兽放置到灵摆区。
function s.initial_effect(c)
	-- 记录此卡文本中提到的卡号77297908（「魔界剧场「奇幻剧场」」），使卡组检索/代码列表功能能够识别该卡名。
	aux.AddCodeList(c,77297908)
	c:EnableReviveLimit()
	-- 给这张卡添加连接召唤手续：需要2只怪兽作为素材，且素材组需通过s.lchk检查（至少含1只恶魔族怪兽）。
	aux.AddLinkProcedure(c,nil,2,2,s.lchk)
	-- 这个卡名的效果1回合只能使用1次。①：自己·对方的主要阶段，以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏。那之后，可以从以下效果选1个适用。●从卡组选1张「魔界剧场「奇幻剧场」」在自己的场地区域表侧表示放置。●从卡组选1只「魔界剧团」灵摆怪兽在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.dtfcon)
	e1:SetTarget(s.dtftg)
	e1:SetOperation(s.dtfop)
	c:RegisterEffect(e1)
end
-- 连接素材检查函数：判断素材组中是否存在至少1只恶魔族怪兽（RACE_FIEND）。
function s.lchk(g)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_FIEND)
end
-- ①效果的发动条件：当前阶段为主要阶段1或主要阶段2时才能发动。
function s.dtfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于与主要阶段1/2比较。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 检索过滤函数：选择卡组中符合条件的卡——「魔界剧场「奇幻剧场」」（卡号77297908），或「魔界剧团」字段（0x10ec）且为灵摆怪兽，并确保该卡不是禁止卡且满足场上同名卡限制。
function s.filter(c,tp)
	return (c:IsCode(77297908) or c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM)
			-- 同时要求自己的灵摆区域（序号0或1）至少有一个空格，保证灵摆怪兽可以被放置到灵摆区。
			and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)))
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果的取对象目标处理：选择自己场上1张表侧表示的卡作为对象，并设置破坏类操作信息。
function s.dtftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 在效果发动合法性检查时，确认自己场上存在至少1张表侧表示卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向操作玩家显示选择提示“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上的表侧表示卡中选择1张，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：本次连锁将破坏1张卡，目标为g，供后续效果连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：先破坏对象卡，若成功且卡组有可放置的卡，则询问玩家是否适用后续放置效果，之后执行从卡组选卡放置到场地区或灵摆区。
function s.dtfop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（要破坏的那张卡）。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡已不在场上/不关联本效果，或破坏处理未成功则终止后续处理。
	if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	-- 检查卡组中是否存在满足s.filter条件的卡（「魔界剧场「奇幻剧场」」或「魔界剧团」灵摆怪兽）。
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp)
		-- 若存在候选卡，再询问玩家是否选择适用“从卡组选卡放置上场”的追加效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组选卡上场？"
		-- 中断当前效果处理，使后续的放置处理与之前的破坏处理错开时点。
		Duel.BreakEffect()
		-- 向操作玩家显示选择提示“请选择要放置到场上的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 让玩家从卡组选出1张满足s.filter条件的卡，并取得该卡。
		local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		-- 获取自己场地区域（编号5）的卡，用于判断是否已有场地魔法。
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if sc:IsType(TYPE_FIELD) and fc then
			-- 若场地区已有卡，则按规则将旧场地卡送去墓地，以便放置新场地。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 再次中断效果处理，使旧场地送墓与新场地放置不同时处理。
			Duel.BreakEffect()
		end
		local loc=sc:IsType(TYPE_FIELD) and LOCATION_FZONE or LOCATION_PZONE
		-- 将选出的卡以表侧表示移动到目标区域：场地魔法到场地区，灵摆怪兽到灵摆区域。
		Duel.MoveToField(sc,tp,tp,loc,POS_FACEUP,true)
	end
end
