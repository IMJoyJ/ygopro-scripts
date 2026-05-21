--魔救の救砕
-- 效果：
-- ①：把自己场上的「魔救」怪兽任意数量解放，以那个数量＋1张的场上的卡为对象才能发动。那些卡破坏。
function c9341993.initial_effect(c)
	-- ①：把自己场上的「魔救」怪兽任意数量解放，以那个数量＋1张的场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c9341993.cost)
	e1:SetTarget(c9341993.target)
	e1:SetOperation(c9341993.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上（或因代替解放效果而可解放的对方场上表侧表示）的「魔救」怪兽
function c9341993.costfilter(c,tp)
	return c:IsSetCard(0x140) and (c:IsControler(tp) or c:IsFaceup())
end
-- 辅助选择函数：检查选定的解放怪兽数量与场上可选择的破坏对象数量是否匹配，并验证解放合法性
function c9341993.fselect(g,tp,exc)
	local dg=g:Clone()
	if exc then dg:AddCard(exc) end
	-- 检查场上是否存在解放数量+1张的、且不包含已被选为解放怪兽（及此卡自身）的卡片作为效果对象
	if Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,g:GetCount()+1,dg) then
		-- 将当前已选择的解放怪兽组设置到后续的解放检查中，以便配合 CheckReleaseGroup 进行验证
		Duel.SetSelectedCard(g)
		-- 检查这些被选中的怪兽是否满足可解放的规则条件
		return Duel.CheckReleaseGroup(tp,nil,0,nil)
	else return false end
end
-- 效果发动的代价处理函数，用于选择并解放任意数量的「魔救」怪兽
function c9341993.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	local exc=nil
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
	-- 获取玩家场上所有可解放的「魔救」怪兽
	local g=Duel.GetReleaseGroup(tp):Filter(c9341993.costfilter,nil,tp)
	if chk==0 then return g:CheckSubGroup(c9341993.fselect,1,g:GetCount(),tp,exc) end
	-- 给玩家发送提示信息，提示选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:SelectSubGroup(tp,c9341993.fselect,false,1,g:GetCount(),tp,exc)
	-- 适用类似「暗影敌托邦」等代替解放效果的次数限制
	aux.UseExtraReleaseCount(rg,tp)
	-- 解放选中的怪兽作为发动代价，并将实际解放的数量保存在Label中传递给target函数
	e:SetLabel(100,Duel.Release(rg,REASON_COST))
end
-- 效果的对象选择与发动准备函数
function c9341993.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local exc=nil
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
	local check,ct=e:GetLabel()
	if chkc then return chkc:IsOnField() end
	-- 检查在不考虑解放数量时，场上是否至少存在1张可作为对象的卡（用于基本发动条件的初步判定）
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc) end
	if check~=100 then ct=0 end
	e:SetLabel(0,0)
	-- 给玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择解放数量+1张的场上的卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct+1,ct+1,exc)
	-- 设置连锁信息，表明此效果的操作分类为破坏，并指定要破坏的对象卡片组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理（发动）函数，用于破坏作为对象的卡
function c9341993.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与此效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将这些对象卡片全部破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
