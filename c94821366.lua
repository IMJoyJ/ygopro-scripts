--驚楽園の支配人 ＜∀rlechino＞
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：对方对怪兽的召唤·特殊召唤成功的场合，以那1只对方怪兽为对象才能发动。从卡组选1张「游乐设施」陷阱卡给那只对方怪兽装备。
-- ③：1回合1次，从自己墓地把「游乐设施」陷阱卡任意数量除外，以那个数量的对方场上的卡为对象才能发动。那些卡破坏。
function c94821366.initial_effect(c)
	-- ①：陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94821366,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,94821366)
	e1:SetCondition(c94821366.spcon)
	e1:SetTarget(c94821366.sptg)
	e1:SetOperation(c94821366.spop)
	c:RegisterEffect(e1)
	-- ②：对方对怪兽的召唤·特殊召唤成功的场合，以那1只对方怪兽为对象才能发动。从卡组选1张「游乐设施」陷阱卡给那只对方怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94821366,1))  --"装备"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,94821367)
	e2:SetTarget(c94821366.eqtg)
	e2:SetOperation(c94821366.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：1回合1次，从自己墓地把「游乐设施」陷阱卡任意数量除外，以那个数量的对方场上的卡为对象才能发动。那些卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(94821366,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c94821366.descost)
	e4:SetTarget(c94821366.destg)
	e4:SetOperation(c94821366.desop)
	c:RegisterEffect(e4)
end
-- 判断发动连锁的卡是否为陷阱卡的发动
function c94821366.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 特殊召唤效果的发动准备与检测
function c94821366.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理，将自身特殊召唤
function c94821366.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤满足条件的对方召唤·特殊召唤成功的怪兽，且卡组中存在可装备的「游乐设施」陷阱卡
function c94821366.eqfilter1(c,e,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsCanBeEffectTarget(e) and c:IsControler(1-tp) and c:IsSummonPlayer(1-tp)
		-- 检查卡组中是否存在至少1张满足条件的「游乐设施」陷阱卡
		and Duel.IsExistingMatchingCard(c94821366.eqfilter2,tp,LOCATION_DECK,0,1,nil)
end
-- 过滤卡组中属于「游乐设施」字段且不被禁止使用的陷阱卡
function c94821366.eqfilter2(c)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and not c:IsForbidden()
end
-- 装备效果的发动准备，选择1只对方召唤·特殊召唤成功的怪兽作为效果的对象
function c94821366.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c94821366.eqfilter1(chkc,e,tp) end
	-- 在发动准备阶段，检查自己魔法与陷阱区域是否有空位，且是否存在满足条件的对方怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and eg:IsExists(c94821366.eqfilter1,1,nil,e,tp) end
	local g=eg:Clone()
	if #eg>1 then
		-- 向玩家发送提示信息，要求选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=eg:FilterSelect(tp,c94821366.eqfilter1,1,1,nil,e,tp)
	end
	-- 将选择的怪兽卡组设置为当前连锁的对象
	Duel.SetTargetCard(g)
end
-- 装备效果的处理，从卡组选1张「游乐设施」陷阱卡装备给对象怪兽
function c94821366.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果此时自己场上没有可用的魔法与陷阱区域，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(tp) then return end
	-- 向玩家发送提示信息，要求选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从卡组中选择1张满足条件的「游乐设施」陷阱卡
	local sg=Duel.SelectMatchingCard(tp,c94821366.eqfilter2,tp,LOCATION_DECK,0,1,1,nil)
	local sc=sg:GetFirst()
	if sc then
		-- 将选中的陷阱卡作为装备卡装备给对象怪兽，若装备失败则结束处理
		if not Duel.Equip(tp,sc,tc) then return end
		-- 从卡组选1张「游乐设施」陷阱卡给那只对方怪兽装备。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c94821366.eqlimit)
		e1:SetLabelObject(tc)
		sc:RegisterEffect(e1)
	end
end
-- 定义装备限制，使该装备卡只能装备给指定的怪兽
function c94821366.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- 过滤自己墓地中可以作为发动成本除外的「游乐设施」陷阱卡
function c94821366.costfilter(c)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 破坏效果的发动成本处理，从自己墓地除外任意数量的「游乐设施」陷阱卡，并记录除外的数量
function c94821366.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己墓地是否存在至少1张可除外的「游乐设施」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c94821366.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取对方场上可以作为效果对象的卡片数量，作为除外数量的上限
	local rt=Duel.GetTargetCount(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 向玩家发送提示信息，要求选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张到上限数量的「游乐设施」陷阱卡
	local g=Duel.SelectMatchingCard(tp,c94821366.costfilter,tp,LOCATION_GRAVE,0,1,rt,nil)
	-- 将选择的卡片表侧表示除外作为发动成本，并返回实际除外的卡片数量
	local cg=Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(cg)
end
-- 破坏效果的发动准备，以与除外数量相同的对方场上的卡为对象
function c94821366.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在发动准备阶段，检查对方场上是否存在至少1张可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 向玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择与除外数量相同数量的对方场上的卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置当前连锁的操作信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 破坏效果的处理，将作为对象的卡片破坏
function c94821366.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #rg>0 then
		-- 因效果将依然存在于场上且与效果相关的对象卡片破坏
		Duel.Destroy(rg,REASON_EFFECT)
	end
end
