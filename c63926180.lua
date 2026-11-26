--神霊剣アイワス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这个回合，自己不用融合怪兽不能攻击宣言。
-- ●从自己的卡组·墓地把1只「法之神灵 艾华斯」特殊召唤。
-- ●从卡组选1只「阿莱斯特」怪兽送去墓地或除外。
-- ●把对方的额外卡组的里侧的卡随机3张确认，选那之内的1张除外。
local s,id,o=GetID()
-- 初始化卡片效果：登记「法之神灵 艾华斯」卡名记载列表，并注册1回合1次的三选一魔法卡发动效果
function s.initial_effect(c)
	-- 记录此卡效果文本中记述有「法之神灵 艾华斯」的卡名
	aux.AddCodeList(c,84288367)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●从自己的卡组·墓地把1只「法之神灵 艾华斯」特殊召唤。●从卡组选1只「阿莱斯特」怪兽送去墓地或除外。●把对方的额外卡组的里侧的卡随机3张确认，选那之内的1张除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤己方卡组或墓地中可特殊召唤的「法之神灵 艾华斯」
function s.spfilter(c,e,tp)
	return c:IsCode(84288367) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤卡组中可送去墓地或可除外的「阿莱斯特」怪兽
function s.tgfilter(c)
	return c:IsSetCard(0x1e1) and c:IsType(TYPE_MONSTER) and (c:IsAbleToGrave() or c:IsAbleToRemove())
end
-- 过滤对方额外卡组中里侧表示且可被除外的卡片
function s.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 发动前校验三个选项中至少有一个可行，让己方从中选择1个并据此设置对应效果分类与操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查选项1的前提条件：己方怪兽区是否有可用空位
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查己方卡组·墓地是否存在可特殊召唤的「法之神灵 艾华斯」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查选项2条件：己方卡组是否存在可送墓或除外的「阿莱斯特」怪兽
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查选项3条件：对方额外卡组是否存在至少3张里侧表示且可除外的卡
	local b3=Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_EXTRA,3,nil)
	if chk==0 then return b1 or b2 or b3 end
	-- 从满足条件的选项中让己方玩家选择1个要发动的效果分支
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"特殊召唤"
			{b2,aux.Stringid(id,2),2},  --"卡组选1只「阿莱斯特」怪兽"
			{b3,aux.Stringid(id,3),3})  --"除外额外"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECK_SPSUMMON)
		end
		-- 登记从己方卡组或墓地特殊召唤1只怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_DECKDES)
		end
	elseif op==3 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_REMOVE)
		end
		-- 登记从对方额外卡组除外1张卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
	end
end
-- 效果处理：施加本回合己方非融合怪兽不能攻击宣言的自肃限制，随后根据所选分支执行特召、卡组送墓/除外或随机确认除外对方额外卡组
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己不用融合怪兽不能攻击宣言。●从自己的卡组·墓地把1只「法之神灵 艾华斯」特殊召唤。●从卡组选1只「阿莱斯特」怪兽送去墓地或除外。●把对方的额外卡组的里侧的卡随机3张确认，选那之内的1张除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为己方玩家注册持续至回合结束的攻击宣言限制效果
	Duel.RegisterEffect(e1,tp)
	if e:GetLabel()==1 then
		-- 处理选项1时检查己方怪兽区是否仍有空位，无空位则中止
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向己方发送选择要特殊召唤的「法之神灵 艾华斯」的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 受「王家长眠之谷」判定过滤后，从己方卡组或墓地选择1只「法之神灵 艾华斯」
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「法之神灵 艾华斯」以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif e:GetLabel()==2 then
		-- 向己方发送从卡组选择要操作的「阿莱斯特」怪兽的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 让己方从卡组选择1只「阿莱斯特」怪兽
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 判断该卡能否送去墓地，并在不能除外或玩家选择送去墓地时执行送墓分支
			if tc and tc:IsAbleToGrave() and (not tc:IsAbleToRemove() or Duel.SelectOption(tp,1191,1192)==0) then
				-- 将选中的「阿莱斯特」怪兽以效果送去墓地
				Duel.SendtoGrave(tc,REASON_EFFECT)
			else
				-- 将选中的「阿莱斯特」怪兽以效果表侧除外
				Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
			end
		end
	elseif e:GetLabel()==3 then
		-- 获取对方额外卡组中所有里侧表示的卡片
		local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_EXTRA,nil)
		if g:GetCount()<3 then return end
		local cg=g:RandomSelect(1-tp,3)
		local flag=cg:FilterCount(Card.IsAbleToRemove,nil)>0
		-- 将随机选出的3张对方额外卡组里侧卡展示给己方确认
		Duel.ConfirmCards(tp,cg,flag)
		-- 向己方发送从确认的3张卡中选择1张除外的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=cg:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
		-- 将选中的1张对方额外卡组卡片以效果表侧除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		-- 洗切对方的额外卡组
		Duel.ShuffleExtra(1-tp)
	end
end
-- 攻击限制过滤函数：使己方场上非融合怪兽的怪兽不能进行攻击宣言
function s.atktg(e,c)
	return not c:IsType(TYPE_FUSION)
end
