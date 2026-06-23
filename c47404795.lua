--魔界劇団－スーパー・プロデューサー
-- 效果：
-- 包含恶魔族怪兽的怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏。那之后，可以从以下效果选1个适用。
-- ●从卡组选1张「魔界剧场「奇幻剧场」」在自己的场地区域表侧表示放置。
-- ●从卡组选1只「魔界剧团」灵摆怪兽在自己的灵摆区域放置。
local s,id,o=GetID()
-- 初始化效果，设置卡片的连接召唤条件和主要效果
function s.initial_effect(c)
	-- 记录该卡包含「魔界剧场「奇幻剧场」」这张卡
	aux.AddCodeList(c,77297908)
	c:EnableReviveLimit()
	-- 设置此卡为连接召唤，需要2只包含恶魔族的怪兽作为素材
	aux.AddLinkProcedure(c,nil,2,2,s.lchk)
	-- ①：自己·对方的主要阶段，以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏。那之后，可以从以下效果选1个适用。
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
-- 连接召唤时检查是否有包含恶魔族的怪兽
function s.lchk(g)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_FIEND)
end
-- 判断当前是否为主要阶段1或主要阶段2
function s.dtfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤函数，用于筛选可以放置到场上的卡（包括「魔界剧场「奇幻剧场」」和「魔界剧团」灵摆怪兽）
function s.filter(c,tp)
	return (c:IsCode(77297908) or c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM)
			-- 检查玩家的灵摆区域是否有空位
			and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)))
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 设置效果的目标选择处理，选择场上一张表侧表示的卡作为破坏对象
function s.dtftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 判断是否满足发动条件：场上存在一张表侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张表侧表示的卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息，记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的处理函数，先破坏目标卡，然后询问是否从卡组选卡上场
function s.dtfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否存在且成功破坏
	if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	-- 检查卡组中是否存在满足条件的卡
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp)
		-- 询问玩家是否发动后续效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组选卡上场？"
		-- 中断当前效果处理，使之后的效果视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从卡组中选择一张满足条件的卡
		local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		-- 获取玩家场上已存在的场地区域卡
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if sc:IsType(TYPE_FIELD) and fc then
			-- 将已存在的场地区域卡送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 再次中断当前效果处理
			Duel.BreakEffect()
		end
		local loc=sc:IsType(TYPE_FIELD) and LOCATION_FZONE or LOCATION_PZONE
		-- 将选中的卡移动到指定区域（灵摆区或场地区域）
		Duel.MoveToField(sc,tp,tp,loc,POS_FACEUP,true)
	end
end
