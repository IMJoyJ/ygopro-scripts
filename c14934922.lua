--サラマングレイト・レイジ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从手卡以及自己场上的表侧表示怪兽之中把1只「转生炎兽」怪兽送去墓地，以场上1张卡为对象才能发动。那张卡破坏。
-- ●以用和自身同名的怪兽为素材作连接召唤的自己场上1只「转生炎兽」连接怪兽为对象才能发动。选最多有那只怪兽的连接标记数量的对方场上的卡破坏。
function c14934922.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,14934922+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c14934922.target)
	e1:SetOperation(c14934922.activate)
	c:RegisterEffect(e1)
	if not c14934922.global_check then
		c14934922.global_check=true
		-- 效果原文内容：①：可以从以下效果选择1个发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c14934922.valcheck)
		-- 将效果注册给全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查素材是否包含同名连接怪兽的函数
function c14934922.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,c:GetCode()) then
		c:RegisterFlagEffect(14934922,RESET_EVENT+0x4fe0000,0,1)
	end
end
-- 过滤手牌或场上「转生炎兽」怪兽作为破坏对象的函数
function c14934922.costfilter(c,mc,tp)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
		-- 检查所选怪兽是否能成为效果对象
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,mc))
end
-- 过滤自己场上的「转生炎兽」连接怪兽的函数
function c14934922.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(14934922)~=0
end
-- 处理效果选择和目标选择的函数
function c14934922.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==0 and chkc:IsOnField() and chkc~=e:GetHandler()
		or e:GetLabel()==1 and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14934922.filter(chkc) end
	-- 检查是否存在满足条件的「转生炎兽」怪兽用于破坏
	local b1=Duel.IsExistingMatchingCard(c14934922.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e:GetHandler(),tp)
	-- 检查是否存在满足条件的「转生炎兽」连接怪兽
	local b2=Duel.IsExistingTarget(c14934922.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1张卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 选择第一个效果：从手卡或场上送去墓地破坏1张卡
		op=Duel.SelectOption(tp,aux.Stringid(14934922,0),aux.Stringid(14934922,1))  --"破坏1张卡" / "破坏连接标记数量的卡"
	elseif b1 then
		-- 选择第一个效果：从手卡或场上送去墓地破坏1张卡
		op=Duel.SelectOption(tp,aux.Stringid(14934922,0))  --"破坏1张卡"
	else
		-- 选择第二个效果：破坏对方场上最多连接标记数量的卡
		op=Duel.SelectOption(tp,aux.Stringid(14934922,1))+1  --"破坏连接标记数量的卡"
	end
	e:SetLabel(op)
	if op==0 then
		-- 提示玩家选择要送去墓地的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		-- 选择满足条件的「转生炎兽」怪兽送去墓地
		local g=Duel.SelectMatchingCard(tp,c14934922.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e:GetHandler(),tp)
		-- 将选中的怪兽送去墓地作为费用
		Duel.SendtoGrave(g,REASON_COST)
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		-- 选择场上1张卡作为破坏对象
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
		-- 设置破坏操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		-- 提示玩家选择要破坏的连接怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		-- 选择自己场上的「转生炎兽」连接怪兽
		Duel.SelectTarget(tp,c14934922.filter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 获取对方场上的所有卡
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		-- 设置破坏操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 处理效果发动后的操作
function c14934922.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取当前连锁的目标卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 破坏目标卡
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		-- 获取当前连锁的目标卡
		local tc=Duel.GetFirstTarget()
		if not tc:IsRelateToEffect(e) then return end
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		-- 选择对方场上的最多连接标记数量的卡
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,tc:GetLink(),nil)
		if g:GetCount()>0 then
			-- 显示选中的卡被选为对象的动画
			Duel.HintSelection(g)
			-- 破坏选中的卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
