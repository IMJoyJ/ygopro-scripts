--サラマングレイト・レイジ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从手卡以及自己场上的表侧表示怪兽之中把1只「转生炎兽」怪兽送去墓地，以场上1张卡为对象才能发动。那张卡破坏。
-- ●以用和自身同名的怪兽为素材作连接召唤的自己场上1只「转生炎兽」连接怪兽为对象才能发动。选最多有那只怪兽的连接标记数量的对方场上的卡破坏。
function c14934922.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。
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
		-- ●从手卡以及自己场上的表侧表示怪兽之中把1只「转生炎兽」怪兽送去墓地，以场上1张卡为对象才能发动。那张卡破坏。●以用和自身同名的怪兽为素材作连接召唤的自己场上1只「转生炎兽」连接怪兽为对象才能发动。选最多有那只怪兽的连接标记数量的对方场上的卡破坏。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c14934922.valcheck)
		-- 将全局的素材检查效果注册到决斗中，使所有连接召唤时都触发valcheck，用于标记“用和自身同名的怪兽为素材作连接召唤”的转生炎兽连接怪兽。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查怪兽连接召唤时的素材中是否存在与自身同名的怪兽，存在则为该连接怪兽注册flag标记，作为第二个效果可选对象的判定依据。
function c14934922.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,c:GetCode()) then
		c:RegisterFlagEffect(14934922,RESET_EVENT+0x4fe0000,0,1)
	end
end
-- 判定一张卡是否能作为第一个效果的代价：是「转生炎兽」怪兽，且在手牌或表侧表示，可送墓，并且场上存在除该卡和目标怪兽以外的可破坏对象。
function c14934922.costfilter(c,mc,tp)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
		-- 确认场上存在至少1张可以被选择为破坏对象的卡（排除候选代价卡和指定对象），保证第一个效果发动时有合法对象。
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,mc))
end
-- 判定怪兽是否为表侧表示的「转生炎兽」连接怪兽、以连接召唤出场，并带有素材同名检测的flag标记，用于第二个效果选择对象。
function c14934922.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(14934922)~=0
end
-- 处理取对象时的合法性检查：若选择第一个选项，则以场上任意卡为对象（不能是效果发动者）；若选择第二个选项，则以自己场上符合filter的连接怪兽为对象。
function c14934922.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==0 and chkc:IsOnField() and chkc~=e:GetHandler()
		or e:GetLabel()==1 and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14934922.filter(chkc) end
	-- 检查是否存在满足costfilter条件的「转生炎兽」怪兽，用于判断第一个选项是否可发动。
	local b1=Duel.IsExistingMatchingCard(c14934922.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e:GetHandler(),tp)
	-- 检查自己场上是否存在满足filter条件的「转生炎兽」连接怪兽，用于判断第二个选项是否可发动。
	local b2=Duel.IsExistingTarget(c14934922.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1张卡，作为第二个效果可破坏的对象，确保第二个选项可发动。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个选项都满足时，让玩家从“破坏1张卡”和“破坏连接标记数量的卡”中选择一个，op记录选项序号。
		op=Duel.SelectOption(tp,aux.Stringid(14934922,0),aux.Stringid(14934922,1))  --"破坏1张卡/破坏连接标记数量的卡"
	elseif b1 then
		-- 仅第一个选项满足时，让玩家选择“破坏1张卡”，op为0。
		op=Duel.SelectOption(tp,aux.Stringid(14934922,0))  --"破坏1张卡"
	else
		-- 仅第二个选项满足时，让玩家选择“破坏连接标记数量的卡”，op为1。
		op=Duel.SelectOption(tp,aux.Stringid(14934922,1))+1  --"破坏连接标记数量的卡"
	end
	e:SetLabel(op)
	if op==0 then
		-- 提示玩家选择要送去墓地的「转生炎兽」怪兽作为代价。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从手牌和自己场上的表侧表示怪兽中选1只满足costfilter的「转生炎兽」怪兽作为代价。
		local g=Duel.SelectMatchingCard(tp,c14934922.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e:GetHandler(),tp)
		-- 将选中的代价怪兽送去墓地，完成第一个效果的发动代价。
		Duel.SendtoGrave(g,REASON_COST)
		-- 提示玩家选择第一个效果要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上1张卡（不能是效果发动者自身）作为第一个效果的破坏对象，并登记为效果对象。
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
		-- 登记第一个效果将破坏1张卡的操作信息，供其他卡连锁时参考。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		-- 提示玩家选择表侧表示的「转生炎兽」连接怪兽作为第二个效果的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择自己场上1只满足filter条件的「转生炎兽」连接怪兽作为第二个效果的对象，并登记为效果对象。
		Duel.SelectTarget(tp,c14934922.filter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 获取对方场上的全部卡，作为第二个效果可能破坏的候选集合，用于操作信息登记。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		-- 登记第二个效果将破坏对方场上卡的操作信息（处理时实际选择最多连接标记数量张）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理：若选择了选项0，则破坏之前选定的那张卡；若选择了选项1，则从对方场上选最多为对象连接标记数量的卡破坏。
function c14934922.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取第一个效果发动时选择的对象卡。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 用效果破坏第一个效果选择的对象卡。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		-- 获取第二个效果发动时所选择的「转生炎兽」连接怪兽。
		local tc=Duel.GetFirstTarget()
		if not tc:IsRelateToEffect(e) then return end
		-- 提示玩家选择要破坏的对方场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1到对象怪兽连接标记数量张卡作为破坏对象。
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,tc:GetLink(),nil)
		if g:GetCount()>0 then
			-- 手动显示选中的破坏对象动画，并将这些卡登记为广义的选为对象。
			Duel.HintSelection(g)
			-- 用效果破坏选中的对方场上的所有卡。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
