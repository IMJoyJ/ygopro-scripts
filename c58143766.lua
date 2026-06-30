--ヴォルカニック・エミッション
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从卡组选1只「火山」怪兽加入手卡或无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
-- ●以场上1只炎族怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。以自己场上的怪兽为对象发动的场合，这个效果给与的伤害变成一半。
local s,id,o=GetID()
-- 卡片激活效果的初始化注册
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。 ●从卡组选1只「火山」怪兽加入手卡或无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。 ●以场上1只炎族怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。以自己场上的怪兽为对象发动的场合，这个效果给与的伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
-- 卡组中「火山」怪兽的过滤条件
function s.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x32) and (c:IsAbleToHand()
		-- 检查是否可以无视召唤条件特殊召唤该怪兽
		or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end
-- 场上可选择作为对象的炎族怪兽过滤条件
function s.dfilter(c,tp)
	if c:IsControler(tp) and c:GetBaseAttack()<2 then return false end
	return c:IsFaceup() and c:GetBaseAttack()>0 and c:IsRace(RACE_PYRO)
end
-- 卡片发动的靶向/基本发动条件检测与效果分支选择
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.dfilter(chkc,tp) end
	-- 判断第一个效果是否可以发动（检测是否已使用以及是否有可用卡片）
	local b1=(Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
		-- 检查卡组中是否存在可检索或特殊召唤的「火山」怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
	-- 判断第二个效果是否可以发动（检测是否已使用以及场上是否有符合条件的对象）
	local b2=(Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
		-- 检查场上是否存在可以作为对象的炎族怪兽
		and Duel.IsExistingTarget(s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})  --"加入手卡或特殊召唤/给与对方伤害"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(0)
			-- 给玩家注册第一个效果本回合已使用的标记
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置“卡组检索加入手卡”的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		-- 设置“卡组特殊召唤怪兽”的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DAMAGE)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
			-- 给玩家注册第二个效果本回合已使用的标记
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 提示玩家选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择场上1只表侧表示的炎族怪兽作为效果的对象
		local tc=Duel.SelectTarget(tp,s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp):GetFirst()
		local atk=tc:GetBaseAttack()
		if tc:IsControler(tp) then atk=atk//2 end
		-- 设置“给与对方生命值伤害”的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	end
end
-- 卡片激活效果的执行分支选择
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		s.sop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.dop(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 第一个效果（检索或特殊召唤）的执行函数
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1只符合条件的「火山」怪兽
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	local b1=tc:IsAbleToHand()
	-- 判断是否满足特殊召唤的条件（怪兽区域空位及特殊召唤可行性）
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
	-- 让玩家选择将该卡“加入手卡”或“特殊召唤”
	local op=aux.SelectFromOptions(tp,{b1,1190},{b2,1152})
	if op==1 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	-- 无视召唤条件将选中的卡特殊召唤，并检查是否成功
	elseif Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的怪兽在结束阶段回到手卡。
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
-- 特殊召唤怪兽在结束阶段回到手卡的效果执行函数
function s.ret(e,tp,eg,ep,ev,re,r,rp)
	-- 将特殊召唤的怪兽送回持有者的手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
-- 第二个效果（原本攻击力伤害）的执行函数
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的炎族怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local d=1
		if tc:IsControler(tp) then d=2 end
		-- 给与对方那只怪兽的原本攻击力数值的伤害。以自己场上的怪兽为对象发动的场合，这个效果给与的伤害变成一半。
		Duel.Damage(1-tp,tc:GetBaseAttack()//d,REASON_EFFECT)
	end
end
