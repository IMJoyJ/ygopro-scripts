--覇王門無限
-- 效果：
-- ←13 【灵摆】 13→
-- ①：自己场上有怪兽存在的场合，自己不能灵摆召唤。这个效果不会被无效化。
-- ②：1回合1次，自己场上有「霸王龙 扎克」存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
-- 【怪兽效果】
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示卡为对象才能发动。那张卡和这张卡破坏，把1只龙族超量怪兽或者龙族灵摆怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，效果无效化，不能作为同调·超量召唤的素材。
-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c22211622.initial_effect(c)
	-- 记录这张卡上记载着「霸王龙 扎克」，用于相关卡名判定。
	aux.AddCodeList(c,13331639)
	-- 为这张卡添加灵摆怪兽属性，使其可作为灵摆卡在灵摆区域发动并参与灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上有怪兽存在的场合，自己不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTargetRange(1,0)
	e1:SetCondition(c22211622.splimcon)
	e1:SetTarget(c22211622.splimit)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上有「霸王龙 扎克」存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22211622,0))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c22211622.rccon)
	e2:SetTarget(c22211622.rctg)
	e2:SetOperation(c22211622.rcop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示卡为对象才能发动。那张卡和这张卡破坏，把1只龙族超量怪兽或者龙族灵摆怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，效果无效化，不能作为同调·超量召唤的素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22211622,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c22211622.sptg)
	e3:SetOperation(c22211622.spop)
	c:RegisterEffect(e3)
	-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(22211622,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c22211622.pencon)
	e4:SetTarget(c22211622.pentg)
	e4:SetOperation(c22211622.penop)
	c:RegisterEffect(e4)
end
-- 灵摆效果①的限制条件：判断效果持有者自己场上是否存在怪兽。
function c22211622.splimcon(e)
	-- 获取效果持有者自己场上怪兽区的怪兽数量并判断是否大于0。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>0
end
-- 作为「不能灵摆召唤」的限制目标判定：当召唤方式为灵摆召唤时返回真，禁止该次特殊召唤。
function c22211622.splimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤自己场上表侧表示且卡号为13331639的「霸王龙 扎克」。
function c22211622.rccfilter(c)
	return c:IsFaceup() and c:IsCode(13331639)
end
-- 效果②的发动条件：确认自己场上存在表侧表示的「霸王龙 扎克」。
function c22211622.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有满足rccfilter条件的卡存在（即表侧表示的「霸王龙 扎克」）。
	return Duel.IsExistingMatchingCard(c22211622.rccfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果②对象过滤器：对方场上表侧表示且攻击力大于0的怪兽。
function c22211622.rcfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 效果②的发动处理：选择对方场上一只表侧表示且攻击力大于0的怪兽为对象，并设置回复LP的操作信息。
function c22211622.rctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c22211622.rcfilter(chkc) end
	-- 效果发动时检查是否存在满足条件的对象（对方场上表侧表示且攻击力>0的怪兽）。
	if chk==0 then return Duel.IsExistingTarget(c22211622.rcfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从对方场上选择一只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c22211622.rcfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置回复LP的操作信息，回复数值为所选对象怪兽的攻击力。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
-- 效果②的解决：若本卡仍与效果关联且对象怪兽表侧表示并与效果关联，则回复对象攻击力数值的LP。
function c22211622.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 让发动者回复对象怪兽攻击力数值的基本分。
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
-- 怪兽效果①的对象过滤器：所选卡是自己场上表侧表示的卡（非本卡），且破坏后能从额外卡组特召符合条件的龙族超量/灵摆怪兽。
function c22211622.desfilter(c,e,tp,mc)
	-- 判定对象卡为表侧表示，且额外卡组存在可特殊召唤的龙族超量或灵摆怪兽。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c22211622.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,Group.FromCards(c,mc))
end
-- 特殊召唤候选过滤器：龙族且为超量或灵摆怪兽，并满足可特殊召唤及额外怪兽区空格条件。
function c22211622.spfilter(c,e,tp,dg)
	return c:IsType(TYPE_XYZ+TYPE_PENDULUM) and c:IsRace(RACE_DRAGON)
		-- 检查候选怪兽是否可被特殊召唤，并确认破坏本卡和对象卡后额外卡组怪兽有可用区域。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,dg,c)>0
end
-- 怪兽效果①的发动处理：选择这张卡以外的自己场上1张表侧表示卡为对象，并设置破坏2张卡和从额外卡组特殊召唤1只怪兽的操作信息。
function c22211622.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c22211622.desfilter(chkc,e,tp,c) and chkc~=c end
	-- 效果发动时检查是否存在符合条件的对象（自己场上表侧表示且能引出特召的卡）。
	if chk==0 then return Duel.IsExistingTarget(c22211622.desfilter,tp,LOCATION_ONFIELD,0,1,c,e,tp,c) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1张表侧表示卡作为对象（不能是本卡），并将本卡加入该对象组成破坏集合。
	local g=Duel.SelectTarget(tp,c22211622.desfilter,tp,LOCATION_ONFIELD,0,1,1,c,e,tp,c)
	g:AddCard(c)
	-- 设置破坏操作信息，确定要破坏的对象卡和本卡共2张。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置从额外卡组特殊召唤1只怪兽的操作信息，来源为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果①的解决：将对象卡和本卡同时破坏，若两张均破坏成功，从额外卡组选1只符合条件的龙族超量/灵摆怪兽特殊召唤，并附加攻击力·守备力为0、效果无效化、不能作为同调/超量素材的限制。
function c22211622.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象卡（这张卡以外的自己场上的表侧表示卡）。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local dg=Group.FromCards(c,tc)
	-- 同时破坏对象卡和这张卡，若实际破坏数量为2则继续处理特殊召唤。
	if Duel.Destroy(dg,REASON_EFFECT)==2 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足spfilter条件的龙族超量或灵摆怪兽。
		local g=Duel.SelectMatchingCard(tp,c22211622.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
		if g:GetCount()==0 then return end
		local sc=g:GetFirst()
		-- 将选择的怪兽以表侧表示进行特殊召唤（分步处理），若成功则继续附加限制效果。
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1,true)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e2,true)
			-- 这个效果特殊召唤的怪兽的攻击力·守备力变成0，不能作为同调·超量召唤的素材。②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK_FINAL)
			e3:SetValue(0)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e3,true)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
			sc:RegisterEffect(e4,true)
			local e5=e3:Clone()
			e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e5:SetValue(1)
			sc:RegisterEffect(e5,true)
			local e6=e5:Clone()
			e6:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			sc:RegisterEffect(e6,true)
		end
		-- 完成特殊召唤的连锁处理，触发特殊召唤成功时的时点。
		Duel.SpecialSummonComplete()
	end
end
-- 怪兽效果②的发动条件：这张卡被破坏前位于怪兽区域且表侧表示。
function c22211622.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果②的发动时点处理：检查自己的灵摆区域是否有空位可以放置这张卡。
function c22211622.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域左侧或右侧是否存在空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果②的处理：将这张卡移动到自己的灵摆区域。
function c22211622.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到自己的灵摆区域，并使其效果适用。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
