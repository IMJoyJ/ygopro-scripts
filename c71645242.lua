--ブラック・ガーデン
-- 效果：
-- ①：每次「黑色花园」的效果以外让怪兽表侧表示召唤·特殊召唤发动。那些怪兽的攻击力变成一半。那之后，那控制者在对方场上把1只「蔷薇衍生物」（植物族·暗·2星·攻/守800）攻击表示特殊召唤。
-- ②：以持有和场上的全部植物族怪兽的攻击力合计相同攻击力的自己墓地1只怪兽为对象才能发动。这张卡以及场上的植物族怪兽全部破坏。全部破坏的场合，再把作为对象的怪兽特殊召唤。
function c71645242.initial_effect(c)
	-- 在卡片关联代码列表中添加自身卡名，用于支持相关卡片效果的检索或判定。
	aux.AddCodeList(c,71645242)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次「黑色花园」的效果以外让怪兽表侧表示召唤·特殊召唤发动。那些怪兽的攻击力变成一半。那之后，那控制者在对方场上把1只「蔷薇衍生物」（植物族·暗·2星·攻/守800）攻击表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(71645242,0))  --"攻击减半，特殊召唤衍生物"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_CUSTOM+71645242)
	e4:SetTarget(c71645242.sptg)
	e4:SetOperation(c71645242.spop)
	c:RegisterEffect(e4)
	-- ②：以持有和场上的全部植物族怪兽的攻击力合计相同攻击力的自己墓地1只怪兽为对象才能发动。这张卡以及场上的植物族怪兽全部破坏。全部破坏的场合，再把作为对象的怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(71645242,1))  --"特殊召唤"
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTarget(c71645242.sptg2)
	e5:SetOperation(c71645242.spop2)
	c:RegisterEffect(e5)
	if not c71645242.global_check then
		c71645242.global_check=true
		-- ①：每次「黑色花园」的效果以外让怪兽表侧表示召唤·特殊召唤发动。那些怪兽的攻击力变成一半。那之后，那控制者在对方场上把1只「蔷薇衍生物」（植物族·暗·2星·攻/守800）攻击表示特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetCondition(c71645242.regcon)
		ge1:SetOperation(c71645242.regop)
		-- 在全局注册一个用于监听怪兽通常召唤成功事件的永续效果。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 在全局注册一个用于监听怪兽特殊召唤成功事件的永续效果。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 过滤出由指定玩家表侧表示召唤或特殊召唤，且不是由「黑色花园」的效果召唤的怪兽。
function c71645242.cfilter(c,tp)
	local code,code2=c:GetSpecialSummonInfo(SUMMON_INFO_CODE,SUMMON_INFO_CODE2)
	return c:IsFaceup() and c:IsControler(tp) and code~=71645242 and code2~=71645242
end
-- 检查是否有满足条件的怪兽被召唤或特殊召唤，并记录召唤玩家的标识。
function c71645242.regcon(e,tp,eg,ep,ev,re,r,rp)
	local sf=0
	if eg:IsExists(c71645242.cfilter,1,nil,0) then
		sf=sf+1
	end
	if eg:IsExists(c71645242.cfilter,1,nil,1) then
		sf=sf+2
	end
	e:SetLabel(sf)
	return sf~=0
end
-- 触发自定义事件，将召唤的怪兽信息和召唤玩家标识传递给黑色花园的效果。
function c71645242.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，通知场上的「黑色花园」发动效果。
	Duel.RaiseEvent(eg,EVENT_CUSTOM+71645242,e,r,rp,ep,e:GetLabel())
end
-- 攻击力减半及特殊召唤衍生物效果的靶向与操作信息设置函数。
function c71645242.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次召唤的怪兽群设为当前效果的处理对象。
	Duel.SetTargetCard(eg)
	-- 设置操作信息，表明该效果包含产生衍生物的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表明该效果包含特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 过滤出仍在怪兽区域、与效果相关且不受该效果免疫的怪兽。
