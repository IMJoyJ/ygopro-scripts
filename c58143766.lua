--ヴォルカニック・エミッション
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从卡组选1只「火山」怪兽加入手卡或无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
-- ●以场上1只炎族怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。以自己场上的怪兽为对象发动的场合，这个效果给与的伤害变成一半。
local s,id,o=GetID()
-- 初始化卡片效果：注册一个自由时点的魔法卡发动效果，并设定目标函数与效果处理函数
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选「火山」字段的怪兽，且能加入手卡或满足特殊召唤条件
function s.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x32) and (c:IsAbleToHand()
		-- 或者自己怪兽区有空位且该怪兽可以被无视召唤条件特殊召唤的场合也符合条件
		or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end
-- 过滤函数：筛选场上表侧表示、原本攻击力大于0的炎族怪兽；自己场上原本攻击力不足2的怪兽（伤害减半后为0）除外
function s.dfilter(c,tp)
	if c:IsControler(tp) and c:GetBaseAttack()<2 then return false end
	return c:IsFaceup() and c:GetBaseAttack()>0 and c:IsRace(RACE_PYRO)
end
-- 目标函数：分别检查两个选项本回合是否可选且条件满足，让玩家选择发动哪个效果，并设置对应的效果分类、取对象属性与操作信息
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.dfilter(chkc,tp) end
	-- 选项一的前提：本回合尚未选择过第一个效果（标识效果计数为0）
	local b1=(Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
		-- 且卡组中存在满足条件的「火山」怪兽，则选项一可用
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
	-- 选项二的前提：本回合尚未选择过第二个效果（标识效果计数为0）
	local b2=(Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
		-- 且双方场上存在可以作为效果对象的满足条件的炎族怪兽，则选项二可用
		and Duel.IsExistingTarget(s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})  --"加入手卡或特殊召唤/给与对方伤害"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(0)
			-- 注册标识效果记录本回合已选择第一个效果，结束阶段重置（实现1回合各能选择1次）
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：预计从卡组把1张卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		-- 设置操作信息：预计从卡组把1只怪兽特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DAMAGE)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
			-- 注册标识效果记录本回合已选择第二个效果，结束阶段重置（实现1回合各能选择1次）
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 提示玩家选择1张表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 以场上1只满足条件的炎族怪兽为对象并取得该卡
		local tc=Duel.SelectTarget(tp,s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp):GetFirst()
		local atk=tc:GetBaseAttack()
		if tc:IsControler(tp) then atk=atk//2 end
		-- 设置操作信息：预计给予对方atk点伤害（以自己场上的怪兽为对象时已预先减半）
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	end
end
-- 效果处理入口：根据发动时选择的选项，分别执行检索/特殊召唤处理（选项一）或伤害处理（选项二）
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		s.sop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.dop(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 第一个效果的处理：从卡组选1只满足条件的「火山」怪兽，由玩家选择加入手卡或无视召唤条件特殊召唤；特殊召唤成功的场合为其注册结束阶段回到手卡的持续效果
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选1只满足条件的「火山」怪兽
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	local b1=tc:IsAbleToHand()
	-- 选项二条件：自己怪兽区有空位且该怪兽可以无视召唤条件特殊召唤
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
	-- 让玩家选择把该怪兽加入手卡还是特殊召唤
	local op=aux.SelectFromOptions(tp,{b1,1190},{b2,1152})
	if op==1 then
		-- 把该怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方确认
		Duel.ConfirmCards(1-tp,tc)
	-- 否则把该怪兽无视召唤条件在自己场上表侧攻击表示特殊召唤，特殊召唤成功的场合执行后续处理
	elseif Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的怪兽在结束阶段回到手卡。给与对方那只怪兽的原本攻击力数值的伤害。以自己场上的怪兽为对象发动的场合，这个效果给与的伤害变成一半。
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
-- 结束阶段触发的处理函数：把该怪兽回到持有者的手卡
function s.ret(e,tp,eg,ep,ev,re,r,rp)
	-- 把该怪兽送去持有者的手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
-- 第二个效果的处理：取得对象怪兽，若其仍为表侧表示且与本效果相关联，则给与对方那只怪兽原本攻击力数值的伤害（对象在自己场上的场合减半）
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local d=1
		if tc:IsControler(tp) then d=2 end
		-- 给与对方等于该怪兽原本攻击力除以d的伤害（以自己场上的怪兽为对象时d为2，即伤害减半）
		Duel.Damage(1-tp,tc:GetBaseAttack()//d,REASON_EFFECT)
	end
end
