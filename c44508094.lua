--スターダスト・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
-- ②：这张卡的①的效果适用的回合的结束阶段才能发动。为那个效果发动而解放的这张卡从墓地特殊召唤。
function c44508094.initial_effect(c)
	-- 注册同调召唤手续：需要1只调整怪兽与1只以上调整以外的怪兽
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
-- 设置效果①的发动条件：排除了自身战斗破坏确定的状态、无法被无效的效果，以及特定连锁情况，且当前被发动的连锁中含有破坏场上卡片的效果
function c44508094.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若本卡已战斗破坏确定，或者当前连锁无法被无效，则不满足发动条件
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 并且判定前一个连锁不能是属于激活并无效魔陷发动的效果，以符合无效类卡片的正常响应链规则
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取触发效果在操作信息中是否有破坏卡片的信息，以及计算受该破坏效果影响的场上卡片数量
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 过滤条件：在墓地中寻找可以作为代替解放代价除外的卡片
function c44508094.excostfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsHasEffect(84012625,tp)
end
-- 效果①的发动代价支付：正常解放自身，或者当自身符合「救世」系列时可将墓地的特定卡片作为代替解放而除外
function c44508094.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Group.CreateGroup()
	local c=e:GetHandler()
	if c:IsReleasable() then g:AddCard(c) end
	-- 若本卡为「救世」系列卡片，则将墓地中可用于代替解放的卡片与本卡合并，作为可选代价卡片组
	if c:IsSetCard(0xa3) then g:Merge(Duel.GetMatchingGroup(c44508094.excostfilter,tp,LOCATION_GRAVE,0,nil,tp)) end
	if chk==0 then return #g>0 end
	local tc
	if #g>1 then
		-- 提示玩家选择解放的卡或者代替除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(84012625,0))  --"请选择要解放或代替解放除外的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	local te=tc:IsHasEffect(84012625,tp)
	if te then
		-- 若玩家选择了代替卡片，则将该卡表侧除外以作为代替代价
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 若正常解放，则将所选的本卡作为代价解放并送去墓地
		Duel.Release(tc,REASON_COST)
	end
end
-- 效果①的发动准备：进行连锁无效与卡片破坏的操作信息设置
function c44508094.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效当前连锁的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若触发效果的卡片能够被破坏且符合关联条件，则设置操作信息：破坏引发该连锁的卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的效果处理：使被触发的效果的发动无效并破坏那张卡，之后为本卡注册在结束阶段可以特殊召唤的标志
function c44508094.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使得被触发的效果发动无效，且该卡符合关联判定
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该卡片破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
	e:GetHandler():RegisterFlagEffect(44508094,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
-- 效果②的发动准备与合法性检查：检查场上是否有怪兽空格，本卡本回合是否成功适用了效果①，以及能否从墓地特殊召唤
function c44508094.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时，检查自己场上是否有空闲的主要怪兽区域，且本卡具有效果①适用的阶段标志
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetFlagEffect(44508094)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将墓地中的本卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的效果处理：将为该效果发动而解放并送去墓地的本卡重新特殊召唤到自己场上
function c44508094.sumop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将本卡在自己场上以表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
