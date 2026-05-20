--ヴォルカニック・エミッション
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从卡组选1只「火山」怪兽加入手卡或无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
-- ●以场上1只炎族怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。以自己场上的怪兽为对象发动的场合，这个效果给与的伤害变成一半。
local s,id,o=GetID()
-- 定义卡片发动时的效果，设置为自由时点发动的魔法卡效果。
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
-- 过滤卡组中可以加入手卡或可以无视召唤条件特殊召唤的「火山」怪兽。
function s.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x32) and (c:IsAbleToHand()
		-- 检查自己场上是否有空怪兽区域，且该怪兽是否可以无视召唤条件特殊召唤。
		or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end
-- 过滤场上表侧表示、原本攻击力大于0且为炎族的怪兽（若为自己场上的怪兽，原本攻击力需大于等于2以确保减半后伤害不为0）。
function s.dfilter(c,tp)
	if c:IsControler(tp) and c:GetBaseAttack()<2 then return false end
	return c:IsFaceup() and c:GetBaseAttack()>0 and c:IsRace(RACE_PYRO)
end
-- 效果发动的准备与对象选择，根据玩家选择的分支设置对应的效果分类、对象和操作信息，并注册同名效果一回合一次的限制。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.dfilter(chkc,tp) end
	-- 检查本回合是否尚未选择过第一个效果（检索/特召）。
	local b1=(Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
		-- 检查卡组中是否存在满足条件的「火山」怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
	-- 检查本回合是否尚未选择过第二个效果（伤害）。
	local b2=(Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
		-- 检查场上是否存在可以作为对象的炎族怪兽。
		and Duel.IsExistingTarget(s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})  --"加入手卡或特殊召唤/给与对方伤害"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(0)
			-- 给玩家注册已使用第一个效果的标记，持续到回合结束。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息为：从卡组将1张卡加入手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		-- 设置操作信息为：从卡组将1只怪兽特殊召唤。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DAMAGE)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
			-- 给玩家注册已使用第二个效果的标记，持续到回合结束。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 提示玩家选择表侧表示的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 玩家选择场上1只表侧表示的炎族怪兽作为效果对象。
		local tc=Duel.SelectTarget(tp,s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp):GetFirst()
		local atk=tc:GetBaseAttack()
		if tc:IsControler(tp) then atk=atk//2 end
		-- 设置操作信息为：给与对方特定数值的伤害。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	end
end
-- 效果处理，根据发动时选择的分支（Label值）调用对应的处理函数。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		s.sop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.dop(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 第一个效果（检索/特召）的具体处理：从卡组选1只「火山」怪兽，由玩家选择加入手卡或特殊召唤，若特殊召唤则注册结束阶段回到手卡的效果。
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 玩家从卡组选择1只满足条件的「火山」怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	local b1=tc:IsAbleToHand()
	-- 检查当前是否可以特殊召唤该怪兽（有空怪兽区域且满足特召条件）。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
	-- 让玩家选择将该怪兽“加入手卡”或“特殊召唤”。
	local op=aux.SelectFromOptions(tp,{b1,1190},{b2,1152})
	if op==1 then
		-- 将选中的怪兽加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,tc)
	-- 无视召唤条件特殊召唤该怪兽，若特殊召唤成功则执行后续处理。
	elseif Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在结束阶段回到手卡。●以场上1只炎族怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。以自己场上的怪兽为对象发动的场合，这个效果给与的伤害变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetOperation(s.ret)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- 结束阶段使特殊召唤的怪兽回到手卡的效果处理函数。
function s.ret(e,tp,eg,ep,ev,re,r,rp)
	-- 将该怪兽送回持有者的手卡。
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
-- 第二个效果（伤害）的具体处理：给与对方作为对象的怪兽原本攻击力数值（若为自己场上的怪兽则为一半）的伤害。
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local d=1
		if tc:IsControler(tp) then d=2 end
		-- 给与对方玩家计算后的伤害数值。
		Duel.Damage(1-tp,tc:GetBaseAttack()//d,REASON_EFFECT)
	end
end
