--Concours de Cuisine～菓冷なる料理対決～
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡·卡组·额外卡组选1只「新式魔厨」灵摆怪兽和1只「圣菓使」灵摆怪兽在双方场上各1只特殊召唤。这个回合，自己不是「新式魔厨」怪兽以及「圣菓使」怪兽不能作为融合·同调·超量·连接召唤的素材。
-- ②：自己主要阶段把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升双方墓地的「食谱」卡数量×200。
local s,id,o=GetID()
-- 注册这张卡的①②两个效果：①为通常魔法发动效果，②为墓地起动效果。e1对应①特殊召唤，e2对应②攻击力上升。
function s.initial_effect(c)
	-- ①：从手卡·卡组·额外卡组选1只「新式魔厨」灵摆怪兽和1只「圣菓使」灵摆怪兽在双方场上各1只特殊召唤。这个回合，自己不是「新式魔厨」怪兽以及「圣菓使」怪兽不能作为融合·同调·超量·连接召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升双方墓地的「食谱」卡数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将墓地中的这张卡除外作为发动②的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 筛选同时满足以下条件的怪兽：属于「新式魔厨」（0x196）或「圣菓使」（0x19f）系列，且是灵摆怪兽。
function s.filter(c)
	return c:IsSetCard(0x196,0x19f) and c:IsType(TYPE_PENDULUM)
end
-- 判断候选怪兽c能否由自己特殊召唤到自己的场上，并在此前提下还能从同一批候选中找到另一只可以特殊召唤到对方场上的怪兽，组成一对组合。
function s.sfilter1(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若c不在额外卡组，则自己主要怪兽区必须存在可用的空格。
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 若c在额外卡组，则需要有足够的额外卡组特殊召唤区域空格（如额外怪兽区或允许从额外卡组特殊召唤的格子）。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
		and g:IsExists(s.sfilter2,1,c,e,tp,c)
end
-- 判断第二只怪兽c能否由自己特殊召唤到对方场上，且与已选定的oc组成一个“新式魔厨”+“圣菓使”的配对。
function s.sfilter2(c,e,tp,oc)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
		-- 若c不在额外卡组，则对方主要怪兽区需要存在可用空格（以tp视角检查对方场上的空格，考虑格子限制）。
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
			-- 若c在额外卡组，则需要对方场上有可供额外卡组怪兽特殊召唤的空位。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(1-tp,tp,nil,c)>0)
		-- 检查组内两张卡正好分属两个系列：一张是「新式魔厨」（0x196），另一张是「圣菓使」（0x19f）。
		and aux.gfcheck(Group.FromCards(c,oc),Card.IsSetCard,0x196,0x19f)
end
-- ①效果的发动条件：自己场上没有【青眼精灵龙】的“不能同时特殊召唤2只以上怪兽”效果影响，且存在一组符合条件的两只灵摆怪兽可供选择。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从手卡、卡组、额外卡组中获取所有满足s.filter条件的灵摆怪兽（即「新式魔厨」或「圣菓使」灵摆怪兽）。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND,0,nil)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and g:IsExists(s.sfilter1,1,nil,e,tp,g) end
	-- 设置操作信息：本次效果将特殊召唤2只怪兽，来源可能为双方的手卡、卡组、额外卡组；具体卡片在处理时选择，因此targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND)
end
-- ①效果处理：选择两只符合条件的灵摆怪兽，分别以表侧表示特殊召唤到自己和对方场上；然后给双方场上施加自肃，使非「新式魔厨」「圣菓使」怪兽不能作为融合·同调·超量·连接召唤的素材。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取当前符合条件的候选怪兽组（因为之前选择时状态可能已变化）。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND,0,nil)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133) and g:IsExists(s.sfilter1,1,nil,e,tp,g) then
		-- 向玩家显示选择提示，要求选择要在自己场上特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要在自己场上特殊召唤的怪兽"
		local sc=g:FilterSelect(tp,s.sfilter1,1,1,nil,e,tp,g):GetFirst()
		-- 向玩家显示选择提示，要求选择要在对方场上特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择要在对方场上特殊召唤的怪兽"
		local oc=g:FilterSelect(tp,s.sfilter2,1,1,sc,e,tp,sc):GetFirst()
		-- 将第一张选中的怪兽以表侧表示特殊召唤到自己场上（作为同时特殊召唤流程中的一步）。
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		-- 将第二张选中的怪兽以表侧表示特殊召唤到对方场上（作为同时特殊召唤流程中的一步）。
		Duel.SpecialSummonStep(oc,0,tp,1-tp,false,false,POS_FACEUP)
		-- 结束同时特殊召唤流程，触发召唤成功时点。
		Duel.SpecialSummonComplete()
	end
	local c=e:GetHandler()
	-- 这个回合，自己不是「新式魔厨」怪兽以及「圣菓使」怪兽不能作为融合·同调·超量·连接召唤的素材。②：自己主要阶段把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升双方墓地的「食谱」卡数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置自肃影响的对象：不是「新式魔厨」（0x196）也不是「圣菓使」（0x19f）系列的怪兽（即这些怪兽不能作为素材）。
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsSetCard),0x196,0x19f))
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(s.fuslimit)
	-- 将融合素材限制效果注册到全场，使非指定系列怪兽不能作为融合素材。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetValue(s.sumlimit)
	-- 将同调素材限制效果注册到全场，使非指定系列怪兽不能作为同调素材。
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	-- 将超量素材限制效果注册到全场，使非指定系列怪兽不能作为超量素材。
	Duel.RegisterEffect(e3,tp)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	-- 将连接素材限制效果注册到全场，使非指定系列怪兽不能作为连接素材。
	Duel.RegisterEffect(e4,tp)
end
-- 判定融合素材限制的具体条件：该怪兽的控制者是效果发动者，且召唤方式是融合召唤时才限制。
function s.fuslimit(e,c,sumtype)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer()) and sumtype==SUMMON_TYPE_FUSION
end
-- 判定同调/超量/连接素材限制的具体条件：只要该怪兽的控制者是效果发动者就限制（不区分召唤方式）。
function s.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
-- ②效果的发动条件：自己墓地存在「食谱」系列卡，且场上有表侧表示怪兽可以成为对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否存在至少1张「食谱」系列卡（0x197）在双方墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,0x197)
		-- 检查场上是否存在至少1只表侧表示怪兽可以作为效果对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，要求玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为攻击力上升效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理：统计双方墓地的「食谱」卡数量，为对象怪兽赋予攻击力上升效果。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 统计双方墓地为「食谱」系列（0x197）的卡的数量。
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,0x197)
	-- 取得通过Duel.SelectTarget选中的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力上升双方墓地的「食谱」卡数量×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ct*200)
		tc:RegisterEffect(e1)
	end
end
