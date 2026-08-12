--Emボール・ライダー
-- 效果：
-- ←3 【灵摆】 3→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己的额外卡组（表侧）把1只「娱乐法师」灵摆怪兽送去墓地。那之后，可以让这张卡的灵摆刻度上升送去墓地的怪兽的灵摆刻度数值。
-- 【怪兽效果】
-- 这个卡名的①②③的怪兽效果1回合各能使用1次。
-- ①：自己场上有「娱乐法师」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，可以从以下效果选择1个发动。
-- ●从卡组把1只「娱乐法师」灵摆怪兽表侧加入额外卡组。
-- ●自己场上1张「娱乐法师」怪兽卡破坏。
-- ③：特殊召唤的对方怪兽的直接攻击宣言时才能发动。这张卡从墓地特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含灵摆效果、手卡特召效果、召唤·特召成功时选择发动的效果、以及墓地特召效果。
function s.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动等基本属性。
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。从自己的额外卡组（表侧）把1只「娱乐法师」灵摆怪兽送去墓地。那之后，可以让这张卡的灵摆刻度上升送去墓地的怪兽的灵摆刻度数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从额外卡组送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)
	-- ①：自己场上有「娱乐法师」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤·特殊召唤的场合，可以从以下效果选择1个发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"发动效果"
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ③：特殊召唤的对方怪兽的直接攻击宣言时才能发动。这张卡从墓地特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))  --"从墓地特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id+o*3)
	e5:SetCondition(s.spcon2)
	e5:SetTarget(s.sptg2)
	e5:SetOperation(s.spop2)
	c:RegisterEffect(e5)
end
-- 过滤条件：额外卡组表侧表示、属于「娱乐法师」且是灵摆怪兽、可以送去墓地、且灵摆刻度大于0。
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc6) and c:IsType(TYPE_PENDULUM) and c:IsAbleToGrave()
		and c:GetLeftScale()>0
end
-- 灵摆效果的发动准备与合法性检查，并设置送去墓地的操作信息。
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在至少1只满足条件的「娱乐法师」灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁处理的操作信息，表示此效果会从额外卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 灵摆效果的执行逻辑：将额外卡组的「娱乐法师」灵摆怪兽送去墓地，并可选择让这张卡的灵摆刻度上升该怪兽的刻度数值。
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己额外卡组选择1只满足条件的「娱乐法师」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	-- 检查是否成功将选中的怪兽因效果送去墓地且该怪兽目前存在于墓地。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 询问玩家是否选择发动“让这张卡的灵摆刻度上升”的效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,8)) then  --"是否上升灵摆刻度？"
		-- 中断当前效果处理，使后续的灵摆刻度上升处理与送去墓地不视为同时处理。
		Duel.BreakEffect()
		local ct=tc:GetLeftScale()
		-- 可以让这张卡的灵摆刻度上升送去墓地的怪兽的灵摆刻度数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		c:RegisterEffect(e2)
	end
end
-- 过滤条件：场上表侧表示的「娱乐法师」怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc6)
end
-- 怪兽效果①的特殊召唤发动条件：自己场上有「娱乐法师」怪兽存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「娱乐法师」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 怪兽效果①的发动准备与合法性检查，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示此效果会将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 怪兽效果①的执行逻辑：将自身从手卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：属于「娱乐法师」且是灵摆怪兽，并且可以加入额外卡组。
function s.schfilter(c)
	return c:IsSetCard(0xc6) and c:IsType(TYPE_PENDULUM) and c:IsAbleToExtra()
end
-- 过滤条件：自己场上表侧表示的「娱乐法师」怪兽卡（包含原本是怪兽的卡）。
function s.desfilter(c)
	return c:IsSetCard(0xc6) and c:IsFaceup() and bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER
end
-- 怪兽效果②的发动准备与分支选择，根据场上和卡组状态决定可选的分支，并让玩家选择其中一个效果发动。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local sel=0
		-- 检查卡组中是否存在可以加入额外卡组的「娱乐法师」灵摆怪兽，若有则标记分支1可用。
		if Duel.IsExistingMatchingCard(s.schfilter,tp,LOCATION_DECK,0,1,nil) then sel=sel+1 end
		-- 检查自己场上是否存在可以破坏的「娱乐法师」怪兽卡，若有则标记分支2可用。
		if Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil) then sel=sel+2 end
		e:SetLabel(sel)
		return sel~=0
	end
	local sel=e:GetLabel()
	if sel==3 then
		-- 提示玩家选择要发动的效果分支。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))  --"选择1个效果"
		-- 让玩家在“加入额外卡组”和“破坏效果”两个选项中选择一个。
		sel=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))+1  --"加入额外卡组/破坏效果"
	elseif sel==1 then
		-- 仅有“加入额外卡组”效果满足条件时，自动选择该效果。
		Duel.SelectOption(tp,aux.Stringid(id,5))  --"加入额外卡组"
	elseif sel==2 then
		-- 仅有“破坏效果”满足条件时，自动选择该效果。
		Duel.SelectOption(tp,aux.Stringid(id,6))  --"破坏效果"
	end
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_TOEXTRA)
		-- 设置连锁处理的操作信息，表示此效果会从卡组将1张卡表侧加入额外卡组。
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
	elseif sel==2 then
		-- 获取自己场上所有满足条件的「娱乐法师」怪兽卡。
		local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,nil)
		e:SetCategory(CATEGORY_DESTROY)
		-- 设置连锁处理的操作信息，表示此效果会破坏场上的1张卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 怪兽效果②的执行逻辑：根据玩家选择的分支，执行“将卡组的「娱乐法师」灵摆怪兽表侧加入额外卡组”或“破坏自己场上1张「娱乐法师」怪兽卡”。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
		-- 提示玩家选择要加入额外卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,7))  --"请选择要加入额外卡组的卡"
		-- 让玩家从卡组选择1只「娱乐法师」灵摆怪兽。
		local g=Duel.SelectMatchingCard(tp,s.schfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的灵摆怪兽表侧表示送去额外卡组。
			Duel.SendtoExtraP(g,nil,REASON_EFFECT)
		end
	elseif sel==2 then
		-- 获取自己场上所有可破坏的「娱乐法师」怪兽卡。
		local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,nil)
		if g:GetCount()>0 then
			-- 提示玩家选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=g:Select(tp,1,1,nil)
			-- 闪烁显示被选择要破坏的卡片。
			Duel.HintSelection(dg)
			-- 破坏选中的「娱乐法师」怪兽卡。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
-- 怪兽效果③的特殊召唤发动条件：特殊召唤的对方怪兽直接攻击宣言时。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击宣言的怪兽是否由对方控制，且攻击对象为空（即直接攻击）。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
		-- 检查进行攻击宣言的对方怪兽是否是通过特殊召唤出场的。
		and Duel.GetAttacker():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 怪兽效果③的发动准备与合法性检查，并设置特殊召唤的操作信息。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示此效果会将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 怪兽效果③的执行逻辑：将自身从墓地特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，且不受「王家之谷」的影响。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将自身以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
