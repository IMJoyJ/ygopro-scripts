--ゴーティスの朧キーフ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：场上有鱼族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：对方场上有怪兽特殊召唤的场合，以那之内的1只怪兽和自己的除外状态的1只6星以下的鱼族怪兽为对象才能发动。作为对象的对方怪兽和这张卡除外，作为对象的自己怪兽特殊召唤。
-- ③：这张卡被除外的下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。
local s,id,o=GetID()
-- 注册该卡全部效果：①手牌起动特殊召唤、②对方怪兽特殊召唤时取对象除外并特招除外区鱼族、③除外后下个准备阶段特殊召唤，以及为③服务的除外标记效果。
function s.initial_effect(c)
	-- 这个卡名的①②③的效果1回合各能使用1次。①：场上有鱼族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上有怪兽特殊召唤的场合，以那之内的1只怪兽和自己的除外状态的1只6星以下的鱼族怪兽为对象才能发动。作为对象的对方怪兽和这张卡除外，作为对象的自己怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外对方怪兽"
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_REMOVE)
	e3:SetOperation(s.spreg)
	c:RegisterEffect(e3)
	-- 下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"除外对方怪兽"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.spcon1)
	e4:SetTarget(s.sptg1)
	e4:SetOperation(s.spop1)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 定义过滤函数s.cfilter：判断怪兽是否表侧表示且种族为鱼族，用于①的发动条件中检查场上是否存在鱼族怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH)
end
-- 定义①的发动条件：任意一方场上存在至少1只表侧表示鱼族怪兽时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上合计是否存在至少1只表侧表示鱼族怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 定义①的发动目标（chk==0阶段）：自己主要怪兽区有空位，且这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否还有可用的空位（用于从手卡特殊召唤这张卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次特殊召唤的操作信息登记为CATEGORY_SPECIAL_SUMMON，目标为自己手牌的这张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义①的效果处理：确认这张卡仍与发动效果关联后，将它特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义筛选除外区鱼族怪兽的过滤函数s.spfilter1：可用效果特殊召唤、6星以下、鱼族，并且基夫本身可以被除外，以保证②处理时能完成除外自己。
function s.spfilter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(6) and c:IsRace(RACE_FISH) and e:GetHandler():IsAbleToRemove()
end
-- 定义筛选对方场上可除外的怪兽的过滤函数s.rmfilter：位于对方主要怪兽区、控制者为对方、可被除外、能成为该效果的对象。
function s.rmfilter(c,tp,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
-- 定义②的触发条件：对方场上有怪兽被特殊召唤成功（eg中存在控制者为对方的怪兽）。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 定义②的发动目标：在对方场上被特殊召唤的怪兽中选取可作为对象的对方怪兽，并在自己除外区选取符合条件的鱼族怪兽作为特殊召唤对象；检查条件并登记操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=eg:Filter(s.rmfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) and e:GetHandler():IsAbleToRemove() end
	-- 检查②发动时合法性：cost检查通过、至少存在1只可除外的对方怪兽，且自己特殊召唤区域可用（>=0表示此处不实际限制空格数）。
	if chk==0 then return e:IsCostChecked() and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=0
	-- 检查自己除外区是否存在至少1只符合条件的鱼族怪兽（6星以下、可特殊召唤，且基夫可除外）。
	and Duel.IsExistingTarget(s.spfilter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的对方怪兽（选择框提示文案）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tg=g:Clone()
	if #g>1 then
		-- 当候选对方怪兽多于1只时，再次提示玩家选择要除外的对方怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		tg=g:Select(tp,1,1,nil)
	end
	-- 将选中的对方怪兽设置为当前连锁的对象（作为效果处理时的依据）。
	Duel.SetTargetCard(tg)
	-- 将除外操作信息登记：目标为选中的对方怪兽，数量为实际选择张数，供后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,#tg,0,0)
	-- 提示玩家选择要特殊召唤的自己除外区的鱼族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己除外区选择1只符合s.spfilter1条件的鱼族怪兽作为对象，并自动设置为当前连锁的对象。
	local g2=Duel.SelectTarget(tp,s.spfilter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 将特殊召唤操作信息登记：目标为g2，数量1，供后续处理与连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
-- 定义②的效果处理：取出登记的除外对象和特殊召唤对象；若对方怪兽仍可除外、自身仍关联且可除外，则同时除外对方怪兽和自身；成功除外2张且特殊召唤对象仍关联时，将其特殊召唤。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出本次连锁中登记的CATEGORY_REMOVE操作信息，得到要除外的目标组tg1。
	local res1,tg1=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
	-- 取出本次连锁中登记的CATEGORY_SPECIAL_SUMMON操作信息，得到要特殊召唤的目标组tg2。
	local res2,tg2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local c,rc,sc=e:GetHandler(),tg1:GetFirst(),tg2:GetFirst()
	if rc:IsRelateToEffect(e) and rc:IsControler(1-tp) and rc:IsType(TYPE_MONSTER) and c:IsRelateToEffect(e)
		and c:IsAbleToRemove() and rc:IsAbleToRemove() then
		local rg=Group.FromCards(c,rc)
		-- 判定：如果对方怪兽仍与效果关联、为对方怪兽且可除外，自身也仍关联且可除外，则将两者组成一组除外，并检查是否恰好除外成功2张且要特殊召唤的鱼族仍与效果关联。
		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==2 and sc:IsRelateToEffect(e) then
			-- 将选中的除外区鱼族怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义③的辅助效果：这张卡被除外时记录当时的回合数，并给自己设置一个标记，用于判别‘下个回合’并满足③的发动条件。
function s.spreg(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合数，用于记录这张卡被除外时的回合。
	local ct=Duel.GetTurnCount()
	e:SetLabel(ct)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 定义③的发动条件：当前回合不是被除外的那个回合（即已到下个回合），且这张卡拥有被除外的标记，才可发动。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 返回③发动条件：e3记录的回合数≠当前回合数，且这张卡带有id标记。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(id)>0
end
-- 定义③的发动目标：自己主要怪兽区有空位，且这张卡可被特殊召唤。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将特殊召唤操作信息登记：目标为这张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义③的效果处理：若这张卡仍与发动效果关联，则将它特殊召唤。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行③的特殊召唤：将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
