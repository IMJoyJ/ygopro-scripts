--天帝アイテール
-- 效果：
-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
-- ①：这张卡上级召唤的场合才能发动。从手卡·卡组把「帝王」魔法·陷阱卡2种类各1张送去墓地，从卡组把1只攻击力2400以上而守备力1000的怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
-- ②：这张卡在手卡存在的场合，对方主要阶段，从自己墓地把1张「帝王」魔法·陷阱卡除外才能发动（同一连锁上最多1次）。进行这张卡的上级召唤。
function c96570609.initial_effect(c)
	-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96570609,0))  --"把1只上级召唤的怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c96570609.otcon)
	e1:SetOperation(c96570609.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：这张卡上级召唤的场合才能发动。从手卡·卡组把「帝王」魔法·陷阱卡2种类各1张送去墓地，从卡组把1只攻击力2400以上而守备力1000的怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96570609,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c96570609.spcon)
	e3:SetTarget(c96570609.sptg)
	e3:SetOperation(c96570609.spop)
	c:RegisterEffect(e3)
	-- ②：这张卡在手卡存在的场合，对方主要阶段，从自己墓地把1张「帝王」魔法·陷阱卡除外才能发动（同一连锁上最多1次）。进行这张卡的上级召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(96570609,2))  --"上级召唤"
	e4:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_HAND)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(c96570609.sumcon)
	e4:SetCost(c96570609.sumcost)
	e4:SetTarget(c96570609.sumtg)
	e4:SetOperation(c96570609.sumop)
	c:RegisterEffect(e4)
end
-- 过滤条件：是否为上级召唤登场的怪兽
function c96570609.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 判定是否满足「把1只上级召唤的怪兽解放作上级召唤」的召唤规则条件
function c96570609.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取场上所有通过上级召唤登场的怪兽
	local mg=Duel.GetMatchingGroup(c96570609.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 判定自身等级是否在7星以上、所需最少祭品数是否不大于1，且场上是否存在至少1只上级召唤登场的怪兽作为祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行「把1只上级召唤的怪兽解放作上级召唤」的解放操作
function c96570609.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有通过上级召唤登场的怪兽
	local mg=Duel.GetMatchingGroup(c96570609.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 让玩家选择1只上级召唤登场的怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽用于上级召唤
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 触发条件：此卡成功进行上级召唤的场合
function c96570609.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤条件：手卡·卡组中可以送去墓地的「帝王」魔法·陷阱卡
function c96570609.tgfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 过滤条件：卡组中可以特殊召唤的攻击力2400以上且守备力1000的怪兽
function c96570609.spfilter(c,e,tp)
	return c:IsAttackAbove(2400) and c:IsDefense(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测（检查手卡·卡组是否有2种不同名「帝王」魔陷，且卡组有符合条件的怪兽可特召，并有空怪兽位）
function c96570609.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取手卡和卡组中所有满足条件的「帝王」魔法·陷阱卡
		local g=Duel.GetMatchingGroup(c96570609.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>1
			-- 检查自己场上是否有可用的怪兽区域空格
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组中是否存在至少1只满足特召条件的攻击力2400以上且守备力1000的怪兽
			and Duel.IsExistingMatchingCard(c96570609.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置操作信息：从卡组将2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：送墓2种「帝王」魔陷，特召符合条件的怪兽，并注册结束阶段回到手卡的效果
function c96570609.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡和卡组中所有满足条件的「帝王」魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c96570609.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从符合条件的卡中选择2张卡名不同的卡
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选中的2张卡送去墓地，并确认它们是否成功到达墓地
	if Duel.SendtoGrave(tg1,REASON_EFFECT)~=0 and tg1:IsExists(Card.IsLocation,2,nil,LOCATION_GRAVE)
		-- 确认自己场上仍有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只满足特召条件的攻击力2400以上且守备力1000的怪兽
		local g=Duel.SelectMatchingCard(tp,c96570609.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			local fid=e:GetHandler():GetFieldID()
			tc:RegisterFlagEffect(96570609,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 这个效果特殊召唤的怪兽在结束阶段回到手卡。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(c96570609.thcon)
			e1:SetOperation(c96570609.thop)
			-- 注册全局延迟效果，用于在结束阶段将特召的怪兽送回手卡
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 检查特召的怪兽是否仍在场上且标记未丢失，若已不在则重置该延迟效果
function c96570609.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(96570609)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行将特召怪兽送回手卡的操作
function c96570609.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该怪兽送回持有者的手卡
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
-- 效果②的触发条件：对方回合的主要阶段
function c96570609.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 判定当前是否为对方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤条件：墓地中可以作为发动成本除外的「帝王」魔法·陷阱卡
function c96570609.cfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动成本处理：从自己墓地除外1张「帝王」魔法·陷阱卡
function c96570609.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查墓地中是否存在至少1张可除外的「帝王」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c96570609.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张「帝王」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c96570609.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡表侧表示除外作为发动成本
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的目标确认：检查此卡是否可以进行通常召唤（表侧召唤或里侧放置）
function c96570609.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1) end
	-- 设置操作信息：进行1只怪兽的通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
-- 效果②的处理：让玩家选择表示形式并进行此卡的上级召唤（或里侧放置）
function c96570609.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local pos=0
	if c:IsSummonable(true,nil,1) then pos=pos+POS_FACEUP_ATTACK end
	if c:IsMSetable(true,nil,1) then pos=pos+POS_FACEDOWN_DEFENSE end
	if pos==0 then return end
	-- 让玩家选择此卡召唤时的表示形式，并判断是否选择了表侧攻击表示
	if Duel.SelectPosition(tp,c,pos)==POS_FACEUP_ATTACK then
		-- 进行此卡的表侧表示上级召唤（无视每回合通常召唤次数限制，至少需要1个祭品）
		Duel.Summon(tp,c,true,nil,1)
	else
		-- 进行此卡的里侧表示上级放置（无视每回合通常召唤次数限制，至少需要1个祭品）
		Duel.MSet(tp,c,true,nil,1)
	end
end
