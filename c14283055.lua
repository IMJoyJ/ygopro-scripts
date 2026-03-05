--Concours de Cuisine～菓冷なる料理対決～
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡·卡组·额外卡组选1只「新式魔厨」灵摆怪兽和1只「圣菓使」灵摆怪兽在双方场上各1只特殊召唤。这个回合，自己不是「新式魔厨」怪兽以及「圣菓使」怪兽不能作为融合·同调·超量·连接召唤的素材。
-- ②：自己主要阶段把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升双方墓地的「食谱」卡数量×200。
local s,id,o=GetID()
-- 初始化卡片效果函数
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
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 筛选符合条件的灵摆怪兽
function s.filter(c)
	return c:IsSetCard(0x196,0x19f) and c:IsType(TYPE_PENDULUM)
end
-- 检查是否可以特殊召唤并满足条件的「新式魔厨」灵摆怪兽
function s.sfilter1(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查目标怪兽是否在主要怪兽区且有空位
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查目标怪兽是否在额外卡组且有空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
		and g:IsExists(s.sfilter2,1,c,e,tp,c)
end
-- 检查是否可以特殊召唤并满足条件的「圣菓使」灵摆怪兽
function s.sfilter2(c,e,tp,oc)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
		-- 检查目标怪兽是否在主要怪兽区且有空位
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
			-- 检查目标怪兽是否在额外卡组且有空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(1-tp,tp,nil,c)>0)
		-- 检查两张怪兽是否分别属于不同派系
		and aux.gfcheck(Group.FromCards(c,oc),Card.IsSetCard,0x196,0x19f)
end
-- 设置效果目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取符合条件的灵摆怪兽组
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND,0,nil)
	-- 检查是否满足发动条件
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and g:IsExists(s.sfilter1,1,nil,e,tp,g) end
	-- 设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND)
end
-- 发动效果的处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取符合条件的灵摆怪兽组
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND,0,nil)
	-- 检查是否满足发动条件
	if not Duel.IsPlayerAffectedByEffect(tp,59822133) and g:IsExists(s.sfilter1,1,nil,e,tp,g) then
		-- 提示选择「新式魔厨」灵摆怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local sc=g:FilterSelect(tp,s.sfilter1,1,1,nil,e,tp,g):GetFirst()
		-- 提示选择「圣菓使」灵摆怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local oc=g:FilterSelect(tp,s.sfilter2,1,1,sc,e,tp,sc):GetFirst()
		-- 将「新式魔厨」灵摆怪兽特殊召唤
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		-- 将「圣菓使」灵摆怪兽特殊召唤
		Duel.SpecialSummonStep(oc,0,tp,1-tp,false,false,POS_FACEUP)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
	local c=e:GetHandler()
	-- 设置不能作为融合·同调·超量·连接召唤素材的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置目标为非「新式魔厨」和「圣菓使」怪兽
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsSetCard),0x196,0x19f))
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(s.fuslimit)
	-- 注册融合素材限制效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetValue(s.sumlimit)
	-- 注册同调素材限制效果
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	-- 注册超量素材限制效果
	Duel.RegisterEffect(e3,tp)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	-- 注册连接素材限制效果
	Duel.RegisterEffect(e4,tp)
end
-- 融合素材限制判断函数
function s.fuslimit(e,c,sumtype)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer()) and sumtype==SUMMON_TYPE_FUSION
end
-- 同调素材限制判断函数
function s.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
-- 设置攻击力上升效果的目标
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否有「食谱」卡在墓地
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,0x197)
		-- 检查场上是否有表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择场上表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择场上表侧表示怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理攻击力上升效果
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算墓地「食谱」卡数量
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,0x197)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 设置攻击力上升效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ct*200)
		tc:RegisterEffect(e1)
	end
end
