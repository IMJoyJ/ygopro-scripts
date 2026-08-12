--青い涙の天使
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以场上1只表侧表示怪兽为对象才能发动。从那只怪兽的控制者来看的对方受到自身手卡数量×200伤害。那之后，作为对象的怪兽的效果直到回合结束时无效。
-- ②：自己或对方受到效果伤害的场合，把墓地的这张卡除外才能发动。从手卡·卡组把1张通常陷阱卡在自己场上盖放。从手卡盖放的场合，那张卡在盖放的回合也能发动。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。从那只怪兽的控制者来看的对方受到自身手卡数量×200伤害。那之后，作为对象的怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己或对方受到效果伤害的场合，把墓地的这张卡除外才能发动。从手卡·卡组把1张通常陷阱卡在自己场上盖放。从手卡盖放的场合，那张卡在盖放的回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"通常陷阱卡盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	-- 设置发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 定义可被无效且其控制者的对手手卡数大于0的怪兽的过滤条件
function s.negfilter(c,ec)
	local p=c:GetControler()
	-- 检查怪兽是否可被无效，且其控制者的对手手卡数大于0
	return aux.NegateMonsterFilter(c) and Duel.GetMatchingGroupCount(aux.TRUE,p,0,LOCATION_HAND,ec)>0
end
-- ①效果的发动准备，选择对象并设置伤害参数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.negfilter(chkc,c) end
	-- 检查场上是否存在符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c) end
	-- 提示玩家选择要无效的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,nil)
	local p=g:GetFirst():GetControler()
	-- 计算伤害数值（对象怪兽控制者的对手的手卡数量×200）
	local dam=Duel.GetFieldGroupCount(p,0,LOCATION_HAND)*200
	-- 设置受到伤害的玩家为对象怪兽控制者的对手
	Duel.SetTargetPlayer(1-p)
	-- 设置伤害数值参数
	Duel.SetTargetParam(dam)
	-- 设置连锁的操作信息为给予伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-p,dam)
end
-- ①效果的处理，给予伤害并无效对象怪兽的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local p=tc:GetControler()
		-- 重新计算伤害数值
		local dam=Duel.GetFieldGroupCount(p,0,LOCATION_HAND)*200
		-- 给予对方效果伤害，若伤害为0或未成功造成伤害则结束处理
		if dam==0 or Duel.Damage(1-p,dam,REASON_EFFECT)==0 then return end
		-- 中断效果处理，使后续的无效处理与伤害处理不视为同时进行
		Duel.BreakEffect()
		if tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
			-- 使与该怪兽相关的连锁中已发动的效果无效
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 作为对象的怪兽的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 作为对象的怪兽的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
-- 检查受到伤害的原因是否为效果伤害
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 定义手卡·卡组中可盖放的通常陷阱卡的过滤条件
function s.setfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- ②效果的发动准备，检查是否存在可盖放的通常陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·卡组是否存在可盖放的通常陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
end
-- ②效果的处理，从手卡·卡组盖放通常陷阱卡并处理手卡盖放时的特殊发动规则
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从手卡·卡组选择1张通常陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
		-- 获取刚才实际操作盖放的卡片组
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_HAND) then
			-- 从手卡盖放的场合，那张卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))  --"适用「蓝泪的天使」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
		end
	end
end
