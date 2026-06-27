--破械神雙ラギア
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 连接召唤条件：怪兽2只以上，必须包含恶魔族怪兽
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	-- 注册检测多只怪兽同时被特殊召唤的延迟事件
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ①：对方对怪兽的特殊召唤成功时才能发动。选自己场上1只恶魔族怪兽破坏，若成功破坏，那只特殊召唤的对方怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(custom_code)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时，自己场上有连接4以上的「破械」怪兽存在的场合，把墓地的这张卡除外才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	-- 效果代价：将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 连接素材检查：素材中是否包含恶魔族怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_FIEND)
end
-- 过滤被对方特殊召唤且可被无效的效果怪兽
function s.disfilter(c,tp,e)
	-- 检查是否为对方召唤的可无效效果怪兽
	return c:IsFaceupEx() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e) and aux.NegateEffectMonsterFilter(c)
end
-- 触发条件检查：对方特殊召唤成功
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 过滤我方场上表侧表示的恶魔族怪兽
function s.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 过滤可以作为破坏代价的我方恶魔族怪兽
function s.tgfilter(c,g,dg)
	return g:IsContains(c) and (dg:GetCount()>1 or not dg:IsContains(c))
end
-- 效果①的目标锁定与条件检查
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.disfilter,nil,tp,e)
	-- 获取我方场上的所有恶魔族怪兽
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return g:GetCount()>0 and (dg:GetCount()>1 or dg~=g) end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 设置所选择的卡片为效果目标
		Duel.SetTargetCard(sg)
	else
		-- 提示选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 选择1只对方特召的怪兽作为效果对象
		sg=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g,dg)
	end
	-- 声明无效对方怪兽效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
	if dg:GetCount()>0 then
		-- 声明破坏我方怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果①的实际处理：破坏我方怪兽并无效对方怪兽效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选中的对方怪兽
	local tgc=Duel.GetFirstTarget()
	local tc=nil
	if tgc and tgc:IsRelateToChain() then tc=tgc end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择我方1只符合破坏条件的恶魔族怪兽
	local sg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,tc)
	if sg:GetCount()>0 then
		-- 高亮显示要破坏的我方怪兽
		Duel.HintSelection(sg)
		-- 将选中的我方怪兽破坏并判断是否破坏成功
		if Duel.Destroy(sg,REASON_EFFECT)~=0
			and tc and tc:IsRelateToChain() and tc:IsOnField() and tc:IsCanBeDisabledByEffect(e) then
			-- 阻断目标怪兽的相关连锁
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标怪兽的效果无效化直到回合结束
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使目标怪兽发动的效果无效化直到回合结束
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
-- 过滤自己场上连接4以上的「破械」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsLinkAbove(4) and c:IsSetCard(0x130)
end
-- 效果②的触发条件：对方场上发动怪兽效果，且自己场上存在连接4以上的「破械」怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
		-- 检查我方场上是否存在符合条件的破械连接怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的目标锁定与检查
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 将对方发动的怪兽锁定为效果对象
	Duel.SetTargetCard(re:GetHandler())
	-- 声明破坏目标怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 效果②的实际处理
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取锁定的怪兽对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 将该怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
