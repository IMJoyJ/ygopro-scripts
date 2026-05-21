--ラスタライガー
-- 效果：
-- 衍生物以外的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己或者对方的墓地1只连接怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升那只怪兽的攻击力数值。
-- ②：把这张卡所连接区的自己怪兽任意数量解放才能发动。选解放的怪兽数量的场上的卡破坏。
function c88000953.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，素材为2只以上非衍生物的怪兽。
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2)
	-- ①：以自己或者对方的墓地1只连接怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升那只怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88000953,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,88000953)
	e1:SetTarget(c88000953.atktg)
	e1:SetOperation(c88000953.atkop)
	c:RegisterEffect(e1)
	-- ②：把这张卡所连接区的自己怪兽任意数量解放才能发动。选解放的怪兽数量的场上的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88000953,1))  --"卡片破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,88000954)
	e2:SetCost(c88000953.descost)
	e2:SetTarget(c88000953.destg)
	e2:SetOperation(c88000953.desop)
	c:RegisterEffect(e2)
end
-- 过滤墓地中攻击力在1以上的连接怪兽。
function c88000953.atkfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAttackAbove(1)
end
-- 效果①的对象选择与发动准备函数。
function c88000953.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c88000953.atkfilter(chkc) end
	-- 检查双方墓地是否存在至少1只满足条件的连接怪兽。
	if chk==0 then return Duel.IsExistingTarget(c88000953.atkfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择双方墓地中的1只连接怪兽作为效果对象。
	Duel.SelectTarget(tp,c88000953.atkfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
end
-- 效果①的处理函数，使这张卡的攻击力上升目标怪兽的攻击力数值。
function c88000953.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的墓地怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升那只怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤可作为解放Cost的怪兽，该怪兽必须在所连接区，且场上存在除该怪兽（及以其为装备的卡）以外的卡可被破坏。
function c88000953.costfilter(c,tp,g)
	return g:IsContains(c)
		-- 检查场上是否存在至少1张除被解放怪兽以外的、可被破坏的卡。
		and Duel.IsExistingMatchingCard(c88000953.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,Group.FromCards(c))
end
-- 过滤可破坏的卡，排除装备在即将被解放的怪兽身上的装备卡。
function c88000953.desfilter(c,g)
	local ec=c:GetEquipTarget()
	return not ec or not g:IsContains(ec)
end
-- 检查选定的解放怪兽组是否合法，即场上可破坏的卡片数量必须大于等于解放的怪兽数量，且这些怪兽确实可以被解放。
function c88000953.fselect(g,tp)
	-- 检查场上是否存在至少与解放数量相同的、可被破坏的卡（排除被解放的怪兽组本身）。
	return Duel.IsExistingMatchingCard(c88000953.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,g:GetCount(),g,g)
		-- 验证选定的怪兽组是否全部可以被解放。
		and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
-- 效果②的Cost发动条件与处理函数，用于选择并解放所连接区的怪兽。
function c88000953.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 检查玩家场上是否存在至少1只可以解放的、位于所连接区且满足破坏条件的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c88000953.costfilter,1,nil,tp,lg) end
	-- 获取玩家场上所有可解放且位于所连接区的怪兽组。
	local rg=Duel.GetReleaseGroup(tp):Filter(c88000953.costfilter,nil,tp,lg)
	-- 提示玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c88000953.fselect,false,1,rg:GetCount(),tp)
	-- 消耗代替解放效果的次数（如暗黑世界-暗影敌托邦-等）。
	aux.UseExtraReleaseCount(sg,tp)
	-- 解放选定的怪兽作为发动Cost，并获取实际解放的数量。
	local ct=Duel.Release(sg,REASON_COST)
	e:SetLabel(ct)
end
-- 效果②的靶向/目标确认函数，设置破坏的操作信息。
function c88000953.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabel()
	-- 获取双方场上的所有卡片。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 设置当前连锁的操作信息，表明此效果将破坏场上与解放数量相同（ct张）的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 效果②的处理函数，选择并破坏与解放数量相同的场上的卡。
function c88000953.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 获取当前双方场上的所有卡片。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if g:GetCount()>=ct then
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=g:Select(tp,ct,ct,nil)
		-- 手动为被选择破坏的卡片显示被选为对象的动画效果。
		Duel.HintSelection(dg)
		-- 因效果破坏选定的卡片。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