function c71645242.opfilter(c,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
-- 攻击力减半及特殊召唤衍生物效果的具体执行函数。
function c71645242.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c71645242.opfilter,nil,e)
	if g:GetCount()==0 then return end
	local tc=g:GetFirst()
	while tc do
		if tc:IsFaceup() then
			-- 那些怪兽的攻击力变成一半。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(math.ceil(tc:GetAttack()/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
	-- 中断当前效果处理，使后续的特殊召唤衍生物处理与攻击力减半不视为同时进行。
	Duel.BreakEffect()
	-- 如果玩家tp召唤了怪兽，且对方场上有可用的怪兽区域。
	if bit.extract(ev,tp)~=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 且判定玩家tp是否可以在对方场上特殊召唤「蔷薇衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,71645243,0,TYPES_TOKEN_MONSTER,800,800,2,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,1-tp) then
		-- 由玩家tp创建「蔷薇衍生物」的卡片数据。
		local token=Duel.CreateToken(tp,71645243)
		-- 将「蔷薇衍生物」以表侧攻击表示特殊召唤到对方场上。
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	end
	-- 如果对方玩家召唤了怪兽，且自己场上有可用的怪兽区域。
	if bit.extract(ev,1-tp)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE,1-tp)>0
		-- 且判定对方玩家是否可以在自己场上特殊召唤「蔷薇衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(1-tp,71645243,0,TYPES_TOKEN_MONSTER,800,800,2,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) then
		-- 由对方玩家创建「蔷薇衍生物」的卡片数据。
		local token=Duel.CreateToken(1-tp,71645243)
		-- 将「蔷薇衍生物」以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummonStep(token,0,1-tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	-- 完成所有单步特殊召唤的处理，使衍生物正式出场。
	Duel.SpecialSummonComplete()
end
-- 过滤场上表侧表示的植物族怪兽。
function c71645242.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 过滤自己墓地中攻击力等于指定数值且可以特殊召唤的怪兽。
function c71645242.filter2(c,atk,e,tp)
	return c:IsAttack(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 破坏场上植物族怪兽及自身并特殊召唤墓地怪兽效果的靶向与操作信息设置函数。
function c71645242.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c71645242.filter2(chkc,e:GetLabel(),e,tp) end
	-- 获取场上所有的表侧表示植物族怪兽。
	local g=Duel.GetMatchingGroup(c71645242.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local atk=g:GetSum(Card.GetAttack)
	local sc=g:FilterCount(Card.IsControler,nil,tp)
	if chk==0 then return g:GetCount()>0
		-- 确保在自己场上的植物族怪兽被破坏后，自己场上有可用的怪兽区域用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-sc
		-- 且自己墓地存在可以作为特殊召唤对象的、攻击力等于场上植物族怪兽攻击力合计的怪兽。
		and Duel.IsExistingTarget(c71645242.filter2,tp,LOCATION_GRAVE,0,1,nil,atk,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只满足攻击力条件的怪兽作为效果的对象。
	local tg=Duel.SelectTarget(tp,c71645242.filter2,tp,LOCATION_GRAVE,0,1,1,nil,atk,e,tp)
	e:SetLabel(atk)
	-- 设置操作信息，表明该效果包含特殊召唤该墓地怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,0,0)
	g:AddCard(e:GetHandler())
	-- 设置操作信息，表明该效果包含破坏这张卡以及场上所有植物族怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏场上植物族怪兽及自身并特殊召唤墓地怪兽效果的具体执行函数。
function c71645242.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 重新获取场上所有的表侧表示植物族怪兽。
	local dg=Duel.GetMatchingGroup(c71645242.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	dg:AddCard(c)
	-- 破坏这张卡以及场上的植物族怪兽，并检查是否全部成功破坏。
	if Duel.Destroy(dg,REASON_EFFECT)==dg:GetCount() then
		-- 获取作为特殊召唤对象的墓地怪兽。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将作为对象的怪兽在自己场上表侧表示特殊召唤。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
