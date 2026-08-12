--神霊剣アイワス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这个回合，自己不用融合怪兽不能攻击宣言。
-- ●从自己的卡组·墓地把1只「法之神灵 艾华斯」特殊召唤。
-- ●从卡组选1只「阿莱斯特」怪兽送去墓地或除外。
-- ●把对方的额外卡组的里侧的卡随机3张确认，选那之内的1张除外。
local s,id,o=GetID()
-- 在卡片效果初始化函数中，声明卡片关联的其他卡，并注册该卡的发动效果，包含卡片效果分类、类型、时点、次数限制以及目标和效果处理函数。
function s.initial_effect(c)
	-- 在卡片信息中记录该卡记载了「法之神灵 艾华斯」（卡号：84288367）的卡名。
	aux.AddCodeList(c,84288367)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。这个回合，自己不用融合怪兽不能攻击宣言。●从自己的卡组·墓地把1只「法之神灵 艾华斯」特殊召唤。●从卡组选1只「阿莱斯特」怪兽送去墓地或除外。●把对方的额外卡组的里侧的卡随机3张确认，选那之内的1张除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选卡片密码为84288367（法之神灵 艾华斯）且可以被特殊召唤的卡片。
function s.spfilter(c,e,tp)
	return c:IsCode(84288367) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：筛选卡组中属于「阿莱斯特」字段的怪兽，且该怪兽可被送去墓地或除外。
function s.tgfilter(c)
	return c:IsSetCard(0x1e1) and c:IsType(TYPE_MONSTER) and (c:IsAbleToGrave() or c:IsAbleToRemove())
end
-- 过滤函数：筛选额外卡组中里侧表示且可以被除外的卡。
function s.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 效果发动时的目标选择与校验函数，检测三个可选效果的合法性，由玩家选择其中一个效果进行发动，并根据所选效果设定相应的效果分类与操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 校验第一个可选效果的前提条件之一：自己场上有空余的怪兽区域。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 校验第一个可选效果的前提条件之二：自己的卡组或墓地中存在可以特殊召唤的「法之神灵 艾华斯」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 校验第二个可选效果的前提条件：自己的卡组中存在可以被送去墓地或除外的「阿莱斯特」怪兽。
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	-- 校验第三个可选效果的前提条件：对方额外卡组里侧表示的卡片数量至少有3张且都可以被除外。
	local b3=Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_EXTRA,3,nil)
	if chk==0 then return b1 or b2 or b3 end
	-- 让玩家在满足发动条件的几个效果选项中选择一个执行。
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"特殊召唤"
			{b2,aux.Stringid(id,2),2},  --"卡组选1只「阿莱斯特」怪兽"
			{b3,aux.Stringid(id,3),3})  --"除外额外"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置连锁处理的操作信息，声明本次效果会从卡组或墓地特殊召唤1张卡。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_DECKDES)
		end
	elseif op==3 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_REMOVE)
		end
		-- 设置连锁处理的操作信息，声明本次效果会将对方额外卡组的1张卡除外。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
	end
end
-- 效果处理函数：首先注册攻击限制效果，然后根据玩家在发动时所做的选择，执行对应的效果处理（特召怪兽、送墓/除外卡组怪兽、或是确认并除外对方额外卡组的卡）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- ①：可以从以下效果选择1个发动。这个回合，自己不用融合怪兽不能攻击宣言。●从自己的卡组·墓地把1只「法之神灵 艾华斯」特殊召唤。●从卡组选1只「阿莱斯特」怪兽送去墓地或除外。●把对方的额外卡组的里侧的卡随机3张确认，选那之内的1张除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不用融合怪兽不能攻击宣言”的限制效果注册给发动该效果的玩家。
	Duel.RegisterEffect(e1,tp)
	if e:GetLabel()==1 then
		-- 对于第一个效果：若怪兽区域没有空位则特殊召唤无法进行，效果终止。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 对于第一个效果：向玩家发送提示，指示选择用于特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 对于第一个效果：让玩家从卡组或墓地中选择1只符合条件的怪兽，若从墓地选择则进行王家长眠之谷的检测。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 对于第一个效果：将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif e:GetLabel()==2 then
		-- 对于第二个效果：向玩家发送提示，指示选择要操作的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 对于第二个效果：让玩家从卡组筛选1只符合条件的「阿莱斯特」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 对于第二个效果：若该卡能送去墓地，且（该卡不能除外 或 玩家选择“送去墓地”选项时），进入送去墓地的处理分支。
			if tc and tc:IsAbleToGrave() and (not tc:IsAbleToRemove() or Duel.SelectOption(tp,1191,1192)==0) then
				-- 对于第二个效果：因效果将选定的怪兽送去墓地。
				Duel.SendtoGrave(tc,REASON_EFFECT)
			else
				-- 对于第二个效果：因效果将选定的怪兽以表侧表示除外。
				Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
			end
		end
	elseif e:GetLabel()==3 then
		-- 对于第三个效果：获取对方额外卡组里侧表示的卡片组。
		local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_EXTRA,nil)
		if g:GetCount()<3 then return end
		local cg=g:RandomSelect(1-tp,3)
		local flag=cg:FilterCount(Card.IsAbleToRemove,nil)>0
		-- 对于第三个效果：给当前玩家展示确认随机选出的3张里侧额外怪兽。
		Duel.ConfirmCards(tp,cg,flag)
		-- 对于第三个效果：向玩家发送提示，指示在确认的卡中选择要除外的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=cg:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
		-- 对于第三个效果：将玩家选中的卡片以表侧表示除外。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		-- 对于第三个效果：重新洗切对方的额外卡组。
		Duel.ShuffleExtra(1-tp)
	end
end
-- 限制攻击效果的靶点函数：筛选自己场上所有非融合怪兽的怪兽，作为不能发动攻击宣言的对象。
function s.atktg(e,c)
	return not c:IsType(TYPE_FUSION)
end
