--セイヴァー・スター・ドラゴン
-- 效果：
-- 「救世龙」＋「星尘龙」＋调整以外的怪兽1只
-- 对方把魔法·陷阱·效果怪兽的效果发动时，可以通过把这张卡解放来让那个发动无效，对方场上的卡全部破坏。1回合1次，可以选择对方场上表侧表示存在的1只怪兽，那个效果直到结束阶段时无效。此外，这个效果无效的怪兽记述的效果在这个回合可以作为这张卡的效果只有1次发动。结束阶段时，这张卡回到额外卡组，选择自己墓地1只「星尘龙」特殊召唤。
function c7841112.initial_effect(c)
	-- 为这张卡添加作为同调素材的特定卡片代码列表（救世龙和星尘龙）
	aux.AddMaterialCodeList(c,21159309,44508094)
	-- 添加同调召唤手续：需要「救世龙」+「星尘龙」+ 1只调整以外的怪兽
	aux.AddSynchroMixProcedure(c,c7841112.mfilter1,c7841112.mfilter2,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- 对方把魔法·陷阱·效果怪兽的效果发动时，可以通过把这张卡解放来让那个发动无效，对方场上的卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7841112,0))  --"发动无效，对方场上的卡全部破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c7841112.negcon)
	e2:SetCost(c7841112.negcost)
	e2:SetTarget(c7841112.negtg)
	e2:SetOperation(c7841112.negop)
	c:RegisterEffect(e2)
	-- 1回合1次，可以选择对方场上表侧表示存在的1只怪兽，那个效果直到结束阶段时无效。此外，这个效果无效的怪兽记述的效果在这个回合可以作为这张卡的效果只有1次发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(7841112,1))  --"效果无效化"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c7841112.distg)
	e3:SetOperation(c7841112.disop)
	c:RegisterEffect(e3)
	-- 此外，这个效果无效的怪兽记述的效果在这个回合可以作为这张卡的效果只有1次发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(c7841112.alop)
	c:RegisterEffect(e4)
	-- 结束阶段时，这张卡回到额外卡组，选择自己墓地1只「星尘龙」特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(7841112,2))  --"返回额外卡组"
	e5:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e5:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetTarget(c7841112.sptg)
	e5:SetOperation(c7841112.spop)
	c:RegisterEffect(e5)
end
c7841112.material_type=TYPE_SYNCHRO
-- 过滤同调素材1：卡名为「救世龙」的怪兽
function c7841112.mfilter1(c)
	return c:IsCode(21159309)
end
-- 过滤同调素材2：卡名为「星尘龙」且在同调召唤中作为调整或与另一张卡其中之一作为调整的怪兽
function c7841112.mfilter2(c,syncard,c1)
	return c:IsCode(44508094) and (c:IsTuner(syncard) or c1:IsTuner(syncard))
end
-- 对方发动效果时无效并破坏效果的发动条件函数
function c7841112.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身未被战斗破坏、发动效果的玩家为对方且该连锁的发动可以被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp and Duel.IsChainNegatable(ev)
end
-- 对方发动效果时无效并破坏效果的消耗（Cost）函数
function c7841112.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 对方发动效果时无效并破坏效果的目标（Target）函数
function c7841112.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息：破坏对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 对方发动效果时无效并破坏效果的操作（Operation）函数
function c7841112.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效
	Duel.NegateActivation(ev)
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏获取到的对方场上的所有卡片
	Duel.Destroy(g,REASON_EFFECT)
end
-- 选择对方场上1只表侧表示怪兽无效其效果的目标（Target）函数
function c7841112.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查指向的对象是否为对方场上表侧表示且可被无效的效果怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 检查对方场上是否存在至少1只表侧表示且可被无效的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只表侧表示且可被无效的效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：使选中的怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 选择对方场上1只表侧表示怪兽无效其效果并复制其效果的操作（Operation）函数
function c7841112.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那个效果直到结束阶段时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那个效果直到结束阶段时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 复制被无效怪兽记述的效果
		Duel.MajesticCopy(c,tc)
	end
end
-- 限制复制的效果在回合内只能发动1次的操作函数
function c7841112.alop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetOwner()==e:GetOwner() and not re:IsHasProperty(EFFECT_FLAG_INITIAL) then
		-- 此外，这个效果无效的怪兽记述的效果在这个回合可以作为这张卡的效果只有1次发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(1,1)
		e1:SetValue(c7841112.aclimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e:GetHandler():RegisterEffect(e1)
	end
end
-- 限制玩家不能再次发动已复制的非初始效果
function c7841112.aclimit(e,re,tp)
	return re:GetOwner()==e:GetOwner() and not re:IsHasProperty(EFFECT_FLAG_INITIAL)
end
-- 过滤墓地中可以特殊召唤的「星尘龙」
function c7841112.spfilter(c,e,tp)
	return c:IsCode(44508094) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 结束阶段回到额外卡组并特召「星尘龙」的效果目标（Target）函数
function c7841112.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c7841112.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「星尘龙」作为效果对象
	local g=Duel.SelectTarget(tp,c7841112.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：将自身送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
	-- 设置效果处理信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 结束阶段回到额外卡组并特召「星尘龙」的效果操作（Operation）函数
function c7841112.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的特殊召唤对象
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 检查自身是否仍受效果影响，若是则将自身送回额外卡组
	if c:IsRelateToEffect(e) and c:IsExtraDeckMonster() and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_EXTRA) and tc and tc:IsRelateToEffect(e) then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
