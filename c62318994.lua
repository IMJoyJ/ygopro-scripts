--サクリファイス・D・ロータス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从卡组把1只「于贝尔」怪兽特殊召唤。
-- ②：对方回合，自己场上有「于贝尔」怪兽存在，怪兽的效果发动时，把这张卡解放才能发动。那个效果变成「场上1只「于贝尔」怪兽破坏」。
-- ③：这张卡在墓地存在，自己场上有「于贝尔」存在的场合，自己结束阶段才能发动。这张卡加入手卡或特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①②③效果的注册。
function s.initial_effect(c)
	-- 记录这张卡的效果文本中记载了「于贝尔」（卡号78371393）。
	aux.AddCodeList(c,78371393)
	-- 记录这张卡的效果文本中记载了「于贝尔」系列怪兽。
	aux.AddSetNameMonsterList(c,0x1a5)
	-- ①：把这张卡解放才能发动。从卡组把1只「于贝尔」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，自己场上有「于贝尔」怪兽存在，怪兽的效果发动时，把这张卡解放才能发动。那个效果变成「场上1只「于贝尔」怪兽破坏」。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果修改"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.chcon)
	e2:SetCost(s.chcost)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在，自己场上有「于贝尔」存在的场合，自己结束阶段才能发动。这张卡加入手卡或特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"墓地回收"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.thoscon)
	e3:SetTarget(s.thostg)
	e3:SetOperation(s.thosop)
	c:RegisterEffect(e3)
end
-- 效果①的COST检测与执行函数。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动COST。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果①的过滤条件：卡组中的「于贝尔」系列怪兽且可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1a5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（Target）函数。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查解放自身后，自己场上是否有可用于特殊召唤的怪兽区域。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 并且卡组中存在至少1只满足条件的「于贝尔」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「于贝尔」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件过滤：自己场上表侧表示的「于贝尔」系列怪兽。
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a5)
end
-- 效果②的发动条件（Condition）函数。
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是对方回合，且对方发动了怪兽的效果。
	return Duel.GetTurnPlayer()==1-tp and re:IsActiveType(TYPE_MONSTER)
		-- 并且自己场上存在表侧表示的「于贝尔」怪兽。
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的COST检测与执行函数。
function s.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动COST。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②修改后效果的过滤条件：场上的「于贝尔」系列怪兽。
function s.repfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1a5)
end
-- 效果②的发动准备（Target）函数。
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只「于贝尔」怪兽作为破坏对象。
	if chk==0 then return Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果②的效果处理（Operation）函数。
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 清空被修改效果的原本对象。
	Duel.ChangeTargetCard(ev,g)
	-- 将该连锁的效果处理函数替换为「场上1只「于贝尔」怪兽破坏」的处理函数。
	Duel.ChangeChainOperation(ev,s.repop)
end
-- 替换后的效果处理函数（破坏场上1只「于贝尔」怪兽）。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动该效果的玩家选择场上1只「于贝尔」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 选中该怪兽并显示选择动画。
		Duel.HintSelection(g)
		-- 破坏选中的怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果③的发动条件过滤：自己场上表侧表示的「于贝尔」（卡号78371393）。
function s.rccfilter(c)
	return c:IsFaceup() and c:IsCode(78371393)
end
-- 效果③的发动条件（Condition）函数。
function s.thoscon(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是自己的回合。
	return Duel.GetTurnPlayer()==tp
		-- 并且自己场上存在表侧表示的「于贝尔」。
		and Duel.IsExistingMatchingCard(s.rccfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果③的发动准备（Target）函数。
function s.thostg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
end
-- 效果③的效果处理（Operation）函数。
function s.thosop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查并适用「王家之谷-Necrovalley」对墓地卡片效果的无效化。
	if aux.NecroValleyNegateCheck(c) then return end
	-- 过滤受「王家之谷-Necrovalley」影响无法操作的卡。
	if not aux.NecroValleyFilter()(c) then return end
	-- 提示玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	if c:IsRelateToEffect(e) then
		if ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 如果不能加入手卡，或者玩家在“加入手卡”与“特殊召唤”中选择了“特殊召唤”。
			and (not c:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将这张卡特殊召唤。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将这张卡加入手卡。
			Duel.SendtoHand(c,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的这张卡。
			Duel.ConfirmCards(1-tp,c)
		end
	end
end
