--蕾禍ノ大王鬼牙
-- 效果：
-- 昆虫族·植物族·爬虫类族怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从对方的卡组·额外卡组有怪兽特殊召唤的场合才能发动。场上2只怪兽破坏。
-- ②：这张卡在墓地存在的场合，以自己场上1只昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化函数：为这张卡添加连接召唤手续（素材为昆虫·植物·爬虫类族怪兽2~5只）并解除特殊召唤限制；注册效果①（对方从卡组/额外卡组特招怪兽时，破坏场上2只怪兽）和效果②（墓地起动，取对象将自己场上1只对应种族怪兽回卡组底，这张卡特殊召唤，并附加本回合非对应种族不能特招的自肃）。
function s.initial_effect(c)
	-- 添加连接召唤手续：以2~5只昆虫族·植物族·爬虫类族怪兽为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_INSECT+RACE_PLANT+RACE_REPTILE),2,5)
	c:EnableReviveLimit()
	-- 效果①：‘①：从对方的卡组·额外卡组有怪兽特殊召唤的场合才能发动。场上2只怪兽破坏。’
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.decon)
	e1:SetTarget(s.detg)
	e1:SetOperation(s.deop)
	c:RegisterEffect(e1)
	-- 效果②：‘②：这张卡在墓地存在的场合，以自己场上1只昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。’
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义过滤条件：判断一只怪兽是否由对方玩家从卡组或额外卡组特殊召唤（用于触发①）。
function s.defilter(c,tp)
	return c:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
-- 效果①的发动条件：本次特殊召唤成功的怪兽组中，存在至少1只由对方从卡组·额外卡组特殊召唤的怪兽。
function s.decon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.defilter,1,nil,tp)
end
-- 效果①的目标阶段处理：确认场上存在至少2只怪兽后才可发动；若可发动，则将场上所有怪兽设定为破坏效果的可能对象，并写入操作信息（实际破坏对象在处理时选择）。
function s.detg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：双方场上怪兽区合计至少有2只怪兽，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
	-- 获取当前场上所有怪兽（双方主要怪兽区），作为设置操作信息时的可能破坏对象集合。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：本次效果包含破坏分类，可能被破坏的对象为场上全部怪兽，处理时确定破坏其中2只。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果①的处理：重新获取场上怪兽，若不足2只则效果不处理；否则提示选择要破坏的卡，并从双方场上选择2只怪兽破坏。
function s.deop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次获取当前场上所有怪兽，用于确认破坏对象数量是否足够。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()<2 then return end
	-- 显示选择提示：请选择要破坏的卡（HINTMSG_DESTROY）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上怪兽区选择2只怪兽作为破坏对象（不取对象，处理时选择）。
	local sg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
	if sg:GetCount()==2 then
		-- 手动展示所选2只怪兽的选中动画，并将其记录为已选择对象。
		Duel.HintSelection(sg)
		-- 以效果原因破坏所选择的2只怪兽。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 定义效果②的选怪过滤条件：用于选择自己场上1只可返回卡组、且为昆虫·植物·爬虫类族的表侧怪兽，并确保该怪兽离开后自己场上仍有空位可特招这张卡。
function s.spfilter(c,tp)
	-- 条件为：该怪兽离开后自己主要怪兽区仍有空位；该怪兽表侧表示、种族为昆虫·植物·爬虫类，且能够返回卡组。
	return Duel.GetMZoneCount(tp,c)>0 and c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsAbleToDeck()
end
-- 效果②的目标选择：选择自己场上1只满足条件的对应种族怪兽作为对象，同时确认墓地中的这张卡能够被特殊召唤，否则不能发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.spfilter(chkc,tp) end
	-- 发动合法性检查：自己场上存在至少1只满足s.spfilter的怪兽，且墓地中的这张卡可以特殊召唤。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 显示选择提示：请选择要返回卡组的卡（HINTMSG_TODECK）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己场上选择1只满足条件的怪兽作为取对象目标，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：本次效果包含将对象怪兽返回卡组的处理，目标为已选择的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置操作信息：本次效果包含将墓地中的这张卡特殊召唤的处理，对象为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②处理：先将对象怪兽送回持有者卡组最下面；若送回成功、对象确实进入卡组/额外卡组、自己场上有空位且这张卡仍与效果关联，则将这张卡特殊召唤；最后给己方附加本回合不能特殊召唤非对应种族怪兽的自肃。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取回效果②的对象怪兽（即要返回卡组的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联且为怪兽，将其送回持有者卡组最下面（SEQ_DECKBOTTOM），且实际操作数量非0。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 继续确认对象已成功进入卡组或额外卡组，同时自己主要怪兽区有空位，且墓地中的这张卡仍与效果关联，才可进行特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		-- 将墓地中的这张卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 效果②的自肃部分：“这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到全场：以己方为对象，在回合结束前，禁止特殊召唤非昆虫·植物·爬虫类族怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定函数：若怪兽种族不是昆虫·植物·爬虫类族，则不允许特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE)
end
