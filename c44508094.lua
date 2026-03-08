--スターダスト・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
-- ②：这张卡的①的效果适用的回合的结束阶段才能发动。为那个效果发动而解放的这张卡从墓地特殊召唤。
function c44508094.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44508094,0))  --"破坏场上卡的效果发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c44508094.condition)
	e1:SetCost(c44508094.cost)
	e1:SetTarget(c44508094.target)
	e1:SetOperation(c44508094.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果适用的回合的结束阶段才能发动。为那个效果发动而解放的这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44508094,1))  --"回合结束时特殊召唤"
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c44508094.sumtg)
	e2:SetOperation(c44508094.sumop)
	c:RegisterEffect(e2)
end
-- 判断是否满足①效果的发动条件，包括是否被战斗破坏、连锁是否可无效、是否为魔法·陷阱·怪兽的效果发动
function c44508094.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若此卡在战斗中被破坏或连锁不可无效则不满足发动条件
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 若连锁效果为无效效果且触发效果为永续魔法则不满足发动条件
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取连锁中涉及的破坏效果信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 定义用于判断是否可以作为解放或代替解放除外的卡的过滤函数
function c44508094.excostfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsHasEffect(84012625,tp)
end
-- 处理①效果的解放费用，从墓地选择满足条件的卡进行解放或除外
function c44508094.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足解放条件的卡组
	local g=Duel.GetMatchingGroup(c44508094.excostfilter,tp,LOCATION_GRAVE,0,nil,tp)
	if e:GetHandler():IsReleasable() then g:AddCard(e:GetHandler()) end
	if chk==0 then return #g>0 end
	local tc
	if #g>1 then
		-- 提示玩家选择要解放或代替解放除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(84012625,0))  --"请选择要解放或代替解放除外的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	local te=tc:IsHasEffect(84012625,tp)
	if te then
		-- 将选中的卡除外作为解放费用
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 将选中的卡解放作为解放费用
		Duel.Release(tc,REASON_COST)
	end
end
-- 设置①效果的目标信息，包括无效和破坏
function c44508094.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行①效果的操作，使连锁无效并破坏对象卡
function c44508094.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否成功无效且对象卡是否有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏连锁对象卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
	e:GetHandler():RegisterFlagEffect(44508094,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
-- 设置②效果的特殊召唤条件
function c44508094.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足②效果的发动条件，包括是否有空场和是否被①效果解放过
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetFlagEffect(44508094)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置②效果的特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行②效果的特殊召唤操作
function c44508094.sumop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡从墓地特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
