--D3
-- 效果：
-- 「D3」的②③的效果1回合各能使用1次。
-- ①：这张卡召唤成功的场合发动。这只怪兽在表侧表示存在期间，也当作「命运英雄」怪兽使用。
-- ②：把最多2张手卡丢弃才能发动。从自己的手卡·卡组·墓地选丢弃数量的「D3」特殊召唤。这个效果的发动后，直到回合结束时自己不是「命运英雄」怪兽不能召唤·特殊召唤。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「命运英雄」怪兽送去墓地。
function c99357565.initial_effect(c)
	-- ①：这张卡召唤成功的场合发动。这只怪兽在表侧表示存在期间，也当作「命运英雄」怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99357565,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c99357565.scop)
	c:RegisterEffect(e1)
	-- ②：把最多2张手卡丢弃才能发动。从自己的手卡·卡组·墓地选丢弃数量的「D3」特殊召唤。这个效果的发动后，直到回合结束时自己不是「命运英雄」怪兽不能召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99357565,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,99357565)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c99357565.spcost)
	e2:SetTarget(c99357565.sptg)
	e2:SetOperation(c99357565.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「命运英雄」怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99357565,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,99357566)
	e3:SetCondition(c99357565.tgcon)
	e3:SetTarget(c99357565.tgtg)
	e3:SetOperation(c99357565.tgop)
	c:RegisterEffect(e3)
end
-- 召唤成功时，将此卡当作「命运英雄」怪兽使用的效果处理
function c99357565.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这只怪兽在表侧表示存在期间，也当作「命运英雄」怪兽使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_SETCODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0xc008)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 检查卡片是否为「D3」以及是否可以特殊召唤
function c99357565.spfilter(c,e,tp)
	return c:IsCode(99357565) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 丢弃手卡特殊召唤「D3」的代价与数量检测
function c99357565.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 进入代价检测，判断手卡中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	local ct=2
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 结合主要怪兽区域空位数限制最大丢弃卡片数
	ct=math.min(ct,(Duel.GetLocationCount(tp,LOCATION_MZONE)),
		-- 结合手卡、卡组、墓地可特殊召唤的「D3」数量限制最大丢弃卡片数
		Duel.GetMatchingGroupCount(c99357565.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,nil,e,tp))
	-- 让玩家丢弃对应数量的手卡作为发动代价
	local cg=Duel.DiscardHand(tp,Card.IsDiscardable,1,ct,REASON_COST+REASON_DISCARD,nil)
	e:SetLabel(cg)
end
-- 特殊召唤「D3」的发动检测与操作信息设置
function c99357565.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有可用于特殊召唤的空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡、卡组、墓地是否存在至少1只可特殊召唤的「D3」
		and Duel.IsExistingMatchingCard(c99357565.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息，包含待召卡片数量及所在区域
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,e:GetLabel(),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
-- 特殊召唤「D3」并施加本回合不是「命运英雄」不能召唤·特殊召唤的限制处理
function c99357565.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 获取自己场上当前可用的空怪兽格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>=ct then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133) then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从手卡、卡组、墓地选出与丢弃数量相同的「D3」（受王家长眠之谷限制）
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c99357565.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,ct,ct,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的「D3」以表侧表示特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是「命运英雄」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c99357565.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册本回合不能特殊召唤「命运英雄」以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 给玩家注册本回合不能通常召唤「命运英雄」以外怪兽的限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 通常召唤·特殊召唤怪兽字段限制，非「命运英雄」怪兽则无法召唤·特召
function c99357565.splimit(e,c)
	return not c:IsSetCard(0xc008)
end
-- 检查此卡是否因战斗或效果而被破坏
function c99357565.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 检查卡片是否为「命运英雄」怪兽且可以送入墓地
function c99357565.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xc008) and c:IsAbleToGrave()
end
-- 从卡组将「命运英雄」怪兽送去墓地的发动检测与操作信息设置
function c99357565.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己卡组中是否存在可以送去墓地的「命运英雄」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c99357565.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置送去墓地操作信息，数量为1，目标区域为卡组
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行从卡组将「命运英雄」怪兽送入墓地的操作
function c99357565.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1只「命运英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,c99357565.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将被选中的怪兽送入墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
