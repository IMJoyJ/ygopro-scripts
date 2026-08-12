--繋星の雷后
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：这张卡可以让自己场上最多2只怪兽回到手卡，从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合，把手卡的怪兽任意数量给对方观看（相同等级最多1只），以那个数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果无效。
-- ③：场上的这张卡被效果破坏送去墓地的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片的初始化效果，包含手牌特殊召唤的手续效果、特殊召唤成功时展示手牌怪兽无效对方场上卡片效果的效果，以及自己被效果破坏送墓时回收自身的效果
function s.initial_effect(c)
	-- ①：这张卡可以让自己场上最多2只怪兽回到手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合，把手卡的怪兽任意数量给对方观看（相同等级最多1只），以那个数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被效果破坏送去墓地的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 特召手续的怪兽过滤条件：能作为代价回到手牌，且使其离开后能空出可用的主要怪兽区域
function s.spfilter(c,tp)
	-- 判断怪兽是否可以因代价回到手牌，且在其离开场上后怪兽区是否有空位
	return c:IsAbleToHandAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特召规则的发动条件判定：检查玩家自己场上是否存在满足特召手续回手条件的怪兽
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定自己场上是否存在至少1只可用于支付特召代价的怪兽
	return Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,tp)
end
-- 判定怪兽组合的合法性条件：选择的怪兽中至少有1只满足特召手续回手的过滤条件
function s.gcheck(g,tp)
	return g:IsExists(s.spfilter,1,nil,tp)
end
-- 特召规则的目标选择：让玩家从自己场上选择1到2只怪兽作为回到手牌的代价，并将其保存到LabelObject
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有可以作为特召代价回到手牌的怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,true,1,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特召规则的执行处理：将选择的怪兽因特殊召唤手续送回玩家手牌
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 手动为被选作特召手续的怪兽显示选定动画效果
	Duel.HintSelection(g)
	-- 将选择的怪兽作为特殊召唤手续送回持有者的手牌
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 展示手牌怪兽的过滤条件：手牌中未公开的怪兽
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 无效效果的发动代价处理：计算对方场上可无效卡的数量，让玩家从中选择最多等量的且等级互不相同的手牌怪兽给对方确认，记录展示的数量并洗牌
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计对方场上所有可以作为效果无效化目标的卡片数量
	local ct=Duel.GetTargetCount(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 判断玩家手牌中是否存在可以展示给对方确认的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 获取玩家手牌中所有未公开的怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	-- 提示玩家选择给对方观看并确认的手牌怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 使用等级检查辅助函数，约束后续选择的卡片组合必须满足所有卡片等级互不相同
	aux.GCheckAdditional=aux.dlvcheck
	-- 让玩家选择1到数量上限的怪兽（相同等级最多1只）
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,ct)
	-- 重置等级检查辅助函数
	aux.GCheckAdditional=nil
	-- 将选择的怪兽展示给对方玩家进行确认
	Duel.ConfirmCards(1-tp,sg)
	-- 洗切展示卡片玩家的手牌
	Duel.ShuffleHand(tp)
	e:SetLabel(sg:GetCount())
end
-- 无效效果的发动准备与对象选择：在对方场上选择与展示卡片数量相同数量的表侧表示卡片作为对象，并设置无效分类的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 处理连锁中作为对象的目标判定逻辑：对象卡片必须位于对方场上，且其效果可以被无效
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and aux.NegateAnyFilter(chkc) and chkc:IsControler(1-tp) end
	-- 判断是否已进行代价检查且对方场上是否存在可以被无效的对象卡片
	if chk==0 then return e:IsCostChecked() and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 提示玩家选择需要无效其效果的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家在对方场上选择与展示手牌数量相同数量的表侧表示卡片作为效果的对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置连锁的操作信息：预计无效这些目标卡片的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 无效效果的具体处理：遍历所有在场且与本次效果连锁相关的对象卡片，将其相关的连锁效果无效，并注册无效化的永续效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍然相关的对象卡片组合
	local dg=Duel.GetTargetsRelateToChain()
	-- 遍历卡片组中的每一个对象卡片
	for tc in aux.Next(dg) do
		-- 使与该卡片相关的所有正在连锁的效果失效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那些卡的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那些卡的效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那些卡的效果无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- 回收效果的发动条件判定：检查这张卡在场上是否被效果破坏
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetReason()&0x41==0x41 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 回收效果的发动准备：判断自身是否可以加入手牌，并设置连锁操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁的操作信息：预计将自身加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 回收效果的具体处理：若自身与连锁有关且不受王家长眠之谷无效，则将其送回玩家手牌并让对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定自身是否仍与连锁相关，且未受王家长眠之谷的效果无效
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 因效果将自身送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 将回收的卡片向对方玩家进行确认
		Duel.ConfirmCards(1-tp,c)
	end
end
