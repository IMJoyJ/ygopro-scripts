--破械神雙ラギア
-- 效果：
-- 包含恶魔族怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽表侧表示特殊召唤的场合，以那之内的1只为对象才能发动。自己场上1只恶魔族怪兽破坏，作为对象的怪兽的效果直到回合结束时无效。
-- ②：自己场上有连接4以上的「破械」连接怪兽存在，场上的怪兽的效果发动时，把墓地的这张卡除外才能发动。那只把效果发动的怪兽破坏。
local s,id,o=GetID()
-- 初始化卡片效果：设定连接召唤条件（包含恶魔族怪兽的怪兽2只以上），并注册①②效果及同名卡1回合各1次的限制
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：需要包含恶魔族怪兽的怪兽2只以上（最多3只）
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	-- 为本卡注册合并延迟特召事件，避免同一连锁中多次特殊召唤重复触发①效果
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方把怪兽表侧表示特殊召唤的场合，以那之内的1只为对象才能发动。自己场上1只恶魔族怪兽破坏，作为对象的怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"无效"
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
	-- ②：自己场上有连接4以上的「破械」连接怪兽存在，场上的怪兽的效果发动时，把墓地的这张卡除外才能发动。那只把效果发动的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	-- 设定②效果的发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 连接素材检查函数：确认所选素材中包含至少1只恶魔族怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_FIEND)
end
-- ①效果对象过滤函数：筛选对方表侧表示特殊召唤到场上、可取对象且可被无效的效果怪兽
function s.disfilter(c,tp,e)
	-- 检查怪兽表侧表示在怪兽区、由对方特殊召唤、可成为效果对象且是可无效的效果怪兽
	return c:IsFaceupEx() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e) and aux.NegateEffectMonsterFilter(c)
end
-- ①效果发动条件：检查本次特殊召唤事件中是否存在由对方特殊召唤的怪兽
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 破坏目标过滤函数：筛选表侧表示的恶魔族怪兽
function s.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 取对象校验过滤函数：确保选中的无效对象在特召组内，且不会导致没有其他恶魔族怪兽可破坏
function s.tgfilter(c,g,dg)
	return g:IsContains(c) and (dg:GetCount()>1 or not dg:IsContains(c))
end
-- ①效果目标设定：确认自己场上有恶魔族怪兽且存在合法的对方特召怪兽，选择1只作为无效对象并登记操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.disfilter,nil,tp,e)
	-- 获取自己场上所有表侧表示的恶魔族怪兽
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return dg:GetCount()>0
		-- 检查场上是否存在满足条件且可成为效果对象的目标怪兽
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g,dg) end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 当仅有1只符合条件的特召怪兽时，直接将其设为效果对象
		Duel.SetTargetCard(sg)
	else
		-- 向玩家提示选择要无效效果的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家从符合条件的怪兽中选择1只作为效果对象
		sg=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g,dg)
	end
	-- 声明本次效果将无效选定对象的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
	-- 声明本次效果将破坏自己场上1只恶魔族怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- ①效果处理：优先选择对象以外的自己场上1只恶魔族怪兽破坏，成功破坏后使作为对象的怪兽效果直到回合结束时无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果指定的对象怪兽
	local tgc=Duel.GetFirstTarget()
	local tc=nil
	if tgc and tgc:IsRelateToChain() then tc=tgc end
	-- 向玩家提示选择要破坏的恶魔族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家先尝试从自己场上选择1只与对象不同的恶魔族怪兽准备破坏
	local sg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,tc)
	if sg:GetCount()==0 then
		-- 若不存在其他恶魔族怪兽，则允许从自己场上任意选择1只恶魔族怪兽（包括对象自身）
		sg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	end
	if sg:GetCount()>0 then
		-- 向双方提示展示被选择破坏的恶魔族怪兽
		Duel.HintSelection(sg)
		-- 破坏选中的恶魔族怪兽并判断是否成功破坏
		if Duel.Destroy(sg,REASON_EFFECT)~=0
			and tc and tc:IsRelateToChain() and tc:IsOnField() and tc:IsCanBeDisabledByEffect(e) then
			-- 使对象怪兽相关的当前连锁效果无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 作为对象的怪兽的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 作为对象的怪兽的效果直到回合结束时无效。
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
-- ②效果存在条件过滤函数：筛选表侧表示且连接4以上的「破械」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsLinkAbove(4) and c:IsSetCard(0x130)
end
-- ②效果发动条件：检查是否为场上怪兽发动效果，且自己场上有连接4以上的「破械」怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
		-- 检查自己怪兽区是否存在连接4以上的表侧「破械」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果目标设定：检查发动效果的怪兽是否可破坏，并设定其为处理对象与破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 将发动效果的怪兽设为本次效果的处理对象
	Duel.SetTargetCard(re:GetHandler())
	-- 声明本次效果将破坏那只发动效果的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- ②效果处理：若那只怪兽仍与当前连锁有联系且为怪兽卡，则将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取记录的发动效果的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 以效果原因破坏那只把效果发动的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
