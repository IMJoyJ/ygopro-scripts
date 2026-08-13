--地獄人形の館
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「机关傀儡」怪兽加入手卡。
-- ②：自己场上的「机关傀儡」怪兽不会被战斗破坏，不受超量怪兽以外的对方怪兽发动的效果影响。
-- ③：1回合1次，把自己场上1个超量素材取除，以自己墓地1只「机关傀儡」怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。
local s,id,o=GetID()
-- 该函数是卡片的初始化入口，为卡片创建并注册三个效果：①发动时从卡组检索「机关傀儡」怪兽加入手卡；②自己场上的「机关傀儡」怪兽获得战斗破坏抗性与超量怪兽以外的对方怪兽效果免疫；③通过去除自己场上1个超量素材，将墓地「机关傀儡」怪兽特殊召唤到对方场上守备表示。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「机关傀儡」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「机关傀儡」怪兽不会被战斗破坏，
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	-- ③：1回合1次，把自己场上1个超量素材取除，以自己墓地1只「机关傀儡」怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数，判断卡组中的卡是否为「机关傀儡」字段的怪兽且能够加入手卡，用于检索时的筛选条件。
function s.filter(c)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时的效果处理：从持有者的卡组获取所有符合条件的「机关傀儡」怪兽，若存在且玩家选择发动，则从中选择1张加入手卡，并向对方展示。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取以tp玩家视角查看的自己卡组中所有满足s.filter条件的「机关傀儡」怪兽集合。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 判断检索对象集合不为空，并且询问发动者是否要执行从卡组加入手卡的效果。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组把「机关傀儡」怪兽加入手卡？"
		-- 给玩家tp发送卡片选择提示信息，提示其选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「机关傀儡」怪兽以效果原因送入其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将检索并加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤函数，判断怪兽是否为表侧表示的「机关傀儡」怪兽，用于自己场上「机关傀儡」怪兽的战斗破坏免疫效果的目标筛选。
function s.indtg(e,c)
	return c:IsSetCard(0x1083) and c:IsFaceup()
end
-- 效果免疫过滤函数：免疫来源为对方玩家、已发动、且是怪兽效果的卡，但对方超量怪兽发动的效果不免疫；即“不受超量怪兽以外的对方怪兽发动的效果影响”。
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated() and re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsType(TYPE_XYZ)
end
-- 过滤函数，判断墓地中的「机关傀儡」怪兽是否能由发动者tp特殊召唤到对方场上，且以表侧守备表示进行特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- 特殊召唤效果的发动代价：自己场上1个超量素材取除。先检查是否满足代价，满足则实际执行移除1个超量素材。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认发动者tp自己的场上是否存在至少1个可移除的超量素材作为代价。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 实际执行代价：从tp玩家自己场上移除1个超量素材，移除原因为效果代价。
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 特殊召唤效果的发动条件与取对象处理：需要对方场上有空余怪兽区，且自己墓地存在符合条件的「机关傀儡」怪兽；满足条件时选择墓地1只作为效果对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动条件检查：确认对方玩家(1-tp)的怪兽区还有空位可以特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 发动条件检查：确认自己墓地存在至少1只满足s.spfilter条件的「机关傀儡」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家tp发送卡片选择提示信息，提示其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「机关傀儡」怪兽作为效果对象，并自动将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息，标明本效果包含特殊召唤分类，对象为已选择的墓地怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤处理：取得效果对象，若对象仍与效果关联，则将其特殊召唤到对方场上表侧守备表示。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取得已选择的特殊召唤对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标「机关傀儡」怪兽以表侧守备表示特殊召唤到对方玩家(1-tp)的怪兽区，不检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
